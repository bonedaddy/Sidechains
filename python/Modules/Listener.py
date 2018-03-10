from web3 import Web3, IPCProvider, HTTPProvider
from web3.contract import ConciseContract
import json

# lightweight library used to establish a listen (read-only) connection to a contract to fetch events.
# We use the ConciseContract factory method since we are only performing read actions

class Listener():

	def __init__(self, listenerContract, listenerContractAbi):
		self.listenerContract = listenerContract
		with open(listenerContractAbi, 'r') as abi_definition:
			self.listenerContractAbi = json.load(abi_definition)

	# if we're not using test rpc, connect via ipc
	def establishIpcConnection(self, ipcPath):
		self.w3 = Web3(IPCProvider(ipcPath))
		
	# if we're not using test rpc, connect via specified rpc url
	def establishRpcConnection(self, rpcUrl):
		self.w3 = Web3(HTTPProvider(rpcUrl))
	
	def authenticate(self, account, password):
		self.w3.personal.unlockAccount(account, password, 0)

	# loads the listener contract (bridge contract)
	def loadContract(self):
		self.contract = self.w3.eth.contract(self.listenerContract, abi=self.listenerContractAbi)

	# lets us manually load a contract on the given network, returning an instance ofi ts contract object
	def manualLoadContract(self, contractAddress, contractAbi):
		return self.w3.eth.contract(contractAddress, abi=contractAbi, ContractFactoryClass=ConciseContract)

	# returns a particular  log filter instance for the particular event.
	def returnEventHandler(self, eventName):
		event_filter = self.contract.eventFilter(eventName)
		return event_filter

	# get new event entries, requires a valid event filter
	def getNewEventEntries(self, eventFilter):
		return eventFilter.get_new_entries()

	# return an instance of the contract
	def returnContractHandler(self):
		return self.contract