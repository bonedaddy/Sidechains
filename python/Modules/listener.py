from web3 import Web3, IPCProvider, HTTPProvider
from web3.contract import ConciseContract
import json

# Contract agnostic listener
class Listener():

	def __init__(self, adminAccount, adminPassword, listenerContract, listenerContractAbi):
		self.adminAccount = adminAccount
		self.adminPassword = adminPassword
		self.listenerContract = listenerContract
		self.testRpc = False
		with open(listenerContractAbi, 'r') as abi_definition:
			self.listenerContractAbi = json.load(abi_definition)


	# if we're not using test rpc, connect via ipc
	def establishIpcConnection(self, ipcPath):
		self.w3 = Web3(IPCProvider(ipcPath))
		
	# if we're not using test rpc, connect via specified rpc url
	def establishRpcConnection(self, rpcUrl):
		self.w3 = Web3(HTTPProvider(rpcUrl))
		
	# used to unlock the admin account (this is the sealer on a private network)
	def unlockAccount(self):
		if self.testRpc == False:
			self.w3.personal.unlockAccount(self.adminAccount, self.adminPassword, 0)

	# loads the listener contract (bridge contract)
	def loadContract(self):
		self.contract = self.w3.eth.contract(self.listenerContract, abi=self.listenerContractAbi)

	# lets us manually load a contract on the given network, returning an instance ofi ts contract object
	def manualLoadContract(self, contractAddress, contractAbi):
		return self.w3.eth.contract(contractAddress, abi=contractAbi)

	# returns a particular  log filter instance for the particular event.
	def returnEventHandler(self, eventName):
		event_filter = self.contract.eventFilter(eventName)
		return event_filter

	# get new event entries, requires a valid event filter
	def getNewEventEntries(self, eventFilter):
		return eventFilter.get_new_entries()

	# return an instance of the contract
	def returnContractHandler(self):
		return self.w3.contract