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
apt-get install -y docker docker-compose curl
ipaddr=$(curl ifconfig.me/ip)
docker run -d  --name=wireguard --cap-add=NET_ADMIN --cap-add=SYS_MODULE -e PUID=1000 -e PGID=1000 -e TZ=Europe/London -e SERVERURL=$ipaddr -e SERVERPORT=51820 -e PEERS=115 -e PEERDNS=auto -e INTERNAL_SUBNET=10.10.10.0 -e ALLOWEDIPS=0.0.0.0/0 -e LOG_CONFS=true -p 51820:51820/udp -v /path/to/appdata/config:/config -v /lib/modules:/lib/modules --sysctl="net.ipv4.conf.all.src_valid_mark=1" --restart always linuxserver/wireguard
mkdir wg_peers
for i in $(seq 1 115);
do
  docker cp wireguard:/config/peer$i/peer$i.conf wg_peers/peer$i.conf
done
tar cvf wg_peers.tar wg_peers/
echo "Done. Your peer's configuration files is in directory wg_peers and in archive wg_peers.tar."
echo "if extractoin of peers don't works, laucnch script wireguard_get_peers.sh"
