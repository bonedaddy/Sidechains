pragma solidity 0.4.21;

import "./Math/SafeMath.sol";

contract Sealers {

	using SafeMath for uint256;
 
 	/*
		this is a hard coded address, and is supposed to be the first sealer of the network
		the singularity node is what signs the messages to be submitted by sealers
		for authorization of transfers to the mainnet

		this is then picked up by one of the authorized bridge programs that then pushes the transaction
		to the mainnet. these authorized bridges are ran by all the sealers. This is an extremely basic
		way of allowing a distributed method of submitting transactions to the main network. This will
		be refined as time goes on.
 	*/
	address constant public singularity = 0xC3D2aA21caa190AEE4F70F8359d96F6d3c5dAD9C;

	enum SealerStates { pending, active, disabled }

	address[]	public 	sealerAddresses;
	uint256		public	sealerCount = 1;
	// 60% in eth
	uint256		public	minQuorumPercent = 0.6 ether;

	struct SealerStruct {
		bytes32 id;
		uint256 forgedDate;
		SealerStates state;
	}

	mapping (address => SealerStruct) 	public sealers;
	mapping (address => bool)			public registeredSealers;

	event SealerForged(address _sealerAddress, bytes32 _id);

	modifier onlySingularity() {
		require(msg.sender == singularity);
		_;
	}

	function Sealers() {
		sealers[0xC3D2aA21caa190AEE4F70F8359d96F6d3c5dAD9C].id = keccak256(uint8(1));
		sealers[0xC3D2aA21caa190AEE4F70F8359d96F6d3c5dAD9C].forgedDate = now;
		sealers[0xC3D2aA21caa190AEE4F70F8359d96F6d3c5dAD9C].state = SealerStates.active;
	}

	/*
		used by singularity ndoe to forcefully forge a sealer
	*/
	function _forgeSealer(
		address _sealerAddress)
		public
		onlySingularity
		returns (bool)
	{
		sealerCount = sealerCount.add(1);
		bytes32 id = keccak256(_sealerAddress, now, sealerCount);
		sealers[_sealerAddress].id = id;
		sealers[_sealerAddress].forgedDate = now;
		sealers[_sealerAddress].state = SealerStates.active;
		sealerAddresses.push(_sealerAddress);
		SealerForged(_sealerAddress, id);
		return true;
	}

	function calculateRequiredVotes()
		public
		view
		returns (uint256)
	{
		uint256 mulSealercount = sealerCount.mul(1 ether);
		uint256 mulRequiredVotes = mulSealercount.mul(minQuorumPercent);
		return mulRequiredVotes.div(1 ether);
	}

	function checkIfSealerEnabled(
		address _sealerAddress)
		public
		view
		returns (bool)
	{
		if (sealers[_sealerAddress].state == SealerStates.active) {
			return true;
		} else {
			return false;
		}
	}

}