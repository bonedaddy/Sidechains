#! /bin/bash
echo "enter swarm address"
read -r BZZ
echo "enter datadir"
read -r DATADIR


swarm -bzzaccount "$BZZ" --datadir "$DATADIR" --ens-api "$DATADIR/geth.ipc"
