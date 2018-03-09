pragma solidity 0.4.21;


contract BridgeTest {

	string public constant INFO = "Bridge Unit Tester";
	string public constant VERSION = "0.0.1a";

	event Test(address _sender);

	function sendTest()
		public
		returns (bool)
	{
		emit Test(msg.sender);
		return true;
	}
}