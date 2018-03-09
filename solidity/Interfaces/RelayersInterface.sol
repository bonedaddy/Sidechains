pragma solidity 0.4.21;

interface RelayersInterface {
	function omega() external view returns (address);
	function checkIfActiveRelay(address _relayerAddress) external view returns (bool);
}