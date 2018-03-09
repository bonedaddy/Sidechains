pragma solidity 0.4.21;

import "./Modules/Administration.sol";
import "./Math/SafeMath.sol";
import "./Interfaces/RelayersInterface.sol";
/*
payload format:
	mAddress (address which has paid the service fee, and execution costs)
	mContract (contract to which the data payload will be sent)
	payload (the actualy data payload)
	ipfsHash (copy of the payload contents, and transaction information which has been stored on ipfs)
*/
contract PayloadAccumulator is Administration {
	
	using SafeMath for uint256;

	RelayersInterface public relayersI;

	enum UserStates { pending, active, disabled }
	enum SubmissionStates { pending, approved, spent }
	enum ContractStates { pending, active, disabled }

	struct PayloadSubmissionStruct {
		address mAddress;
		address mContract;
		bytes 	payload;
		string  fileHash;
		SubmissionStates state;
	}

	struct UserStruct {
		address mAddress;
		uint256 balance;
		uint256 numSubmissions;
		UserStates state;
	}

	struct ContractStruct {
		address contractAddress;
		bytes4[] functionSignatures;
		ContractStates state;
	}

	mapping (address => UserStruct) public users;
	mapping (address => ContractStruct) private contracts;
	mapping (address => bool) private listedContracts;

	event ContractSubmitted(address _contractAddress, bytes4[] _functionSignatures);
	event ContractApproved(address _contractAddress);
	
	modifier activeRelayer(address _addr) {
		require(relayersI.checkIfActiveRelay(_addr));
		_;
	}

	modifier pendingContract(address _contractAddress) {
		require(contracts[_contractAddress].state == ContractStates.pending);
		_;
	}

	modifier nonListedContract(address _contractAddress) {
		require(!listedContracts[_contractAddress]);
		_;
	}

	function addContract(
		address  _contractAddress,
		bytes4[] _functionSignatures)
		public
		nonRegisteredContract(_contractAddress)
		returns (bool)
	{
		contracts[_contractAddress] = ContractStruct(_contractAddress, _functionSignatures, ContractStates.pending);
		listedContracts[_contractAddress] = true;
		emit ContractSubmitted(_contractAddress, _functionSignatures);
		return true;
	}

	function approveContract(
		address _contractAddress)
		public
		activeRelayer(msg.sender)
		pendingContract(_contractAddress)
		returns (bool)
	{
		contracts[_contractAddress].state = ContractStates.approved;
		emit ContractApproved(_contractAddress);
		return true;
	}

}	