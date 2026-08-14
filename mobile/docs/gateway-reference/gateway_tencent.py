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

import hashlib
import hmac
import json
import logging
import os
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
    with urllib.request.urlopen(request, timeout=10) as response:
        result = json.loads(response.read().decode("utf-8"))
    response_payload = result.get("Response", {})
    if "Error" in response_payload:
        error = response_payload["Error"]
        raise RuntimeError(f"TMT error {error.get('Code')}: {error.get('Message')}")
    return response_payload.get("TargetText", "")


class Handler(BaseHTTPRequestHandler):
    server_version = "DiandujiGateway/1.0"

    def log_message(self, fmt, *args):  # 关闭默认访问日志（避免记录路径）
        return

    def do_POST(self):
        started = time.time()
        try:
            length = int(self.headers.get("Content-Length", 0))
            raw = self.rfile.read(length)
            request = json.loads(raw.decode("utf-8"))
        except (ValueError, UnicodeDecodeError):
            self._reply(400, {"error": "malformed request"})
            return

        if self.path != "/translate":
            self._reply(404, {"error": "not found"})
            return

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
        except RuntimeError as error:
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

    def _reply(self, status: int, body: dict):
        data = json.dumps(body, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)


def main():
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
