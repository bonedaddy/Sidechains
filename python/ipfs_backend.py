from Modules import IpfsModule
from Modules import listener
from time import sleep
import sys

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
