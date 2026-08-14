# 腾讯云后端网关部署指南

`gateway_tencent.py` 是点读机在线翻译网关的参考实现，后端使用
腾讯云机器翻译（TMT）`TextTranslate`。零第三方依赖（Python 3.8+ 标准库）。

## 第一步：申请腾讯云翻译 API

1. 注册腾讯云账号并完成**实名认证**：
   <https://cloud.tencent.com/register>（个人实名即可）。
2. 开通**机器翻译**服务（新用户通常赠送免费额度）：
   <https://console.cloud.tencent.com/tmt> 按页面提示开通。
3. 创建 API 密钥（SecretId / SecretKey）：
   <https://console.cloud.tencent.com/cam/capi> → 「新建密钥」。
   - SecretId：形如 `AKIDxxxxxxxxxxxxxxxx`
   - SecretKey：形如 `xxxxxxxxxxxxxxxxxxxx`
   - **妥善保管，不要提交到代码仓库或发给任何人**；密钥只填在服务器环境变量里。
4. （可选）在机器翻译控制台查看免费额度与用量。

## 第二步：部署网关

```bash
# 在任意 Linux 服务器（国内云主机最佳）上：
export TENCENT_SECRET_ID=AKIDxxxxxxxxxxxxxxxx
export TENCENT_SECRET_KEY=xxxxxxxxxxxxxxxxxxxx
export TENCENT_REGION=ap-guangzhou        # 可选
export PORT=8080                          # 可选
python3 gateway_tencent.py
```

验证：

```bash
curl -X POST http://127.0.0.1:8080/translate \
  -H 'Content-Type: application/json' \
  -d '{"term":"random forest","sentence":"A random forest classifies samples."}'
# 期望响应包含 termTranslation / sentenceTranslation / sourceId=tencent-tmt
```

生产建议：

- 用 systemd / docker / nginx 托管；HTTPS 用 nginx + Let's Encrypt 终止；
- 防火墙只放行 8080（或经 nginx 反代的 443）；
- 可在网关前加简单限流（如每 IP 每分钟 60 次）防止滥用；
- 日志已脱敏（只记耗时与状态码），无需额外处理。

## 第三步：客户端接入

构建点读机时注入网关地址与密钥标识（密钥仍在服务器，客户端只有地址）：

```powershell
& $flutter build apk --debug `
  --dart-define=DIANDUJI_TRANSLATE_BASE_URL=http://<服务器IP>:8080/translate
```

> 客户端不传 API 密钥。`DIANDUJI_TRANSLATE_API_KEY` 为可选字段，本参考实现不使用。

## 注意事项

- 点读机每次只发送「所点术语 + 所在单个句子（≤1000 字符）」；
  腾讯云按源语言字符计费，点读机月用量通常远小于免费额度。
- 本实现把 `term` 与 `sentence` 分别调一次 `TextTranslate`；
  `domainGloss` 与 `examples` 返回空（腾讯文本翻译不提供例句，
  客户端会自动隐藏空白区块）。
- 如后续切换后端（百度/有道/DeepL），只需替换 `_translate_text` 实现，
  客户端与契约不变。
