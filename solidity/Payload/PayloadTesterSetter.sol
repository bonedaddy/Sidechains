pragma solidity 0.4.21;

contract PayloadTesterSetter {

	function setData(address _target, bytes _data) public returns (bool) {
		return _target.call(_data);
	}
}
