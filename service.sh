#!/bin/bash

# 默认值
NEWT_ID=""
NEWT_SECRET=""

# 解析参数
while [[ $# -gt 0 ]]; do
  case "$1" in
    --id)
      NEWT_ID="$2"
      shift 2
      ;;
    --secret)
      NEWT_SECRET="$2"
      shift 2
      ;;
    *)
      echo "未知参数: $1"
      exit 1
      ;;
  esac
done

# 校验参数
if [[ -z "$NEWT_ID" || -z "$NEWT_SECRET" ]]; then
  echo "用法: $0 --id <ID> --secret <SECRET>"
  exit 1
fi

NEWT_BIN="/usr/local/bin/newt"
SERVICE_FILE="/etc/systemd/system/newt.service"

echo "[+] 正在下载 newt..."
wget -O "$NEWT_BIN" "https://github.com/fosrl/newt/releases/download/1.1.3/newt_linux_amd64"
chmod +x "$NEWT_BIN"

echo "[+] 正在创建 Systemd 服务..."
cat <<EOF > "$SERVICE_FILE"
[Unit]
Description=Newt Client Service
After=network.target

[Service]
ExecStart=$NEWT_BIN --id $NEWT_ID --secret $NEWT_SECRET --endpoint https://sso.linas.pro
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

echo "[+] 重新加载 systemd..."
systemctl daemon-reexec
systemctl daemon-reload

echo "[+] 启用并启动 newt 服务..."
systemctl enable newt
systemctl start newt

echo "[+] 服务状态："
systemctl status newt --no-pager
