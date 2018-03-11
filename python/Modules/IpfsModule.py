from web3 import Web3, IPCProvider, HTTPProvider
from web3.contract import ConciseContract
import ipfsapi
import json

class Listener():

	def __init__(self):
		self.initialized = True

	# if we're not using test rpc, connect via ipc
	def establishIpcConnection(self, ipcPath):
		self.w3 = Web3(IPCProvider(ipcPath))
		
	# if we're not using test rpc, connect via specified rpc url
	def establishRpcConnection(self, rpcUrl):
		self.w3 = Web3(HTTPProvider(rpcUrl))

	# lets us manually load a contract on the given network, returning an instance ofi ts contract object
	def manualLoadContract(self, contractAddress, contractAbi):
		with open(contractAbi, 'r') as fh:
			abi = json.load(fh)
		return self.w3.eth.contract(contractAddress, abi=abi)

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

class Ipfs(Listener):

	def __init__(self, ipAddress, portNumber, peerRegistryContract='0x', peerRegistryAbi='0x'):
		self.ip = ipAddress
		self.port = portNumber
		self.peerRegistryContract = peerRegistryContract
		self.peerRegistryAbi = peerRegistryAbi
		self.hashes = {}

	# stores an api handler in mem
	def connect_to_ipfs(self):
		self.api = ipfsapi.connect(
			self.ip, self.port)

	def return_api_handler(self):
		return self.api

	# this needs to notify the network somehow that the file was added to ipfs, so the other nodes can pin it
	def add_file(self, obj):
		response = self.api.add(obj)
		self.hashes[response['Name']] = response['Hash']
		return response

	# returns the contents of file in bytes
	def read_file_bytes(self, fileName):
		assert fileName in self.hashes.keys()
		return self.api.cat(fileName)

	def return_pinned_files(self):
		return self.api.pin_ls()

	def repo_stat(self):
		return self.api.repo_stat()

	def return_multihashserialized_dag_node(self, hashName):
		try:
			return self.api.object_get(hashName)
		except exception as e:
			print("Invalid multihash or other error\n", e)

	def resolve(self, hashName):
		try:
			return self.api.resolve(hashName)
		except exception as e:
			print("Invalid multihash or other error\n", e)

	# publishes a name to ipns
	def name_publish(self, hashName):
		ipfsPath = self.resolve(hashName)
		self.api.name_publish(ipfsPath)

	def pin_object_locally(self, hashName, fileName):
		self.api.pin_add(hashName)
		self.hashes[fileName] = hashName

	#retrieve all peers hosting a single file
	def dht_find_provs(self, hashName):
		return self.api.dht_findprovs(hashName)

	def get_id_object(self):
		return self.api.id()

	# perform garbage collection on non-pinned objects, returning the list of removed objects
	def repo_garbage_collection(self):
		removedObjs = self.api.repo_gc()
		return removedObjs

	# used to construct the necessary components to submit a peer struct
	# to the contract
	def construct_peer_struct(self, peerID):
		id = self.api.id(peerID)
		obj = {}
		obj['id'] = id['ID']
		obj['pk'] = id['PublicKey']
		obj['av'] = id['AgentVersion']
		obj['pv'] = id['ProtocolVersion']
		return obj

	def connect(self, path, Ipc: False):
		if Ipc == False:
			super().establishRpcConnection(path)
		else:
			super().establishIpcConnection(path)

	def loadPeerRegistryContract(self):
		assert self.peerRegistryAbi != '0x' and self.peerRegistryContract != '0x'
		self.contract = super().manualLoadContract(self.peerRegistryContract, self.peerRegistryAbi)
		return self.contract

	def fetchPeerIds(self):
		assert self.peerRegistryAbi != '0x' and self.peerRegistryContract != '0x'
		numPeers = self.contract.call().numPeers()
		peerIds = {}
		for i in range(1, numPeers + 1):
			peerIds[i] = self.contract.call().fetchPeerIdForPeerNumber(i)
		return peerIds

	def fetchPeerStructAtKey(self, key):
		assert self.peerRegistryAbi != '0x' and self.peerRegistryContract != '0x'
		return self.contract.call().fetchPeerStructAtKey(key)

