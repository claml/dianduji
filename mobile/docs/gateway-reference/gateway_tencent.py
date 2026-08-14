#!/usr/bin/env python3
"""
点读机在线翻译网关 —— 腾讯云机器翻译（TMT）后端参考实现

契约见 docs/online-translation-gateway.md。

部署（零第三方依赖，Python 3.8+）：
  1. 设置环境变量：
     TENCENT_SECRET_ID=<你的 SecretId>
     TENCENT_SECRET_KEY=<你的 SecretKey>
     TENCENT_REGION=ap-guangzhou        # 可选，默认 ap-guangzhou
     PORT=8080                          # 可选，默认 8080
  2. 运行：python3 gateway_tencent.py
  3. 客户端构建时注入网关地址：
     --dart-define=DIANDUJI_TRANSLATE_BASE_URL=http://<服务器IP>:8080/translate

安全说明：
  - 密钥只存在于服务器环境变量，绝不进入安装包；
  - 日志只记录耗时与状态码，不输出原句、术语或完整响应；
  - 仅翻译 term 与 sentence 两个字段，不转发任何其他内容。
"""

import base64
import hashlib
import hmac
import json
import logging
import os
import sqlite3
import threading
import time
import urllib.request
from datetime import datetime, timezone
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

LOG = logging.getLogger("gateway")
logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")

TMT_HOST = "tmt.tencentcloudapi.com"
TMT_VERSION = "2018-03-21"
TMT_ACTION = "TextTranslate"
TMT_SERVICE = "tmt"
REGION = os.environ.get("TENCENT_REGION", "ap-guangzhou")
SOURCE_LANG = "en"
TARGET_LANG = "zh"
SOURCE_ID = "tencent-tmt"
CACHE_VERSION = "1"


class _Tc3Signer:
    """腾讯云 TC3-HMAC-SHA256 请求签名（官方流程）。"""

    def __init__(self, secret_id: str, secret_key: str):
        self._secret_id = secret_id
        self._secret_key = secret_key

    def authorize(
        self, payload: dict, timestamp: str, date: str
    ) -> str:
        body = json.dumps(payload, ensure_ascii=False)
        content_type = "application/json; charset=utf-8"
        canonical_headers = (
            f"content-type:{content_type}\n"
            f"host:{TMT_HOST}\n"
            f"x-tc-action:{TMT_ACTION.lower()}\n"
        )
        signed_headers = "content-type;host;x-tc-action"
        hashed_payload = hashlib.sha256(body.encode("utf-8")).hexdigest()
        canonical_request = "\n".join(
            ["POST", "/", "", canonical_headers, signed_headers, hashed_payload]
        )
        credential_scope = f"{date}/{TMT_SERVICE}/tc3_request"
        string_to_sign = "\n".join(
            [
                "TC3-HMAC-SHA256",
                timestamp,
                credential_scope,
                hashlib.sha256(canonical_request.encode("utf-8")).hexdigest(),
            ]
        )

        def _hmac(key: bytes, msg: str) -> bytes:
            return hmac.new(key, msg.encode("utf-8"), hashlib.sha256).digest()

        secret_date = _hmac(b"TC3" + self._secret_key.encode("utf-8"), date)
        secret_service = _hmac(secret_date, TMT_SERVICE)
        secret_signing = _hmac(secret_service, "tc3_request")
        signature = hmac.new(
            secret_signing, string_to_sign.encode("utf-8"), hashlib.sha256
        ).hexdigest()
        return (
            f"TC3-HMAC-SHA256 Credential={self._secret_id}/{credential_scope}, "
            f"SignedHeaders={signed_headers}, Signature={signature}"
        )


def _translate_text(signer: _Tc3Signer, text: str) -> str:
    """调用 TextTranslate，返回译文；失败抛出 RuntimeError。"""
    payload = {
        "SourceText": text,
        "Source": SOURCE_LANG,
        "Target": TARGET_LANG,
        "ProjectId": 0,
    }
    now = datetime.now(timezone.utc)
    timestamp = str(int(now.timestamp()))
    date = now.strftime("%Y-%m-%d")
    authorization = signer.authorize(payload, timestamp, date)

    request = urllib.request.Request(
        f"https://{TMT_HOST}",
        data=json.dumps(payload, ensure_ascii=False).encode("utf-8"),
        method="POST",
        headers={
            "Authorization": authorization,
            "Content-Type": "application/json; charset=utf-8",
            "Host": TMT_HOST,
            "X-TC-Action": TMT_ACTION,
            "X-TC-Timestamp": timestamp,
            "X-TC-Version": TMT_VERSION,
            "X-TC-Region": REGION,
        },
    )
    # 强制直连：urllib 默认会读取 Windows 系统代理设置，若代理软件未运行
    # 会得到 "WinError 10061 目标计算机积极拒绝"。腾讯云 API 在国内直连
    # 即可，这里显式绕过代理。
    opener = urllib.request.build_opener(urllib.request.ProxyHandler({}))
    with opener.open(request, timeout=10) as response:
        result = json.loads(response.read().decode("utf-8"))
    response_payload = result.get("Response", {})
    if "Error" in response_payload:
        error = response_payload["Error"]
        raise RuntimeError(f"TMT error {error.get('Code')}: {error.get('Message')}")
    return response_payload.get("TargetText", "")


# ---------------------------------------------------------------------------
# DeepSeek (LLM) enrichment for the user-grown dictionary.
# ---------------------------------------------------------------------------

DEEPSEEK_HOST = "api.deepseek.com"
DEEPSEEK_MODEL = os.environ.get("DEEPSEEK_MODEL", "deepseek-v4-flash")
ENRICH_BATCH = 40  # 每次最多整理的候选词数

ENRICH_SYSTEM_PROMPT = (
    "You are a lexicographer enriching an English learner's dictionary. "
    "For each word: judge whether it is a real English word or term "
    "(isValid=false for obvious misspellings, gibberish, or proper nouns); "
    "give the IPA phonetic, a concise part-of-speech tag, a short English "
    "definition, and a concise Simplified Chinese definition. "
    "Respond with JSON only, in the exact schema: "
    '{"entries":[{"surface":str,"phonetic":str,"partOfSpeech":str,'
    '"definitionEnglish":str,"definitionChinese":str,"isValid":bool}]}'
)


def _enrich_words(api_key: str, words: list) -> list:
    payload = {
        "model": DEEPSEEK_MODEL,
        "messages": [
            {"role": "system", "content": ENRICH_SYSTEM_PROMPT},
            {
                "role": "user",
                "content": json.dumps({"words": words}, ensure_ascii=False),
            },
        ],
        "response_format": {"type": "json_object"},
        "temperature": 0.2,
    }
    request = urllib.request.Request(
        f"https://{DEEPSEEK_HOST}/chat/completions",
        data=json.dumps(payload, ensure_ascii=False).encode("utf-8"),
        method="POST",
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json; charset=utf-8",
        },
    )
    opener = urllib.request.build_opener(urllib.request.ProxyHandler({}))
    with opener.open(request, timeout=90) as response:
        result = json.loads(response.read().decode("utf-8"))
    content = result["choices"][0]["message"]["content"]
    parsed = json.loads(content)
    entries = parsed.get("entries")
    if not isinstance(entries, list):
        raise RuntimeError("enrich response has no entries list")
    cleaned = []
    for entry in entries:
        if not isinstance(entry, dict):
            continue
        surface = str(entry.get("surface", "")).strip()
        if not surface:
            continue
        cleaned.append(
            {
                "surface": surface,
                "phonetic": str(entry.get("phonetic", "")),
                "partOfSpeech": str(entry.get("partOfSpeech", "")),
                "definitionEnglish": str(entry.get("definitionEnglish", "")),
                "definitionChinese": str(entry.get("definitionChinese", "")),
                "isValid": bool(entry.get("isValid", True)),
            }
        )
    return cleaned


class Handler(BaseHTTPRequestHandler):
    server_version = "DiandujiGateway/1.0"

    def log_message(self, fmt, *args):  # 关闭默认访问日志（避免记录路径）
        return

    def do_OPTIONS(self):
        self.send_response(204)
        self._cors_headers()
        self.end_headers()

    def do_GET(self):
        started = time.time()
        if self.path == "/sync/get":
            self._handle_sync_get(started)
        else:
            self._reply(404, {"error": "not found"})

    def do_POST(self):
        started = time.time()
        try:
            length = int(self.headers.get("Content-Length", 0))
            if length > MAX_REQUEST_BYTES:
                self._reply(413, {"error": "request too large"})
                return
            raw = self.rfile.read(length)
            request = json.loads(raw.decode("utf-8"))
        except (ValueError, UnicodeDecodeError):
            self._reply(400, {"error": "malformed request"})
            return

        if self.path == "/translate":
            self._handle_translate(request, started)
        elif self.path == "/enrich":
            self._handle_enrich(request, started)
        elif self.path == "/auth/register":
            self._handle_register(request, started)
        elif self.path == "/auth/login":
            self._handle_login(request, started)
        elif self.path == "/sync/put":
            self._handle_sync_put(request, started)
        else:
            self._reply(404, {"error": "not found"})

    def _handle_enrich(self, request, started):
        api_key = os.environ.get("DEEPSEEK_API_KEY", "").strip()
        if not api_key:
            self._reply(503, {"error": "DEEPSEEK_API_KEY is not configured"})
            return
        words = request.get("words")
        if not isinstance(words, list) or not words:
            self._reply(400, {"error": "words must be a non-empty list"})
            return
        words = [str(word).strip() for word in words[:ENRICH_BATCH] if str(word).strip()]
        if not words:
            self._reply(400, {"error": "words must be a non-empty list"})
            return
        try:
            entries = _enrich_words(api_key, words)
        except Exception as error:  # noqa: BLE001
            LOG.warning("enrich failed in %.0fms: %s",
                        (time.time() - started) * 1000, error)
            self._reply(502, {"error": str(error)})
            return
        LOG.info("enrich ok in %.0fms (%d words -> %d entries)",
                 (time.time() - started) * 1000, len(words), len(entries))
        self._reply(
            200,
            {"entries": entries, "sourceId": DEEPSEEK_MODEL, "cacheVersion": "1"},
        )

    def _handle_translate(self, request, started):
        term = str(request.get("term", "")).strip()
        sentence = str(request.get("sentence", "")).strip()
        if not term and not sentence:
            self._reply(400, {"error": "term and sentence are both empty"})
            return

        try:
            term_translation = _translate_text(self.server.signer, term) if term else ""
            sentence_translation = (
                _translate_text(self.server.signer, sentence) if sentence else ""
            )
        except Exception as error:  # noqa: BLE001 —— 网关对上游错误统一返回 502
            LOG.warning("translate failed in %.0fms: %s",
                        (time.time() - started) * 1000, error)
            self._reply(502, {"error": str(error)})
            return

        result = {
            "termTranslation": term_translation,
            "sentenceTranslation": sentence_translation,
            "domainGloss": "",
            "examples": [],
            "sourceId": SOURCE_ID,
            "cacheVersion": CACHE_VERSION,
        }
        LOG.info("ok in %.0fms", (time.time() - started) * 1000)
        self._reply(200, result)

    def _handle_register(self, request, started):
        username = str(request.get("username", "")).strip()
        password = str(request.get("password", ""))
        if not username or len(password) < MIN_PASSWORD_LENGTH:
            self._reply(
                400,
                {"error": "username is required and password must be >= 6 chars"},
            )
            return
        if not _sync_secret():
            self._reply(503, {"error": "DIANDUJI_SYNC_SECRET is not configured"})
            return
        try:
            with _db_lock:
                connection = _db()
                try:
                    cursor = connection.execute(
                        "INSERT INTO users (username, password_hash, created_at) "
                        "VALUES (?, ?, ?)",
                        (username, _hash_password(password), int(time.time())),
                    )
                    user_id = cursor.lastrowid
                    connection.commit()
                except sqlite3.IntegrityError:
                    self._reply(409, {"error": "username already taken"})
                    return
                finally:
                    connection.close()
        except Exception as error:  # noqa: BLE001
            LOG.warning("register failed: %s", error)
            self._reply(500, {"error": "internal error"})
            return
        token = _issue_token(user_id)
        LOG.info(
            "register ok in %.0fms (user=%d)",
            (time.time() - started) * 1000,
            user_id,
        )
        self._reply(
            201, {"token": token, "user": {"id": user_id, "username": username}}
        )

    def _handle_login(self, request, started):
        username = str(request.get("username", "")).strip()
        password = str(request.get("password", ""))
        if not username or not password:
            self._reply(400, {"error": "username and password are required"})
            return
        if not _sync_secret():
            self._reply(503, {"error": "DIANDUJI_SYNC_SECRET is not configured"})
            return
        with _db_lock:
            connection = _db()
            try:
                row = connection.execute(
                    "SELECT id, username, password_hash FROM users "
                    "WHERE username = ?",
                    (username,),
                ).fetchone()
            finally:
                connection.close()
        if row is None or not _verify_password(password, row["password_hash"]):
            LOG.warning("login failed (user=%s)", username)
            self._reply(401, {"error": "invalid credentials"})
            return
        token = _issue_token(row["id"])
        LOG.info("login ok in %.0fms (user=%d)", (time.time() - started) * 1000, row["id"])
        self._reply(
            200, {"token": token, "user": {"id": row["id"], "username": row["username"]}}
        )

    def _authorized_user(self):
        header = self.headers.get("Authorization", "")
        if not header.startswith("Bearer "):
            return None
        return _verify_token(header[len("Bearer "):].strip())

    def _handle_sync_get(self, started):
        user_id = self._authorized_user()
        if user_id is None:
            self._reply(401, {"error": "invalid or expired token"})
            return
        with _db_lock:
            connection = _db()
            try:
                row = connection.execute(
                    "SELECT data_json, updated_at FROM sync_state WHERE user_id = ?",
                    (user_id,),
                ).fetchone()
            finally:
                connection.close()
        if row is None:
            self._reply(200, {"data": None, "updatedAt": 0})
            return
        self._reply(
            200,
            {"data": json.loads(row["data_json"]), "updatedAt": row["updated_at"]},
        )

    def _handle_sync_put(self, request, started):
        user_id = self._authorized_user()
        if user_id is None:
            self._reply(401, {"error": "invalid or expired token"})
            return
        data = request.get("data")
        updated_at = request.get("updatedAt")
        if (
            not isinstance(data, dict)
            or not isinstance(updated_at, int)
            or updated_at <= 0
        ):
            self._reply(
                400,
                {"error": "data must be an object and updatedAt a positive "
                 "epoch-millis integer"},
            )
            return
        with _db_lock:
            connection = _db()
            try:
                row = connection.execute(
                    "SELECT data_json, updated_at FROM sync_state WHERE user_id = ?",
                    (user_id,),
                ).fetchone()
                if row is not None and row["updated_at"] >= updated_at:
                    self._reply(
                        200,
                        {
                            "data": json.loads(row["data_json"]),
                            "updatedAt": row["updated_at"],
                            "accepted": False,
                        },
                    )
                    return
                connection.execute(
                    "INSERT INTO sync_state (user_id, data_json, updated_at) "
                    "VALUES (?, ?, ?) "
                    "ON CONFLICT(user_id) DO UPDATE SET "
                    "data_json = excluded.data_json, "
                    "updated_at = excluded.updated_at",
                    (
                        user_id,
                        json.dumps(data, ensure_ascii=False),
                        updated_at,
                    ),
                )
                connection.commit()
            finally:
                connection.close()
        LOG.info(
            "sync put ok in %.0fms (user=%d)",
            (time.time() - started) * 1000,
            user_id,
        )
        self._reply(200, {"data": data, "updatedAt": updated_at, "accepted": True})

    def _reply(self, status: int, body: dict):
        data = json.dumps(body, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(data)))
        self._cors_headers()
        self.end_headers()
        self.wfile.write(data)

    def _cors_headers(self):
        # Web 版（独立项目）未来可能跨域调用同一网关；native 客户端无影响。
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header(
            "Access-Control-Allow-Headers", "Authorization, Content-Type"
        )


# ---------------------------------------------------------------------------
# Account & cloud sync (v1.1 login) — standard library only.
#
# Storage: SQLite at DIANDUJI_SYNC_DB (default: dianduji-sync.db next to this
# file, git-ignored). Passwords: hashlib.scrypt. Tokens: HMAC-SHA256 signed,
# 7-day expiry, key from DIANDUJI_SYNC_DB / keys.env. Sync payloads are
# opaque JSON objects; conflicts resolve last-write-wins by updatedAt
# (epoch milliseconds). See sync-api.md for the full contract.
# ---------------------------------------------------------------------------

MAX_REQUEST_BYTES = 10 * 1024 * 1024
SYNC_DB_PATH = os.environ.get(
    "DIANDUJI_SYNC_DB",
    os.path.join(os.path.dirname(os.path.abspath(__file__)), "dianduji-sync.db"),
)
TOKEN_TTL_SECONDS = 7 * 24 * 3600
SCRYPT_N = 2 ** 14
SCRYPT_R = 8
SCRYPT_P = 1
MIN_PASSWORD_LENGTH = 6

_db_lock = threading.Lock()


def _db() -> sqlite3.Connection:
    connection = sqlite3.connect(SYNC_DB_PATH)
    connection.row_factory = sqlite3.Row
    return connection


def init_sync_db():
    with _db_lock:
        connection = _db()
        try:
            connection.execute(
                "CREATE TABLE IF NOT EXISTS users ("
                "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                "username TEXT NOT NULL UNIQUE, "
                "password_hash TEXT NOT NULL, "
                "created_at INTEGER NOT NULL)"
            )
            connection.execute(
                "CREATE TABLE IF NOT EXISTS sync_state ("
                "user_id INTEGER PRIMARY KEY, "
                "data_json TEXT NOT NULL, "
                "updated_at INTEGER NOT NULL)"
            )
            connection.commit()
        finally:
            connection.close()


def _sync_secret() -> str:
    return os.environ.get("DIANDUJI_SYNC_SECRET", "").strip()


def _hash_password(password: str) -> str:
    salt = os.urandom(16)
    digest = hashlib.scrypt(
        password.encode("utf-8"),
        salt=salt,
        n=SCRYPT_N,
        r=SCRYPT_R,
        p=SCRYPT_P,
    )
    return "scrypt${}${}${}${}${}".format(
        SCRYPT_N, SCRYPT_R, SCRYPT_P, salt.hex(), digest.hex()
    )


def _verify_password(password: str, stored: str) -> bool:
    try:
        _, n, r, p, salt_hex, hash_hex = stored.split("$")
        digest = hashlib.scrypt(
            password.encode("utf-8"),
            salt=bytes.fromhex(salt_hex),
            n=int(n),
            r=int(r),
            p=int(p),
        )
        return hmac.compare_digest(digest.hex(), hash_hex)
    except (ValueError, TypeError):
        return False


def _issue_token(user_id: int) -> str:
    payload = {"uid": user_id, "exp": int(time.time()) + TOKEN_TTL_SECONDS}
    encoded = base64.urlsafe_b64encode(
        json.dumps(payload, separators=(",", ":")).encode("utf-8")
    ).rstrip(b"=").decode("ascii")
    signature = hmac.new(
        _sync_secret().encode("utf-8"), encoded.encode("ascii"), hashlib.sha256
    ).digest()
    return encoded + "." + base64.urlsafe_b64encode(signature).rstrip(b"=").decode(
        "ascii"
    )


def _verify_token(token: str):
    """Returns the user id, or None for invalid/expired tokens."""
    try:
        encoded, signature = token.split(".")
        expected = hmac.new(
            _sync_secret().encode("utf-8"), encoded.encode("ascii"), hashlib.sha256
        ).digest()
        provided = base64.urlsafe_b64decode(signature + "=" * (-len(signature) % 4))
        if not hmac.compare_digest(provided, expected):
            return None
        payload = json.loads(
            base64.urlsafe_b64decode(encoded + "=" * (-len(encoded) % 4)).decode(
                "utf-8"
            )
        )
        if payload.get("exp", 0) < time.time():
            return None
        return int(payload["uid"])
    except Exception:  # noqa: BLE001 —— 任何解析失败都视为无效令牌
        return None


def main():
    init_sync_db()
    secret_id = os.environ.get("TENCENT_SECRET_ID", "")
    secret_key = os.environ.get("TENCENT_SECRET_KEY", "")
    if not secret_id or not secret_key:
        raise SystemExit(
            "Missing TENCENT_SECRET_ID / TENCENT_SECRET_KEY environment variables."
        )
    port = int(os.environ.get("PORT", "8080"))
    server = ThreadingHTTPServer(("0.0.0.0", port), Handler)
    server.signer = _Tc3Signer(secret_id, secret_key)
    LOG.info("gateway listening on :%d (region=%s)", port, REGION)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    main()
