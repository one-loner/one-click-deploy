#!/bin/bash
if (($EUID !=0)); then
     echo Script must be run by root.
     exit
fi
echo installing packages
apt-get install -y docker docker-compose curl
docker run --name ipsec-vpn-server --env-file ./vpn.env --restart=always -v ikev2-vpn-data:/etc/ipsec.d -v /lib/modules:/lib/modules:ro -p 500:500/udp -p 4500:4500/udp -d --privileged hwdsl2/ipsec-vpn-server
docker logs ipsec-vpn-server
echo 'Done. You can find login deitals upper.'
