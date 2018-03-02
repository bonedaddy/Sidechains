pragma solidity 0.4.20;

import "./Math/SafeMath.sol";
import "./Sealers.sol";
import "./Interfaces/ERC20Interface.sol";


/** proposal validation hash 
	bytes32 _prefix = keccak256(msg.sender, pAddress, depositValue, blockProposed);
	bytes32 prefixedHash keccak256(prefix, _prefix);

	not yet tested, still a WIP

*/
contract PrivateBridge is Sealers {

	bytes private prefix = "\x19Ethereum Signed Message:\n32";
	ERC20Interface 	public token;

	struct SwapProposal {
		address pAddress;
		address mAddress;
		uint256 deposit;
		bool	approved;
	}


	/*
		This is used to store data necessary to execute a data transfer from the private chain to the main chian
		This could be executing a function from the private chain. For example, we can have gas expensive business logic on the private chain, then for the final step
		transfer the "data" to the mainchain to execute the final function.
	*/
	struct DataTransfer {
		address pAddress;
		address mAddress;
		address mContract;
		bytes 	data;
		bool 	approved;
	}

	// k1  = paddress k2 = block num v1 = proposal
	mapping (address => mapping (uint256 => SwapProposal)) 	private proposedTokenSwaps;
	// k1 = pAddress, k2 = block num, v1 = proposal
	mapping (address => mapping (uint256 => DataTransfer))  private proposedDataSwap;

	/**
		When this is fired, a sealer wll be taksed with validating the proposal
	*/
	event SwapProposed(address _pAddress, address _mAddress, uint256 _blockNumber, uint256 _deposit);
	/**
		When this event is fired, the swap is approved, and the bridge will send a transaction to the mainnet
	*/
	event SwapApproved(address _pAddress, address _mAddress, uint256 _amount);
	event DataSwapProposed(
		address _pAddress,
		address _mAddress,
		address _mContract,
		uint256 _blockProposedAt,
		bytes _data);
	event DataSwapApproved(
		address _mAddress,
		address _mContract,
		bytes _data);

	function proposeDataSwap(
		address _mAddress,
		address _mContract,
		bytes   _data)
		public
		returns (bool)
	{
		proposedDataSwap[msg.sender][block.number].pAddress = msg.sender;
		proposedDataSwap[msg.sender][block.number].mAddress = _mAddress;
		proposedDataSwap[msg.sender][block.number].mContract = _mContract;
		proposedDataSwap[msg.sender][block.number].data = _data;
		DataSwapProposed(
			msg.sender,
			_mAddress,
			_mContract,
			block.number,
			_data
		);
		return true;
	}

	function validateDataSwap(
		address _pAddress,
		uint256 _blockProposedAt,
		bytes32 _h,
		uint8	_v,
		bytes32 _r,
		bytes32 _s)
		public
		onlySealers
		returns (bool)
	{
		require(!proposedDataSwap[_pAddress][_blockProposedAt].approved);
		address signer = ecrecover(_h, _v, _r, _s);
		assert(signer == singularity);
		proposedDataSwap[_pAddress][_blockProposedAt].approved = true;
		// this event will cause the relays to send the datato the mainnet
		DataSwapApproved(
			proposedDataSwap[_pAddress][_blockProposedAt].mAddress,
			proposedDataSwap[_pAddress][_blockProposedAt].mContract,
			proposedDataSwap[_pAddress][_blockProposedAt].data
		);
		return true;
	}

	function validateTokenSwapProposal(
		address _pAddress,
		uint256 _blockProposedAt,
		uint256 _depositValue,
		bytes32 _h,
		uint8   _v,
		bytes32 _r,
		bytes32 _s)
		public
		onlySealers
		returns (bool)
	{
		bytes32 _prefix = keccak256(msg.sender, _pAddress, _depositValue, _blockProposedAt);
		bytes32 prefixedHash = keccak256(prefix, _prefix);
		address signer = verifySignature(_h, _v, _r, _s);
		signer; // silence compiler warning
		assert(prefixedHash == _h);
		proposedTokenSwaps[_pAddress][_blockProposedAt].approved = true;
		SwapApproved(_pAddress, proposedTokenSwaps[_pAddress][_blockProposedAt].mAddress, _depositValue);
		return true;
	}


	function proposeTokenSwapToMainnet(
		address _mainNetAddress,
		uint256 _deposit)
		public
		returns (bool)
	{
		proposedTokenSwaps[msg.sender][block.number].pAddress = msg.sender;
		proposedTokenSwaps[msg.sender][block.number].mAddress = _mainNetAddress;
		proposedTokenSwaps[msg.sender][block.number].deposit = _deposit;
		SwapProposed(msg.sender, _mainNetAddress, block.number, _deposit);
		return true;
	}

	function verifySignature(
		bytes32 _h,
		uint8   _v,
		bytes32 _r,
		bytes32 _s)
		public
		pure
		returns (address)
	{
		return ecrecover(_h, _v, _r, _s);
	}
}