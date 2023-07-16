#!/bin/bash
if (($EUID !=0)); then
     echo Script must be run by root.
     exit
fi
mkdir wg443_peers
for i in $(seq 1 115);
do
  docker cp wireguard443:/config/peer$i/peer$i.conf wg_peers/peer$i.conf
done
tar cvf wg443_peers.tar wg443_peers/
echo "Done. Your peer's configuration files is in directory wg443_peers and in archive wg443_peers.tar."
