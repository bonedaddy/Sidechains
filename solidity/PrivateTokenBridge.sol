pragma solidity 0.4.20;

import "./Math/SafeMath.sol";
import "./Sealers.sol";
import "./Interfaces/ERC20Interface.sol";
import "./Interfaces/SealersInterface.sol";
import "./Interfaces/FactoryInterface.sol";

/** proposal validation hash 
	bytes32 _prefix = keccak256(msg.sender, pAddress, depositValue, blockProposed);
	bytes32 prefixedHash keccak256(prefix, _prefix);

	To Do:
		Add signing (this was removed until we worked out hte logic)

*/
contract TokenBridge {

	bytes private prefix = "\x19Ethereum Signed Message:\n32";

	ERC20Interface 	public tokenI;
	SealersInterface public sealerI;

	struct SwapProposal {
		address pAddress;
		address mAddress;
		address mRecipient;
		address token;
		uint256 deposit;
		bool	approved;
	}

	mapping (address => mapping (uint256 => SwapProposal)) 	public proposedTokenSwaps;
	/**
		When this is fired, a sealer wll be taksed with validating the proposal
	*/
	event SwapProposed(
		address _pAddress,
		address _mAddress,
		address _recipient,
		address _token,
		uint256 _deposit,
		uint256 _blockNumber);
	/**
		When this event is fired, the swap is approved,  indicating for the relay ot execute the swap
		We don't provide the private address since we no longer need it
	*/
	event SwapApproved(
		address _mAddress,
		address _recipient,
		address _token,
		uint256 _amount);

	modifier onlySealers() {
		require(sealerI.checkIfSealerEnabled(msg.sender));
		_;
	}

	function TokenBridge() {
		FactoryInterface fI = FactoryInterface(msg.sender);
		sealerI = SealersInterface(fI.sealer());
	}

	function setSealersInterface(
		address _sealerContract)
		public
		onlySealers
		returns (bool)
	{
		sealerI = SealersInterface(_sealerContract);
		return true;
	}


	/*
		Used by a sealer to validate a token swap proposal
	*/
	function validateTokenSwap(
		address _pAddress,
		uint256 _blockProposedAt)
		public
		onlySealers
		returns (bool)
	{
		address mAddress = proposedTokenSwaps[_pAddress][_blockProposedAt].mAddress;
		address mRecipient = proposedTokenSwaps[_pAddress][_blockProposedAt].mRecipient;
		address token = proposedTokenSwaps[_pAddress][_blockProposedAt].token;
		uint256 value = proposedTokenSwaps[_pAddress][_blockProposedAt].deposit;
		proposedTokenSwaps[_pAddress][_blockProposedAt].approved = true;
		SwapApproved(mAddress, mRecipient, token, value);
		return true;
	}

	/*
		Used to propose an asset transfer of a mainnet token to a mainnet address
		Note, the mainnetaddress must hold a valid balance of the designated token contract
	*/
	function proposeTokenSwap(
		address _mainNetAddress,
		address _recipient,
		address _tokenContract,
		uint256 _deposit)
		public
		returns (bool)
	{
		proposedTokenSwaps[msg.sender][block.number].pAddress = msg.sender;
		proposedTokenSwaps[msg.sender][block.number].mAddress = _mainNetAddress;
		proposedTokenSwaps[msg.sender][block.number].mRecipient = _recipient;
		proposedTokenSwaps[msg.sender][block.number].token = _tokenContract;
		proposedTokenSwaps[msg.sender][block.number].deposit = _deposit;
		SwapProposed(msg.sender, _mainNetAddress, _recipient, _tokenContract, _deposit, block.number);
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