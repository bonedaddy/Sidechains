pragma solidity 0.4.20;

/**
    This contract is intended to function the administration module for PoA sealers.
    Any contract that is used by sealers will inherit this contract

*/

contract Administration {

    // setting to private slightly decreases gas
    address private deployer;


    mapping (address => bool) private _sealers;

    modifier nonRegisteredSealer(address _sealer) {
        require(!_sealers[_sealer]);
        _;
    }

    modifier registeredSealer(address _sealer) {
        require(_sealers[_sealer]);
        _;
    }

    modifier onlySealers() {
        require(_sealers[msg.sender]);
        _;
    }

    modifier onlyDeployer() {
        require(msg.sender == deployer);
        _;
    }

    function Administration() {
        deployer = msg.sender;
    }

    function addSealer(
        address _sealerAddress)
        public
        onlyDeployer
        nonRegisteredSealer(_sealerAddress)
        returns (bool)
    {
        _sealers[_sealerAddress] = true;
        return true;
    }

    function removeSealer(
        address _sealerAddress)
        public
        onlyDeployer
        registeredSealer(_sealerAddress)
        returns (bool)
    {
        _sealers[_sealerAddress] = false;
        return true;
    }

    function getSealerStatus(
        address _sealerAddress)
        public
        view
        returns (bool)
    {
        return _sealers[_sealerAddress];
    }

}
