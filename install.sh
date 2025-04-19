sudo apt update && sudo apt upgrade -y
sudo apt install -y iptables python3-pip python3-venv pipx dnsmasq
python3 -m pipx ensurepath
pipx install mitmproxy
