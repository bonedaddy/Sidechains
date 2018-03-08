from time import sleep
from Modules import Bridge
import json
import yaml

# lets load the configuration file
configFile = 'configs/settings_test.yml'
with open(configFile, 'r') as ymlFile:
	cfg = yaml.load(ymlFile)


pTokenBridgeAddress = cfg['private']['tokenBridgeAddress']
pTokenBridgeAbiFile = cfg['private']['tokenBridgeAbi']
pSealerAddress = cfg['private']['sealerAddress']
pSealerPassword = cfg['private']['sealerPassword']
pConnectionMethod = cfg['private']['connectionMethod']

if pConnectionMethod == 'rpc':
	pConnectionPath = cfg['private']['rpcUrl']
elif pConnectionMethod == 'ipc':
	pConnectionPath = cfg['private']['ipcPath']


# lets create a connection object ot the private networl
pNet = Bridge.Listener(pSealerAddress, pSealerPassword, pTokenBridgeAddress, pTokenBridgeAbiFile)

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


"""
	event SwapApproved(
		address _mAddress,
		address _recipient,
		address _token,
		uint256 _amount);

"""
eventName = 'SwapApproved'
# lets return an  event filter
eventFilter = pNet.returnEventHandler(eventName)

events = []

swapObjects = {}

while True:
	ev = pNet.getNewEventEntries(eventFilter)
	if len(ev) > 0:
		for e in ev:
			events.append(e)
	if len(events) > 0:
		for ev in events:
			print(ev['args'])
			for key in ev['args'].keys():
				if key == '_mAddress':
					swapObjects['mAddress'] = ev['args'][key]
				elif key == '_recipient':
					swapObjects['recipient'] = ev['args'][key]
				elif key == '_token':
					swapObjects['token'] = ev['args'][key]
				elif key == '_amount':
					swapObjects['amount'] = ev['args'][key]
			print(swapObjects)
	sleep(5)
"""
AttributeDict({'_mAddress': '0xabB36c583E9B15736038858bDd540f7f422Db0F8', '_recipient': '0x365b3b4d3168a11291449A015FA0C1b34B0B3d72', '_token': '0x28605Eacf39C906b5331C4C81b9BC3c07F3eF606', '_amount': 9999999999999999999})
"""
