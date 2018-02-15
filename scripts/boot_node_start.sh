#! /bin/bash

# used to start a boot node
echo "enter location of boot node key"
read -r bootKeyPath
echo "enter verbosity level"
read -r verbosityLevel
echo "enter port address"
read -r portAddress
bootnode -nodekey "$bootKeyPath" -verbosity "$verbosityLevel" -addr ":$portAddress"
