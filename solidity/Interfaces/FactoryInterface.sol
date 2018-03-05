pragma solidity 0.4.20;

interface FactoryInterface {
	function sealer() external view returns (address);
	function ptbridge() external view returns (address);
}