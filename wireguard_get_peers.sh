#!/bin/bash
if (($EUID !=0)); then
     echo Script must be run by root.
     exit
fi
mkdir wg_peers
for i in $(seq 1 115);
do
  docker cp wireguard:/config/peer$i/peer$i.conf wg_peers/peer$i.conf
done
tar cvf wg_peers.tar wg_peers/
echo "Done. Your peer's configuration files is in directory wg_peers and in archive wg_peers.tar."
