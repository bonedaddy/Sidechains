from Modules import IpfsModule
from web3 import Web3
import sys

# python3.6 IpfsNode.py

# new better way to connect 
#  web3.providers.ipc.IPCProvider('geth.ipc')
# >>> w3 = Web3(web3.providers.ipc.IPCProvider(('geth.ipc')))

mode = "dev"

if mode != "dev":
	ip = input("Enter ipfs api ip address\t")
	port = int(input("Enter ipfs api port number\t"))
	peerRegistryContractAddress = Web3.toChecksumAddress(input("Enter peer registry contract address\t"))
	peerRegistryContractAbiPath = input("Enter path to peer registry contract abi\t")

else:
	ip = "127.0.0.1"
	port = 5001
	peerRegistryContractAddress = Web3.toChecksumAddress("0x7B8fC2C025b9a50E45D514c6e7Cc14749e55fBd8")
	peerRegistryContractAbiPath = "abi/PeerRegistry.abi"
	ipcPath = "http://127.0.0.1:8501"

print("loading ipfs module")

try:
	ipfs = IpfsModule.Ipfs(ip, port, peerRegistryContractAddress, peerRegistryContractAbiPath)
	print("Ipfs module loaded")
except Exception as e:
	print("Error encountered loading IPFS Module")
	print(e)
	exit()

print("connecting to ifps network")

try:
	ipfs.connect_to_ipfs()
except Exception as e:
	print("Error encountered connecting to ipfs")
	print(e)
	exit()

print("Connecting to ethereum network with ipc")

try:
	ipfs.connect(ipcPath, False)
	print("Connection to ethereum network successful")
except Exception as e:
	print("error connecting to ethereum network")
	print(e)
	exit()

print("Loading peer registry contract")

try:
	peerRegistryContract = ipfs.loadPeerRegistryContract()
	print("Loaded peer registry contract")
except Exception as e:
	print("Error loading peer registry contract")
	print(e)
	exit()


print("peer list", ipfs.fetchPeerIds())
print("Peer struct at key 1", ipfs.fetchPeerStructAtKey(1))
