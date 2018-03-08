pragma solidity 0.4.20;

interface RelayersInterface {
	function omega() external view returns (address);
	function checkIfActiveRelay(address _relayerAddress) external view returns (bool);
}