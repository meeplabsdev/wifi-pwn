#!/bin/bash

sudo apt update && sudo apt upgrade -y
sudo apt install -y iptables python3-pip python3-venv dnsmasq wget git aircrack-ng tcpdump tshark dnsmasq hostapd raspberrypi-kernel-headers git libgmp3-dev gawk qpdf bison flex make
curl -LsSf https://astral.sh/uv/install.sh | sh

if ! command -v docker >/dev/null 2>&1; then
  curl -LsSf https://get.docker.com | sudo sh
fi

git clone https://github.com/meeplabsdev/mitmproxy.git
cd mitmproxy

uv run mitmproxy --version
uv build
cp dist/*.whl docker/
sudo docker build docker/ -t mitm

cd ..

SCRIPT_REL_PATH="./scripts/share-wifi.sh"
SCRIPT_ABS_PATH=$(realpath "$SCRIPT_REL_PATH")
CURRENT_USER=$(whoami)

SERVICE_NAME="share_wifi.service"
SERVICE_PATH="/etc/systemd/system/$SERVICE_NAME"

sudo bash -c "cat > $SERVICE_PATH" <<EOF
[Unit]
Description=Delayed WiFi Sharing Script
After=network.target

[Service]
ExecStartPre=/bin/sleep 15
ExecStart=$SCRIPT_ABS_PATH
User=$CURRENT_USER
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sudo chmod +x "$SCRIPT_ABS_PATH"
sudo systemctl daemon-reload
sudo systemctl enable $SERVICE_NAME
sudo systemctl start $SERVICE_NAME
