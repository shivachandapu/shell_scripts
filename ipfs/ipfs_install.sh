#!/bin/bash

# IPFS Kubo_go
KUBO_GO="kubo_v0.22.0_linux-amd64.tar.gz"
VOID="/dev/null"
GATEWAY="/ip4/0.0.0.0/tcp/8080"
API="/ip4/0.0.0.0/tcp/5001"
IPFS_BOOTSTRAP_ADDRESS="/ip4/10.110.21.55/tcp/4001/p2p/12D3KooWNKKPbpknLiKVubC6VNE8hiDMfLrivyj6Ehu3FDh83FHc"

# path of the service file with the file name
ipfs_service_path="/usr/lib/systemd/system/ipfsd.service"

# Extract the kubo-go file
tar -xvzf $KUBO_GO
echo "Extracted Kubo-go files."
# Enter kubo directory
cd kubo

# install kubo-go
sudo bash install.sh
echo "Installed kubo-go successfully!"

# show ipfs version
ipfs --version  

# initiate ipfs
ipfs init

# configure the ipfs daemon service file
echo """
[Unit]
Description=ipfs daemon

[Service]
ExecStart=/usr/local/bin/ipfs daemon
ExecReload=/usr/local/bin/ipfs daemon
Restart=on-failure
User=$USER
Group=$USER

[Install]
WantedBy=multi-user.target
""" | sudo tee $ipfs_service_path > $VOID

echo "ipfsd service file is configured."

# restart the ipfs daemon
#systemctl restart ipfsd
#echo "Started ipfs daemon."

# remove all the bootstrap nodes
ipfs bootstrap rm --all
echo "Removed all bootstrap nodes."

export LIBP2P_FORCE_PNET=1

# setup the ipfs Gateway and API

ipfs config Addresses.Gateway $GATEWAY
ipfs config Addresses.API $API

# remove all the bootstrap nodes
ipfs bootstrap rm --all
echo "Removed all bootstrap nodes again."

# Add bootstrap node
ipfs bootstrap add $IPFS_BOOTSTRAP_ADDRESS

systemctl restart ipfsd

echo """
---------Installation is done!---------

IPFS daemon is running...
 	Try:
	 - ipfs swarm peers		: To show all the swarm peers in the network.
	 - systemctl restart ipfsd 	: To restart the ipfs daemon.
	 - systemctl stop ipfsd 	: To stop the ipfs daemon. 
"""
