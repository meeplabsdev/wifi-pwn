#!/bin/bash

sudo sh -c "echo 'deb http://http.kali.org/kali kali-rolling main non-free contrib' > /etc/apt/sources.list.d/kali.list"
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ED65462EC8D5E4C5

sudo apt update && sudo apt upgrade -y
sudo apt install -y iptables python3-pip python3-venv dnsmasq wget git aircrack-ng tcpdump tshark dnsmasq hostapd raspberrypi-kernel-headers git libgmp3-dev gawk qpdf bison flex make mdk3 macchanger pwgen

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
