# 典读鸡 · 账号与云同步 API 契约

版本：1.0（2026-08-17）
实现：`gateway_tencent.py`（`/auth/*`、`/sync/*`，标准库，SQLite 存储）
测试：`tests/test_sync_api.py`（`python -m unittest discover -s tests -v`）

移动端 v1.1「用户登录 / 云同步」服务端契约。客户端零密钥：只需
`DIANDUJI_TRANSLATE_BASE_URL`（构建期注入），登录后持有服务端签发的令牌。

## 认证

所有 `/sync/*` 请求需要请求头：`Authorization: Bearer <token>`。
令牌：HMAC-SHA256 签名（密钥 `DIANDUJI_SYNC_SECRET`），有效期 **7 天**，
过期后返回 `401`，客户端应引导重新登录。

## 端点

### POST /auth/register

请求：`{"username": "string", "password": "string(>=6)"}`

| 状态码 | 含义 |
| --- | --- |
| 201 | 注册成功：`{"token": "...", "user": {"id": 1, "username": "alice"}}` |
| 400 | 参数缺失 / 密码过短 |
| 409 | 用户名已存在 |
| 503 | `DIANDUJI_SYNC_SECRET` 未配置 |

### POST /auth/login

请求：`{"username": "string", "password": "string"}`

| 状态码 | 含义 |
| --- | --- |
| 200 | 成功：`{"token": "...", "user": {"id": 1, "username": "alice"}}` |
| 400 | 参数缺失 |
| 401 | 用户名或密码错误 |
| 503 | 同步未配置 |

### GET /sync/get

响应 200：`{"data": <object|null>, "updatedAt": <epoch 毫秒 int>}`
`data` 为 `null` 表示该用户尚无云端数据。

### POST /sync/put

请求：`{"data": <object>, "updatedAt": <epoch 毫秒 int>}`

冲突策略：**last-write-wins**（按 `updatedAt`，仅接受更新的快照）。

| 状态码 | 含义 |
| --- | --- |
| 200 | `{"data": <权威数据>, "updatedAt": <权威时间>, "accepted": true\|false}`；`accepted=false` 表示提交被拒（云端更新），`data` 为云端权威快照，客户端应丢弃本地并采用 |
| 400 | `data` 非对象 / `updatedAt` 非法 |
| 401 | 令牌缺失 / 无效 / 过期 |

## 数据模型

`data` 是不透明的 JSON 对象，由客户端自行组织（建议版本化，例如
`{"version": 1, "vocabulary": [...], "phrases": [...], "progress": {...},
"settings": {...}}`），服务端不做结构校验，仅整体存取。

两个例外字段：

- `candidates`（sync/put 时服务端提取）：客户端上传的待整理候选词
  （字符串数组），网关写入云端候选池（按词去重），供 Web 管理后台
  查看与 LLM 整理。
- `confirmedCandidates`（sync/get 时服务端注入）：管理后台确认入库的词
  （含音标/词性/中英释义），客户端应写入本地用户词典。

## 词库管理端点（管理员，Bearer 鉴权）

| 端点 | 说明 |
| --- | --- |
| `GET /candidates?status=pending\|confirmed\|dropped\|all` | 候选词列表（时间倒序，上限 500） |
| `POST /candidates/enrich` `{"surfaces": [可选]}` | 对 pending 词批量 LLM 整理（DeepSeek），写回音标/词性/中英释义；无效词删除 |
| `POST /candidates/resolve` `{"surface": "...", "action": "confirm"\|"drop"}` | 确认入库 / 丢弃（确认后随 `confirmedCandidates` 下发到所有客户端） |

管理后台页面：`gateway-reference/admin.html`（单文件，随网关部署；登录后
可查看/整理/确认/丢弃候选词）。

## 安全说明

- 密码：`hashlib.scrypt`（n=2^14, r=8, p=1）加盐哈希存储，绝不落明文；
- 令牌：HMAC-SHA256 签名 + 过期时间，篡改即 401；
- 密钥只存于服务器环境变量 / `keys.env`（gitignored）；
- 生产必须 HTTPS（`deploy.sh` 的 nginx 已配置）；
- 登录接口建议在反代层加 IP 限流（v1 未内置）。

## 客户端接入要点（Dart）

1. 注册/登录成功后用 `flutter_secure_storage` 持久化令牌；
2. 离线改动记录本地 `updatedAt`（`DateTime.now().millisecondsSinceEpoch`）；
3. 联网时 `GET /sync/get` 拉云端 → 与本地合并 → `POST /sync/put`；
   `accepted=false` 时采用云端权威快照并重新合并；
4. `401` 统一走重新登录流程。
