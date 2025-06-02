#!/bin/bash

# 检查参数
if [ $# -ne 2 ]; then
  echo "用法: $0 <ID> <SECRET>"
  echo "示例: $0 4a1pthbftlgm5is f76cyw6c9nc0kt6sp5ffcowlkwowo54h2bl6kglmap59q6h4"
  exit 1
fi

NEWT_ID="$1"
NEWT_SECRET="$2"
NEWT_BIN="/usr/local/bin/newt"
SERVICE_FILE="/etc/systemd/system/newt.service"

# 下载并安装 newt
echo "[+] 正在下载 newt..."
wget -O "$NEWT_BIN" "https://github.com/fosrl/newt/releases/download/1.1.3/newt_linux_amd64"
chmod +x "$NEWT_BIN"
echo "[+] newt 下载并设置执行权限完成"

# 写入 systemd 服务文件
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

# 启动服务
echo "[+] 重新加载 systemd..."
systemctl daemon-reexec
systemctl daemon-reload

echo "[+] 启用并启动 newt 服务..."
systemctl enable newt
systemctl start newt

# 显示服务状态
echo "[+] 服务状态："
systemctl status newt --no-pager
