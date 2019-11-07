#!/bin/bash
#
# Shadowsocks Auto Install For CentOS
# By Huson 2018-07-20
#
clear
# Make Sure Run As root
if [[ $EUID -ne 0 ]]; then
	echo "Error: Must Be Run As root!" 1>&2
	exit 1
fi

# Set Time Zone
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# Install pip And Update
yum install python-pip
pip install --upgrade pip
# Install Shadowsocks
#pip install shadowsocks
pip install shadowsocks -i https://pypi.python.org/simple

# Create Config File
touch /etc/shadowsocks.json
cat >/etc/shadowsocks.json<<EOF
{
	"server":"0.0.0.0",
	"port_password":{
		"xxxxx":"xxxxxxxx",
		"xxxxx":"xxxxxxxx",
		"xxxxx":"xxxxxxxx",
		"xxxxx":"xxxxxxxx"
	},
	"timeout":"600",
	"method":"aes-256-cfb",
	"mode":"tcp_and_udp",
	"fast_open":true
}
EOF
# Create Server File
touch /etc/systemd/system/shadowsocks.service
cat >/etc/systemd/system/shadowsocks.service<<EOF
[Unit]
Description=Shadowsocks

[Service]
TimeoutStartSec=0
ExecStart=/usr/bin/ssserver -c /etc/shadowsocks.json

[Install]
WantedBy=multi-user.target
EOF

# Open Tcp_fastopen
echo 3 > /proc/sys/net/ipv4/tcp_fastopen
echo "net.ipv4.tcp_fastopen = 3" >>/etc/sysctl.conf

# Enable And Start Shadowsocks Server
systemctl enable shadowsocks
systemctl start shadowsocks

# Open Port Form Firewall
#firewall-cmd --permanent --add-port=16333-16336/tcp
# Restart Firewall
#firewall-cmd --reload


###################################
# Server Command
# systemctl enable shadowsocks
# systemctl disable shadowsocks
# systemctl start shadowsocks
# systemctl stop shadowsocks
# systemctl status shadowsocks -l

# Program Command
# ssserver -c /etc/shadowsocks.json -d start
# ssserver -c /etc/shadowsocks.json -d stop
# ssserver -c /etc/shadowsocks.json -d restart

