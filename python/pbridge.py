from time import sleep
from Modules import listener
import json
import yaml

# special web 3 overrides to work on a PoA network
from web3.middleware.pythonic import (
    pythonic_middleware,
    to_hexbytes,
)

size_extraData_for_poa = 200   # can change
pythonic_middleware.__closure__[2].cell_contents['eth_getBlockByNumber'].args[1].args[0]['extraData'] = to_hexbytes(size_extraData_for_poa, variable_length=True)
pythonic_middleware.__closure__[2].cell_contents['eth_getBlockByHash'].args[1].args[0]['extraData'] = to_hexbytes(size_extraData_for_poa, variable_length=True)
#####



# lets load the configuration file
configFile = 'configs/settings_test.yml'
with open(configFile, 'r') as ymlFile:
	cfg = yaml.load(ymlFile)


pBridgeAddress = cfg['private']['bridgeAddress']
pBridgeAbi = cfg['private']['bridgeAbi']
pSealerAddress = cfg['private']['sealerAddress']
pSealerPassword = cfg['private']['sealerPassword']
connMethod = cfg['private']['connectionMethod']
if connMethod == 'rpc':
	connectionPath = cfg['private']['rpcUrl']
elif connMethod == 'ipc':
	connectionPath = cfg['private']['ipcPath']


# lets create a connection object ot the private networl
pNet = listener.Listener(pSealerAddress, pSealerPassword, pBridgeAddress, pBridgeAbi, None)
if connMethod == 'rpc':
	# connect to the network
	pNet.establishRpcConnection(connectionPath)
elif connMethod == 'ipc':
	# connect to the network
	pNet.establishIpcConnection(connectionPath)


# before we do anything we need to unlock the account
pNet.unlockAccount()

# load the bridge contract object
pNet.loadContract()

eventName = 'Test'
# lets return an  event filter
eventFilter = pNet.returnEventHandler(eventName)

events = []
while True:
	ev = pNet.getNewEventEntries(eventFilter)
	if len(ev) > 0:
		for e in ev:
			events.append(e)
	if len(events) > 0:
		for ev in events:
			print(ev['args'])
	sleep(5)