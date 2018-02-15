#! /bin/bash

geth --datadir node1/ --syncmode 'full' --port ... --rpc --rpcaddr '...' --rpcport ... --rpcapi 'personal,db,eth,net,web3,txpool,miner' --bootnodes '...' --networkid .... --gasprice '..' --unlock '.....' --password '......'  --mine
