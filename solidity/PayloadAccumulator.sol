pragma solidity 0.4.20;

import "./Modules/Administration.sol";
import "./Math/SafeMath.sol";

contract PayloadAccumulator is Administration {
	using SafeMath for uint256;

	SubmissionStates constant public DEFAULTSUBMISSIONSTATE = SubmissionStates.submitted;

	enum SubmissionStates { submitted, accepted, challenged, fraudulent }

	struct SubmissionStruct {
		address pAddress;
		address mAddress;
		address cAddress;
		bytes 	payload;
		uint256 blockSubmittedAt;
		SubmissionStates state;
	}

	mapping (bytes20 => SubmissionStruct) 	public submissions;
	mapping (address => bool)				public relays;

	modifier onlyRelay() {
		require(relays[msg.sender]);
		_;
	}

	function PayloadAccumulator() {
		relays[msg.sender] = true;
	}

	function addRelay(
		address _relayAddress)
		public
		onlyRelay
		returns (bool)
	{
		relays[_relayAddress] = true;
		return true;
	}

	function submitPayload(
		address _pAddress,
		address _mAddress,
		address _cAddress,
		bytes 	_payload)
		public
		onlyRelay
		returns (bool)
	{
		require(_payload.length > 0);
		bytes20 id = ripemd160(_payload, block.number);
		submissions[id] = SubmissionStruct(
			_pAddress,
			_mAddress,
			_cAddress,
			_payload,
			block.number,
			DEFAULTSUBMISSIONSTATE);
		return true;
	}


}