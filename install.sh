#!/bin/bash

sudo apt update && sudo apt upgrade -y
sudo apt install -y iptables python3-pip python3-venv dnsmasq wget git

curl -LsSf https://astral.sh/uv/install.sh | sh
curl -LsSf https://get.docker.com | sudo sh

git clone https://github.com/meeplabsdev/mitmproxy.git
cd mitmproxy

uv run mitmproxy --version
uv build
cp dist/*.whl docker/
sudo docker build docker/ -t mitm

cd ~
wget https://raw.githubusercontent.com/meeplabsdev/wifi-pwn/refs/heads/main/mitmproxy.sh
wget https://raw.githubusercontent.com/meeplabsdev/wifi-pwn/refs/heads/main/share-wifi.sh
