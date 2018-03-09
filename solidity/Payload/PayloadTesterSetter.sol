pragma solidity 0.4.20;

contract PayloadTesterSetter {

	function setData(address _target, bytes _data) public returns (bool) {
		return _target.call(_data);
	}
}
