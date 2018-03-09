pragma solidity 0.4.20;

/*

	Used to quickly deploy  contracts on testnetworks
*/
contract Factory {

	bytes constant private PTBRIDGE = hex"606060405260408051908101604052601c81527f19457468657265756d205369676e6564204d6573736167653a0a3332000000006020820152600090805161004b9291602001906100f8565b50341561005757600080fd5b33600160a060020a038116632aea4d216000604051602001526040518163ffffffff167c0100000000000000000000000000000000000000000000000000000000028152600401602060405180830381600087803b15156100b757600080fd5b6102c65a03f115156100c857600080fd5b505050604051805160028054600160a060020a031916600160a060020a0392909216919091179055506101939050565b828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f1061013957805160ff1916838001178555610166565b82800160010185558215610166579182015b8281111561016657825182559160200191906001019061014b565b50610172929150610176565b5090565b61019091905b80821115610172576000815560010161017c565b90565b6105c8806101a26000396000f3006060604052600436106100695763ffffffff60e060020a600035041663105ba5c9811461006e57806367640798146100b05780639695786914610119578063b3eee34814610157578063b7ef7bf51461016a578063c2bc153b14610189578063c7b25f0b1461019c575b600080fd5b341561007957600080fd5b61009c600160a060020a03600435811690602435811690604435166064356101be565b604051901515815260200160405180910390f35b34156100bb57600080fd5b6100d2600160a060020a03600435166024356102b3565b604051600160a060020a03968716815294861660208601529285166040808601919091529190941660608401526080830193909352151560a082015260c001905180910390f35b341561012457600080fd5b61013b60043560ff60243516604435606435610306565b604051600160a060020a03909116815260200160405180910390f35b341561016257600080fd5b61013b61037f565b341561017557600080fd5b61009c600160a060020a036004351661038e565b341561019457600080fd5b61013b610441565b34156101a757600080fd5b61009c600160a060020a0360043516602435610450565b33600160a060020a038181166000818152600360208181526040808420438086529252808420805473ffffffffffffffffffffffffffffffffffffffff19908116909617815560018101805487168d891617905560028101805487168c8916179055928301805490951695891695909517909355600401859055927f5f8dc97c0d59edb105e60b8788461fd97c1ea2902afbaea0ee695e4e989a67f692909188918891889188919051600160a060020a0396871681529486166020860152928516604080860191909152919094166060840152608083019390935260a082015260c001905180910390a1506001949350505050565b60036020818152600093845260408085209091529183529120805460018201546002830154938301546004840154600590940154600160a060020a03938416959284169492841693909116919060ff1686565b60006001858585856040516000815260200160405260006040516020015260405193845260ff90921660208085019190915260408085019290925260608401929092526080909201915160208103908084039060008661646e5a03f1151561036d57600080fd5b50506020604051035195945050505050565b600254600160a060020a031681565b600254600090600160a060020a031663c1779b6b33836040516020015260405160e060020a63ffffffff8416028152600160a060020a039091166004820152602401602060405180830381600087803b15156103e957600080fd5b6102c65a03f115156103fa57600080fd5b50505060405180519050151561040f57600080fd5b5060028054600160a060020a03831673ffffffffffffffffffffffffffffffffffffffff199091161790556001919050565b600154600160a060020a031681565b6002546000908190819081908190600160a060020a031663c1779b6b33836040516020015260405160e060020a63ffffffff8416028152600160a060020a039091166004820152602401602060405180830381600087803b15156104b357600080fd5b6102c65a03f115156104c457600080fd5b5050506040518051905015156104d957600080fd5b50505050600160a060020a0383811660009081526003602081815260408084208785529091529182902060018082015460028301549383015460048401546005909401805460ff1916909317909255851694928316939216917fdacfa93c38260000f71c29bca2ec6ba975cb1b1a2ee2123b35119d9c93ebb3b390859085908590859051600160a060020a039485168152928416602084015292166040808301919091526060820192909252608001905180910390a150600196955050505050505600a165627a7a72305820c820737cda48579db7cd2f5ed9b112f5a7674a83b7559837192a6f846801a9a50029";
	bytes constant private BDBRIDGE = hex"60606040526000805460a060020a60ff0219169055341561001f57600080fd5b33600160a060020a038116632aea4d216000604051602001526040518163ffffffff167c0100000000000000000000000000000000000000000000000000000000028152600401602060405180830381600087803b151561007f57600080fd5b6102c65a03f1151561009057600080fd5b505050604051805160008054600160a060020a03909216600160a060020a031990921691909117905550506107d1806100ca6000396000f3006060604052600436106100485763ffffffff60e060020a600035041663396836d2811461004d57806390ac6170146100ca578063bccf31c9146101b0578063ef9fa9cd146101cf575b600080fd5b341561005857600080fd5b6100b6600160a060020a036004803582169160248035909116919060649060443590810190830135806020601f820181900481020160405190810160405281815292919060208401838380828437509496506101f195505050505050565b604051901515815260200160405180910390f35b34156100d557600080fd5b6100ec600160a060020a036004351660243561039b565b604051600160a060020a038087168252858116602083015284166040820152606081016080820183600281111561011f57fe5b60ff1681526020838203810183528554600260018216156101000260001901909116049082018190526040909101908590801561019d5780601f106101725761010080835404028352916020019161019d565b820191906000526020600020905b81548152906001019060200180831161018057829003601f168201915b5050965050505050505060405180910390f35b34156101bb57600080fd5b6100b6600160a060020a03600435166103e3565b34156101da57600080fd5b6100b6600160a060020a0360043516602435610494565b33600160a060020a0390811660008181526001602081815260408084204385529091528220805473ffffffffffffffffffffffffffffffffffffffff19908116909417815590810180548416888616179055600281018054909316938616939093179091559060030182805161026b9291602001906106f8565b506000805433600160a060020a0316825260016020818152604080852043865290915290922060040180547401000000000000000000000000000000000000000090920460ff1692909160ff1916908360028111156102c657fe5b02179055507f38439aa7c5b71ce5226a841d2bab43a8506fa6eb09df3662d06012b00cc2fd223384858543604051600160a060020a0380871682528581166020830152841660408201526080810182905260a06060820181815290820184818151815260200191508051906020019080838360005b8381101561035357808201518382015260200161033b565b50505050905090810190601f1680156103805780820380516001836020036101000a031916815260200191505b50965050505050505060405180910390a15060019392505050565b6001602081815260009384526040808520909152918352912080549181015460028201546004830154600160a060020a03948516949283169392909116916003019060ff1685565b60008054600160a060020a031663c1779b6b33836040516020015260405160e060020a63ffffffff8416028152600160a060020a039091166004820152602401602060405180830381600087803b151561043c57600080fd5b6102c65a03f1151561044d57600080fd5b50505060405180519050151561046257600080fd5b5060008054600160a060020a03831673ffffffffffffffffffffffffffffffffffffffff199091161790556001919050565b60008060006104a1610776565b60008054600160a060020a03169063c1779b6b9033906040516020015260405160e060020a63ffffffff8416028152600160a060020a039091166004820152602401602060405180830381600087803b15156104fc57600080fd5b6102c65a03f1151561050d57600080fd5b50505060405180519050151561052257600080fd5b6001600160a060020a038716600090815260016020908152604080832089845290915290206004015460ff16600281111561055957fe5b5050600160a060020a0386811660009081526001602081815260408084208a855282529283902080830154600280830154600390930180549288169a509290961697509094610100938216159390930260001901169190910491601f83018290048202909101905190810160405280929190818152602001828054600181600116156101000203166002900480156106325780601f1061060757610100808354040283529160200191610632565b820191906000526020600020905b81548152906001019060200180831161061557829003601f168201915b505050505090507ffed9a57798ddc148dec713dfe3dfa086963fa4ee3247ad3ab3cf9f754150c680838383604051600160a060020a0380851682528316602082015260606040820181815290820183818151815260200191508051906020019080838360005b838110156106b0578082015183820152602001610698565b50505050905090810190601f1680156106dd5780820380516001836020036101000a031916815260200191505b5094505050505060405180910390a150600195945050505050565b828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f1061073957805160ff1916838001178555610766565b82800160010185558215610766579182015b8281111561076657825182559160200191906001019061074b565b50610772929150610788565b5090565b60206040519081016040526000815290565b6107a291905b80821115610772576000815560010161078e565b905600a165627a7a723058207c78228317f9d6f18a98be7a61edf3531e9f8c6be12946b72d5435eee452da7e0029";
	bytes constant private SEALERS = hex"606060405260018055670853a0d2313c0000600255341561001f57600080fd5b600160405160ff919091167f010000000000000000000000000000000000000000000000000000000000000002815260010160405190819003902073c3d2aa21caa190aee4f70f8359d96f6d3c5dad9c60005260036020527f299403843bc17600e30e583257c72874161fb8c4ba30d648f3f9dc7199d57cbc55427f299403843bc17600e30e583257c72874161fb8c4ba30d648f3f9dc7199d57cbd557f299403843bc17600e30e583257c72874161fb8c4ba30d648f3f9dc7199d57cbe80546001919060ff19168280021790555061052a806100fd6000396000f3006060604052600436106100985763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416632d2da911811461009d5780633d7ee588146100c25780635bf1cd89146100f55780636b0178701461012757806396c1d6cd1461013a578063a0e685e714610159578063a5dca4641461016c578063aa61aef31461017f578063c1779b6b146101d1575b600080fd5b34156100a857600080fd5b6100b06101f0565b60405190815260200160405180910390f35b34156100cd57600080fd5b6100e1600160a060020a03600435166101f6565b604051901515815260200160405180910390f35b341561010057600080fd5b61010b60043561020b565b604051600160a060020a03909116815260200160405180910390f35b341561013257600080fd5b6100b0610233565b341561014557600080fd5b6100e1600160a060020a0360043516610239565b341561016457600080fd5b6100b0610381565b341561017757600080fd5b61010b6103db565b341561018a57600080fd5b61019e600160a060020a03600435166103f3565b60405183815260208101839052604081018260028111156101bb57fe5b60ff168152602001935050505060405180910390f35b34156101dc57600080fd5b6100e1600160a060020a0360043516610417565b60025481565b60046020526000908152604090205460ff1681565b600080548290811061021957fe5b600091825260209091200154600160a060020a0316905081565b60015481565b60008033600160a060020a031673c3d2aa21caa190aee4f70f8359d96f6d3c5dad9c1461026557600080fd5b600180546102789163ffffffff61045d16565b600181905583904290604051600160a060020a03939093166c0100000000000000000000000002835260148301919091526034820152605401604051908190039020600160a060020a0384166000908152600360205260408120828155426001808301919091556002909101805460ff1916821790558154929350909190810161030283826104b4565b506000918252602090912001805473ffffffffffffffffffffffffffffffffffffffff1916600160a060020a0385161790557ffee4505406fe16269c951fef559ec9b3d752a12ba5897b70b63be36f309952d78382604051600160a060020a03909216825260208201526040908101905180910390a150600192915050565b60008060006103a3670de0b6b3a764000060015461047690919063ffffffff16565b91506103ba6002548361047690919063ffffffff16565b90506103d481670de0b6b3a764000063ffffffff61049d16565b9250505090565b73c3d2aa21caa190aee4f70f8359d96f6d3c5dad9c81565b60036020526000908152604090208054600182015460029092015490919060ff1683565b60006001600160a060020a038316600090815260036020526040902060029081015460ff169081111561044657fe5b141561045457506001610458565b5060005b919050565b60008282018381101561046f57600080fd5b9392505050565b6000828202831580610492575082848281151561048f57fe5b04145b151561046f57600080fd5b60008082848115156104ab57fe5b04949350505050565b8154818355818115116104d8576000838152602090206104d89181019083016104dd565b505050565b6104fb91905b808211156104f757600081556001016104e3565b5090565b905600a165627a7a723058209f325057016cea0743306d0dca1cc2acf54722ba2f36a09182a68e00da0c54180029";

	address public sealer;
	address public tbridge;
	address public dbridge;
	address[] public ptbridges;
	address[] public dbridges;
	address[] public sealers;

	event NewContract(address _addr);

	function deployPrivateTokenBridge() external {
		bytes memory _code = PTBRIDGE;
		address a;
		assembly {
			a := create(0, add(_code, 0x20), mload(_code))
		}
		NewContract(a);
		ptbridges.push(a);
		tbridge = a;
	}

	function deploySealers() external {
		bytes memory _code = SEALERS;
		address a;
		assembly {
			a := create(0, add(_code, 0x20), mload(_code))
		}
		NewContract(a);
		sealers.push(a);
		sealer = a;
	}

	function deployPrivateDataBridge() external {
		bytes memory _code = BDBRIDGE;
		address a;
		assembly {
			a := create(0, add(_code, 0x20), mload(_code))
		}
		NewContract(a);
		dbridges.push(a);
		dbridge = a;
	}
}