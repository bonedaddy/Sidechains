import ipfsapi

class Ipfs():

	def __init__(self, ipAddress, portNumber):
		self.ip = ipAddress
		self.port = portNumber
		self.hashes = {}

	# stores an api handler in mem
	def connect(self):
		self.api = ipfsapi.connect(
			self.ip, self.port)

	def return_api_handler(self):
		return self.api

	def add_file(self, obj):
		response = self.api.add(obj)
		self.hashes[response['Name']] = response['Hash']

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