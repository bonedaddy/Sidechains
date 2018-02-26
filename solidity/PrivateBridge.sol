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

	// k1  = paddress k2 = block num v1 = proposal
	mapping (address => mapping (uint256 => SwapProposal)) private proposedTokenSwaps;

	/**
		When this is fired, a sealer wll be taksed with validating the proposal
	*/
	event SwapProposed(address _pAddress, address _mAddress, uint256 _blockNumber, uint256 _deposit);
	/**
		When this event is fired, the swap is approved, and the bridge will send a transaction to the mainnet
	*/
	event SwapApproved(address _pAddress, address _mAddress, uint256 _amount);

	function validateProposal(
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
		assert(prefixedHash == _h);
		proposedTokenSwaps[_pAddress][_blockProposedAt].approved = true;
		SwapApproved(_pAddress, swaps[_pAddress][_blockProposedAt].mAddress, _depositValue);
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