pragma solidity 0.4.20;

import "./Modules/Administration.sol";
import "./Math/SafeMath.sol";
import "./Interfaces/RelayersInterface.sol";

contract PayloadAccumulator is Administration {
	using SafeMath for uint256;

	PayloadStates constant public DEFAULTSTATE = PayloadStates.pending;

	RelayersInterface public relayerI;

	enum PayloadStates { pending, validated, executed }

	struct PayloadStruct {
		address mAddress;
		address mContract;
		bytes	payload;
		PayloadStates state;
	}

	mapping (address => mapping(uint256 => PayloadStruct)) public payloads;

	event PayloadSubmitted(address _mAddress, address _mContract, bytes _payload);
	event PayloadValidated(address _mAddress, address _mContract, bytes _payload);
	event PayloadExecuted(address _mAddress, address _mContract, bytes _payload);

	modifier onlyRelays() {
		require(relayerI.checkIfActiveRelay(msg.sender));
		_;
	}

	modifier onlyOmega() {
		require(msg.sender == relayerI.omega());
		_;
	}

	modifier pendingPayload(address _mAddress, uint256 _blockSubmittedAt) {
		require(payloads[_mAddress][_blockSubmittedAt].state == PayloadStates.pending);
		_;
	}

	modifier validatedPayload(address _mAddress, uint256 _blockSubmittedAt) {
		require(payloads[_mAddress][_blockSubmittedAt].state == PayloadStates.validated);
		_;
	}

	function submitPayload(
		address _mAddress,
		address _mContract,
		bytes 	_payload)
		public
		onlyRelays
		returns (bool)
	{
		payloads[_mAddress][block.number] = PayloadStruct(_mAddress, _mContract, _payload, DEFAULTSTATE);
		PayloadSubmitted(_mAddress, _mContract, _payload);
		return true;
	}

	function validatePayload(
		address _mAddress,
		uint256 _blockSubmittedAt)
		public
		onlyOmega
		pendingPayload(_mAddress, _blockSubmittedAt)
		returns (bool)
	{
		address mContract = payloads[_mAddress][_blockSubmittedAt].mContract;
		bytes memory payload = payloads[_mAddress][_blockSubmittedAt].payload;
		PayloadValidated(_mAddress, mContract, payload);
		return true;
	}

	function executePayload(
		address _mAddress,
		uint256 _blockSubmittedAt)
		public
		onlyRelays
		validatedPayload(_mAddress, _blockSubmittedAt)
		returns (bool)
	{
		payloads[_mAddress][_blockSubmittedAt].state = PayloadStates.executed;
		address mContract = payloads[_mAddress][_blockSubmittedAt].mContract;
		bytes memory payload = payloads[_mAddress][_blockSubmittedAt].payload;
		PayloadExecuted(_mAddress, mContract, payload);
		require(mContract.call(payload));
		return true;
	}
	
}