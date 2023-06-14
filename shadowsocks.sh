#!/bin/bash
if (($EUID !=0)); then
     echo Script must be run by root.
     exit
fi
echo installing packages
apt-get install -y shadowsocks-libev simple-obfs openssl curl
ipaddr=$(curl ifconfig.me/ip)
echo "Enter password on shadowsocks or just press enter to generate random password: "
read p
if [ -z "$p" ];then
   p=$(openssl rand -base64 8)
fi
echo ""
echo "server: "$ipaddr
echo 'port": 80'
echo 'method: chacha20-ietf-poly1305'
echo "Password: " $p
echo 'Plugin: simple-obfs'
echo 'Obfuscation method: http'
echo 'Obfuscation host: '$ipaddr
echo ""
echo "{" > /etc/shadowsocks-libev/config.json
echo '' >> /etc/shadowsocks-libev/config.json
echo '"server":"'$ipaddr'",' >> /etc/shadowsocks-libev/config.json
echo '' >> /etc/shadowsocks-libev/config.json
echo '"mode":"tcp_and_udp",' >> /etc/shadowsocks-libev/config.json
echo '' >> /etc/shadowsocks-libev/config.json
echo '"server_port":80,' >> /etc/shadowsocks-libev/config.json
echo '' >> /etc/shadowsocks-libev/config.json
echo '"password":"'$p'",' >> /etc/shadowsocks-libev/config.json
echo '' >> /etc/shadowsocks-libev/config.json
echo '"timeout":86400,' >> /etc/shadowsocks-libev/config.json
echo '' >> /etc/shadowsocks-libev/config.json
echo '"method":"chacha20-ietf-poly1305",' >> /etc/shadowsocks-libev/config.json
echo '' >> /etc/shadowsocks-libev/config.json
echo '"plugin":"obfs-server",' >> /etc/shadowsocks-libev/config.json
echo '' >> /etc/shadowsocks-libev/config.json
echo '"plugin_opts":"obfs=http;obfs-host='$ipaddr'"' >> /etc/shadowsocks-libev/config.json
echo '' >>/etc/shadowsocks-libev/config.json
echo "}" >> /etc/shadowsocks-libev/config.json

echo "{" > clientconf.json
echo '' >> clientconf.json
echo '"server":"'$ipaddr'",' >> clientconf.json
echo '' >> clientconf.json
echo '"mode":"tcp_and_udp",' >> clientconf.json
echo '' >> clientconf.json
echo '"server_port":80,' >> clientconf.json
echo '' >> clientconf.json
echo '"local_port":1080,' >> clientconf.json
echo '' >> clientconf.json
echo '"password":"'$p'",' >> clientconf.json
echo '' >> clientconf.json
echo '"timeout":86400,' >> clientconf.json
echo '' >> clientconf.json
echo '"method":"chacha20-ietf-poly1305",' >> clientconf.json
echo '' >> clientconf.json
echo '"plugin":"obfs-local",' >> clientconf.json
echo '' >> clientconf.json
echo '"plugin_opts":"obfs=http;obfs-host='$ipaddr'"' >> clientconf.json
echo '' >>clientconf.json
echo "}" >> clientconf.json

echo '[Unit]' > /etc/systemd/system/shadowsocks.service
echo 'Description=Shadowsocks' >> /etc/systemd/system/shadowsocks.service
echo 'After=network.target' >> /etc/systemd/system/shadowsocks.service
echo '[Service]' >> /etc/systemd/system/shadowsocks.service
echo 'ExecStart=/usr/bin/ss-server -c /etc/shadowsocks-libev/config.json' >> /etc/systemd/system/shadowsocks.service
echo 'Restart=on-failure' >> /etc/systemd/system/shadowsocks.service
echo '[Install]' >> /etc/systemd/system/shadowsocks.service
echo 'WantedBy=multi-user.target' >> /etc/systemd/system/shadowsocks.service

systemctl daemon-reload
systemctl start shadowsocks
systemctl enable shadowsocks
echo "Client config file name is clientconf.json"
echo "You can see content of this file below:"
echo ""
cat clientconf.json
