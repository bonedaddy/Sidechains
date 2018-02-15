#! /bin/bash
# quickly generate genesis file
puppeth
# rename genesis file
mv *.json genesis.json
# get list of node names
odeDirs=$(find . -type d -name "node*" -maxdepth 1)
# init genesis file for each node
for i in $(echo $nodeDirs); do 
	nodeName=$(echo "$i" | awk -F '/' '{print $2}')
	geth --datadir "$nodeName/" init genesis.json
done
# initialize a boot node
bootnode -genkey boot.key
