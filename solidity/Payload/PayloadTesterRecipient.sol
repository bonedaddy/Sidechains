pragma solidity 0.4.20;

contract Test {

	string public someVariable;

	function setSomeVariable(string _data) public returns (bool) {
		someVariable = _data;
		return true;
	}
}