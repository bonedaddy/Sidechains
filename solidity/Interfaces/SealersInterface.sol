pragma solidity 0.4.20;

interface SealersInterface {
		function checkIfSealerEnabled(address _sealerAddress) external view returns (bool);
}