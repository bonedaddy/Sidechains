pragma solidity 0.4.21;

import "blah/Math/SafeMath.sol";
import "blah/Modules/Administration.sol";

/*
  <id> : The peers id.
  <aver>: Agent version.
  <pver>: Protocol version.
  <pubkey>: Public key.
  <addrs>: Addresses (newline delimited).
*/

contract PeerRegistry is Administration {

	using SafeMath for uint256;

	uint256	public numPeers;

	struct PeerStruct {
		string id;
		string av;
		string pv;
		string pk;
	}

	mapping (uint256 => PeerStruct) 	private peers;
	mapping (string => bool)			private registeredPeers;

	event PeerRegistered(
		string _id,
		string _av,
		string _pv,
		string _pk,
		uint256 _peerCount);

	modifier nonRegisteredPeer(string _id) {
		require(!registeredPeers[_id]);
		_;
	}

	function fetchPeerStructAtKey(
		uint256 _key)
		public
		view
		returns (string, string, string, string)
	{
		return (peers[_key].id, peers[_key].av, peers[_key].pv, peers[_key].pk);
	}

	function addPeer(
		string _id,
		string _av,
		string _pv,
		string _pk)
		public
		nonRegisteredPeer(_id)
		onlyAdmin
		returns (bool)
	{
		numPeers = numPeers.add(1);
		peers[numPeers] = PeerStruct(_id, _av, _pv, _pk);
		emit PeerRegistered(_id, _av, _pv, _pk, numPeers);
		return true;
	}

	function fetchPeerIdForPeerNumber(
		uint256 _peerNumber)
		public
		view
		returns (string)
	{
		return peers[_peerNumber].id;
	}


	function numPeers() public view returns (uint256) {
		return numPeers;
	}
}