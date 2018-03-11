from time import sleep
from Modules import Bridge
from Modules import IpfsModule
from web3 import Web3,IPCProvider
import datetime
import json
import yaml

from web3.middleware.pythonic import (
    pythonic_middleware,
    to_hexbytes,
)

size_extraData_for_poa = 200   # can change

web3 = Web3(IPCProvider('/home/solidity/.ethereum/geth.ipc'))

pythonic_middleware.__closure__[2].cell_contents['eth_getBlockByNumber'].args[1].args[0]['extraData'] = to_hexbytes(size_extraData_for_poa, variable_length=True)

pythonic_middleware.__closure__[2].cell_contents['eth_getBlockByHash'].args[1].args[0]['extraData'] = to_hexbytes(size_extraData_for_poa, variable_length=True)

# lets load the configuration file
configFile = 'configs/settings_test.yml'

with open(configFile, 'r') as ymlFile:
	cfg = yaml.load(ymlFile)

pDataBridgeAddress = cfg['private']['dataBridgeAddress']

pDataBridgeAbiFile = cfg['private']['dataBridgeAbi']

pSealerAddress = cfg['private']['sealerAddress']

pSealerPassword = cfg['private']['sealerPassword']

pConnectionMethod = cfg['private']['connectionMethod']

ipfsIp = cfg['ipfs']['ip']

ipfsPort = cfg['ipfs']['port']

ipfs = IpfsModule.Ipfs(ipfsIp, ipfsPort)

ipfs.connect_to_ipfs()

if pConnectionMethod == 'rpc':
	pConnectionPath = cfg['private']['rpcUrl']
elif pConnectionMethod == 'ipc':
	pConnectionPath = cfg['private']['ipcPath']

# lets create a connection object ot the private networl
pNet = Bridge.Listener(pSealerAddress, pSealerPassword, pDataBridgeAddress, pDataBridgeAbiFile)

if pConnectionMethod == 'rpc':
	# connect to the network
	pNet.establishRpcConnection(pConnectionPath)
elif pConnectionMethod == 'ipc':
	# connect to the network
	pNet.establishIpcConnection(pConnectionPath)

# before we do anything we need to unlock the account
pNet.unlockAccount()

# load the bridge contract object
pNet.loadContract()

pNet.loadContract()

contract = pNet.returnContractHandler()

eventName = 'DataSwapProposed'

# lets return an  event filter
eventFilter = pNet.returnEventHandler(eventName)

events = []

swapObjectList = []

swapObjects = {}

while True:
	ev = pNet.getNewEventEntries(eventFilter)
	if len(ev) > 0:
		for e in ev:
			events.append(e)
	if len(events) > 0:
		print('new events detected.\n%d events detected' % len(events))
		for ev in events:
			swapObjects = {}
			for key in ev['args'].keys():
				if key == '_payload':
					swapObjects[key.strip('_')] = Web3.toHex(Web3.toBytes(ev['args'][key]))
				else:
					swapObjects[key.strip('_')] = ev['args'][key]
			swapObjectList.append(swapObjects)
		for swap in swapObjectList:
			now = datetime.datetime.now()
			date = "%s-%s-%s--%s:%s:%s" % (now.year, now.month, now.day, now.hour, now.minute, now.second)
			msg = "mAddress: %s\nmContract: %s\npayload: %s\n" % (swap['mAddress'], swap['mContract'], swap['payload'])
			fileName = "%s_%s_%s" % (swap['mAddress'], swap['mContract'], date)
			with open('/tmp/%s' % fileName, 'w') as fh:
				fh.write(msg)
			with open('/tmp/%s' % fileName, 'rb') as fh:
				response = ipfs.add_file(fh)
				fHash = response['Hash']
				print(ipfs.hashes)
				with open('/tmp/ipfs_files.txt', 'a') as fh:
					fh.write('%s\n' % ipfs.hashes)
			print('submitting swap approval to data bridge contract for ipfs hash', fHash)
			contract.functions.validateDataSwap(Web3.toChecksumAddress(swap['pAddress']), swap['blockProposedAt'], Web3.toText(text=fHash)).transact({'from': pSealerAddress})
	events = []
	swapObjectList = []
	swapObjects = {}
	sleep(1)
