from Modules import Listener
from time import sleep
from web3.middleware.pythonic import (
    pythonic_middleware,
    to_hexbytes,
)
from web3 import Web3
from getpass import getpass
import json
import yaml

size_extraData_for_poa = 200   # can change

pythonic_middleware.__closure__[2].cell_contents['eth_getBlockByNumber'].args[1].args[0]['extraData'] = to_hexbytes(size_extraData_for_poa, variable_length=True)
pythonic_middleware.__closure__[2].cell_contents['eth_getBlockByHash'].args[1].args[0]['extraData'] = to_hexbytes(size_extraData_for_poa, variable_length=True)



config = 'configs/settings_test.yml'
with open(config, 'r') as ymlFile:
	cfg = yaml.load(ymlFile)


pDataBridgeAddress = cfg['private']['dataBridgeAddress']
pDataBridgeAbiFile = cfg['private']['dataBridgeAbi']
pConnectionMethod = cfg['private']['connectionMethod']
mPayloadContractAddress = cfg['main']['payloadContractAddress']
mPayloadContractAbi = cfg['main']['payloadContractAbi']
mConnectionMethod = cfg['main']['connectionMethod']

if pConnectionMethod == 'rpc':
	pConnectionPath = cfg['private']['rpcUrl']
elif pConnectionMethod == 'ipc':
	pConnectionPath = cfg['private']['ipcPath']
else:
	exit()

if mConnectionMethod == 'rpc':
	mConnectionPath = cfg['main']['rpcUrl']
elif mConnectionMethod == 'ipc':
	mConnectionPath = cfg['main']['ipcPath']
else:
	exit()


pNet = Listener.Listener(pDataBridgeAddress, pDataBridgeAbiFile)
mNet = Listener.Listener(mPayloadContractAddress, mPayloadContractAbi)

if pConnectionMethod == 'rpc':
	# connect to the network
	pNet.establishRpcConnection(pConnectionPath)
elif pConnectionMethod == 'ipc':
	# connect to the network
	pNet.establishIpcConnection(pConnectionPath)
else:
	exit()


if mConnectionMethod == 'rpc':
	mNet.establishRpcConnection(mConnectionPath)
elif mConnectionMethod == 'ipc':
	mNet.establishIpcConnection(mConnectionPath)
else:
	exit()

# this will load the private netcontract 
pNet.loadContract()

# this will load the main net payload accumulator
# enter main net details to authenticate and unlock contract exeuction capabilites
password = getpass("Enter mainnet account password")
accountAddress = Web3.toChecksumAddress("0x069bA77207aD40B7d386F8E2979a9337A36f991c")

mNet.loadContract()
mNet.authenticate(accountAddress, password)
payloadContract = mNet.returnContractHandler()
print(payloadContract)
help(payloadContract)
def payloadSubmission(mAddress, mContract, payload, fileHash):
	payloadContract.functions.submitPayload(mAddress, mContract, payload, fileHash).transact({'from': accountAddress})

eventName = 'DataSwapApproved'

events = []

eventFilter = pNet.returnEventHandler(eventName)
"""
	event DataSwapApproved(
		address _mAddress,
		address _mContract,
		bytes   _payload);
"""
swapObject = {}
swapObjectList = []
while True:
	ev = pNet.getNewEventEntries(eventFilter)
	if len(ev) > 0:
		for e in ev:
			events.append(e)
	if len(events) > 0:
		for evnt in events:
			swapObject = {}
			for key in evnt['args'].keys():
				if key == '_payload':
					swapObject[key.strip('_')] = Web3.toHex(Web3.toBytes(evnt['args'][key]))
				else:
					swapObject[key.strip('_')] = evnt['args'][key]
			swapObjectList.append(swapObject)
		# lets process the swaps now
		a = 1
		for swap in swapObjectList:
			print("processing swap",a)
			mAddress = swap['mAddress']
			mContract = swap['mContract']
			payload = swap['payload']
			file = 'test'
			payloadSubmission(mContract, mAddress, payload, file)
			a += 1
	print(swapObjectList)
	swapObject = {}
	swapObjectList = []
	events = []
	sleep(5)