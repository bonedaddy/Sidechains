pragma solidity 0.4.21;

import "blah/Math/SafeMath.sol";
import "blah/Interfaces/SealersInterface.sol";
import "blah/Interfaces/FactoryInterface.sol";



contract DataBridge {
	
	using SafeMath for uint256;

	SealersInterface private sealerI;

	ProposalStates private defaultState = ProposalStates.proposed;

	enum ProposalStates { proposed, active, disabled }

	struct DataSwapProposalStruct {
		address pAddress;
		address mAddress;
		address mContract;
		bytes 	payload;
		bytes32 keccak_fileHash;
		ProposalStates state;
	}

	// k1 = pAddress
	// k2 = block number
	mapping (address => mapping(uint256 => DataSwapProposalStruct)) public dataSwapProposals;

	event DataSwapProposed(
		address _pAddress,
		address _mAddress,
		address _mContract,
		bytes   _payload,
		uint256 _blockProposedAt);

	event DataSwapApproved(
		address _mAddress,
		address _mContract,
		bytes   _payload,
		string  _fileHash);

	modifier onlySealers() {
		require(sealerI.checkIfSealerEnabled(msg.sender));
		_;
	}

	function DataBridge() {
		FactoryInterface factoryI = FactoryInterface(msg.sender);
		sealerI = SealersInterface(factoryI.sealer());
	}

	function setSealerInterface(
		address _sealerContract)
		public
		onlySealers
		returns (bool)
	{
		sealerI = SealersInterface(_sealerContract);
		return true;
	}

	function validateDataSwap(
		address _pAddress,
		uint256 _blockProposedAt,
		string  _fileHash)
		public
		onlySealers
		returns (bool)
	{
		dataSwapProposals[_pAddress][_blockProposedAt].state == ProposalStates.active;
		dataSwapProposals[_pAddress][_blockProposedAt].keccak_fileHash = keccak256(_fileHash);
		address mAddress = dataSwapProposals[_pAddress][_blockProposedAt].mAddress;
		address mContract = dataSwapProposals[_pAddress][_blockProposedAt].mContract;
		bytes memory payload = dataSwapProposals[_pAddress][_blockProposedAt].payload;
		emit DataSwapApproved(mAddress, mContract, payload, _fileHash);
		return true;
	}

	/*
		mAddress is the mainnet address which has deposited the funds to pay for the data swap
		mContract is the contract to receive the data swap
		payload is the data payload to send to the contract
	*/
	function proposeDataSwap(
		address _mAddress,
		address _mContract,
		bytes   _payload)
		public
		returns (bool)
	{
		dataSwapProposals[msg.sender][block.number].pAddress = msg.sender;
		dataSwapProposals[msg.sender][block.number].mAddress = _mAddress;
		dataSwapProposals[msg.sender][block.number].mContract = _mContract;
		dataSwapProposals[msg.sender][block.number].payload = _payload;
		dataSwapProposals[msg.sender][block.number].state = defaultState;
		emit DataSwapProposed(msg.sender, _mContract, _mContract, _payload, block.number);
		return true;
	}

}
