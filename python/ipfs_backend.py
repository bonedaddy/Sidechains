from Modules import IpfsModule
from Modules import listener
from time import sleep
import sys

# special web 3 overrides to work on a PoA network
from web3.middleware.pythonic import (
    pythonic_middleware,
    to_hexbytes,
)

size_extraData_for_poa = 200   # can change
pythonic_middleware.__closure__[2].cell_contents['eth_getBlockByNumber'].args[1].args[0]['extraData'] = to_hexbytes(size_extraData_for_poa, variable_length=True)
pythonic_middleware.__closure__[2].cell_contents['eth_getBlockByHash'].args[1].args[0]['extraData'] = to_hexbytes(size_extraData_for_poa, variable_length=True)
#####

# python3.6 ipfs_backend.py <ip> <port>
if len(sys.argv) > 3 or len(sys.argv) < 3:
	print("Improper invocation")
	print("python3.6 ipfs_backend.py <ip> <port>")
	exit

ipfs_ip = sys.argv[1]
ipfs_port = sys.argv[2]

# load the module
ipfs = IpfsModule(ipfs_ip, ipfs_port)

# connect to the ipfs network
ipfs.connect()