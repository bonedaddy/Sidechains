pragma solidity 0.4.20;

contract Sealers {
 
 	/*
		this is a hard coded address, and is supposed to be the first sealer of the network
		the singularity node is what signs the messages to be submitted by sealers
		for authorization of transfers to the mainnet

		this is then picked up by one of the authorized bridge programs that then pushes the transaction
		to the mainnet. these authorized bridges are ran by all the sealers. This is an extremely basic
		way of allowing a distributed method of submitting transactions to the main network. This will
		be refined as time goes on.
 	*/
	address constant public singularity = address(0);

	enum SealerStates { pending, active, disabled }

	struct SealerStruct {
		bytes32 id;
		uint256 forgedDate;
		SealerStates state;
	}

	mapping (address => SealerStruct) public sealers;

	modifier onlySingularity() {
		require(msg.sender == singularity);
		_;
	}

	modifier onlySealers() {
		require(sealers[msg.sender].state == SealerStates.active);
		_;
	}

}