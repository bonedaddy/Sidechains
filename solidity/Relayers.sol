pragma solidity 0.4.20;

contract Relayers {

	address constant public omega = address(0);

	enum RelayStates { pending, active, disabled }

	RelayStates constant public DEFAULTSTATE = RelayStates.pending;

	struct RelayerStruct {
		address relayAddress;
		bytes32 id;
		RelayStates state;
	}

	mapping (address => RelayerStruct) public relayers;

	event RelayAdded(address _relayAddress, bytes32 _id);
	event RelayActivated(address _relayAddress);

	modifier onlyOmega() {
		require(msg.sender == omega);
		_;
	}

	modifier pendingRelay(address _addr) {
		require(relayers[_addr].state == RelayStates.pending && relayers[_addr].id != bytes32(0));
		_;
	}

	modifier onlyRelays() {
		require(relayers[msg.sender].state == RelayStates.active);
		_;
	}

	function addRelay(
		address _relayAddress)
		public
		onlyRelays
		returns (bool)
	{
		relayers[_relayAddress].relayAddress = _relayAddress;
		relayers[_relayAddress].id = keccak256(_relayAddress, block.number);
		relayers[_relayAddress].state = DEFAULTSTATE;
		RelayAdded(_relayAddress, relayers[_relayAddress].id);
		return true;
	}

	function activateRelay(
		address _relayAddress)
		public
		onlyOmega
		pendingRelay(_relayAddress)
		returns (bool)
	{
		relayers[_relayAddress].state = RelayStates.active;
		RelayActivated(_relayAddress);
		return true;
	}

	function checkIfActiveRelay(
		address _relayAddress)
		public
		view
		returns (bool)
	{
		if (relayers[_relayAddress].state == RelayStates.active) {
			return true;
		} else {
			return false;
		}
	}


}