pragma solidity 0.4.20;


contract BridgeTest {

	string public constant INFO = "Bridge Unit Tester";
	string public constant VERSION = "0.0.1a";

	event Test(address _sender);

	function sendTest()
		public
		returns (bool)
	{
		Test(msg.sender);
		return true;
	}
}