#!/bin/bash
if (($EUID !=0)); then
     echo Script must be run by root.
     exit
fi

kv=$(uname -r)
IFS='.' read -r -a version_parts <<< "$kv"
echo "Version of your Linux kernel is "$kv
if [[ ${version_parts[0]} -lt 5 ]]; then
  echo "Your kernel is less then 5 version. Please upgrade your kernel on 5 version or higher."
  exit
else
  echo "Your kernel have actual for wireguard version."
fi

echo installing packages
apt-get install -y docker docker-compose curl lsof
ipaddr=$(curl ifconfig.me/ip)

port_status=$(sudo lsof -i :443)

# Проверяем вывод команды lsof
if [ -z "$port_status" ]; then
  echo "Port 443 is free."
else
  echo "Port 443 is busy. You may deploy Wireguard VPN by script wireguard.sh"
  exit
fi



docker run -d  --name=wireguard443 --cap-add=NET_ADMIN --cap-add=SYS_MODULE -e PUID=1000 -e PGID=1000 -e TZ=Europe/London -e SERVERURL=$ipaddr -e SERVERPORT=51820 -e PEERS=115 -e PEERDNS=auto -e INTERNAL_SUBNET=10.10.10.0 -e ALLOWEDIPS=0.0.0.0/0 -e LOG_CONFS=true -p 443:51820/udp -v /path/to/appdata/config:/config -v /lib/modules:/lib/modules --sysctl="net.ipv4.conf.all.src_valid_mark=1" --restart always linuxserver/wireguard
mkdir wg443_peers
for i in $(seq 1 115);
do
  docker exec wireguard443 cat /config/peer$i/peer$i.conf > wg443_peers/peer$i.conf
  sed -i "s/:51820/:443/gi" wg443_peers/peer$i.conf
done
echo "Done. Your peer's configuration files is in directory wg443_peers."
