pragma solidity 0.4.21;

interface SealersInterface {
		function checkIfSealerEnabled(address _sealerAddress) external view returns (bool);
}