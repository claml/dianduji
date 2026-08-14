#!/usr/bin/env bash
# 点读机网关正式部署脚本（Ubuntu/Debian 服务器）
#
# 用法：
#   1. 把本目录（gateway-reference/）上传到服务器，例如 /opt/dianduji-gateway/
#   2. 创建 /opt/dianduji-gateway/keys.env（参照 keys.env.example）
#   3. 以 root 运行：bash deploy.sh
#
# 部署内容：
#   - 安装 python3（若缺失）
#   - 创建 systemd 服务 dianduji-gateway（开机自启 + 崩溃重启）
#   - 说明 HTTPS 接入（nginx 反代 + Let's Encrypt）
set -euo pipefail

APP_DIR="$(cd "$(dirname "$0")" && pwd)"
SERVICE_NAME="dianduji-gateway"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

if ! command -v python3 >/dev/null 2>&1; then
  echo ">> 安装 python3"
  apt-get update -y && apt-get install -y python3
fi

if [ ! -f "${APP_DIR}/keys.env" ]; then
  echo "!! 缺少 ${APP_DIR}/keys.env（请参照 keys.env.example 填写密钥）"
  exit 1
fi

cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=Dianduji translation gateway (Tencent TMT + DeepSeek)
After=network.target

[Service]
Type=simple
WorkingDirectory=${APP_DIR}
EnvironmentFile=${APP_DIR}/keys.env
ExecStart=/usr/bin/python3 ${APP_DIR}/gateway_tencent.py
Restart=on-failure
RestartSec=3
User=www-data
NoNewPrivileges=true
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable "${SERVICE_NAME}"
systemctl restart "${SERVICE_NAME}"
sleep 2

if systemctl is-active --quiet "${SERVICE_NAME}"; then
  echo ">> 服务已启动：systemctl status ${SERVICE_NAME}"
  echo ">> 本地验证："
  echo "   curl -X POST http://127.0.0.1:8080/translate \\"
  echo "     -H 'Content-Type: application/json' \\"
  echo "     -d '{\"term\":\"random forest\",\"sentence\":\"A random forest classifies.\"}'"
else
  echo "!! 服务启动失败，查看日志：journalctl -u ${SERVICE_NAME} -n 50"
  exit 1
fi

cat <<'EOF'

HTTPS 接入（推荐，生产必需）：
  1. 安装 nginx + certbot：
     apt-get install -y nginx certbot python3-certbot-nginx
  2. 配置反代（/etc/nginx/sites-available/dianduji-gateway）：
     server {
       listen 80;
       server_name translate.example.com;
       location / {
         proxy_pass http://127.0.0.1:8080;
         proxy_read_timeout 120s;
         proxy_set_header Host $host;
       }
     }
     ln -s /etc/nginx/sites-available/dianduji-gateway /etc/nginx/sites-enabled/
     nginx -t && systemctl reload nginx
  3. 签发证书：certbot --nginx -d translate.example.com
  4. 可选限流（nginx 中）：
     limit_req_zone $binary_remote_addr zone=dianduji:10m rate=10r/s;
     location / { limit_req zone=dianduji burst=20 nodelay; ... }
  5. 客户端构建时指向 https://translate.example.com/translate
EOF
