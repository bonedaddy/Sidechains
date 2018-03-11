# Postables-Sidechains (PChains) - WIP

Repository intended for experimentating with linking up a private ethereum network, to the main ethereum network. No claims are made to the "security" and "decentralization" of using this setup. There are pros and cons that one has to make when using a setup like this. While anyone on the private network can use the smart contracts to submit "proposals" to exchange assets to the main network, only the pre-defined sealers for the PoA network are able to authorize those transactions, broadcasting a transaction to a smart contract on the main ethereum network, which then transfers the mainnet assets to the private network users associated mainnet ethereum address.

The actual work is done in a private repository I maintain, which is periodically synced with this one.

Do note that only the data bridge is tested.

# File Explanation:

`solidity/Payload/PayloadAccumulator.sol` - Used on main chain to accumulate the data swap payloads sent by relayers
`solidity/Bridges/PrivateDataBridge.sol` - Used on private chain to submit data payloads that you wish to be sent to main chain contracts
`solidity/Bridges/PrivateTokenBridge.sol` - Used on private chain to submit token swaps to the main chain
`solidity/Sealers.sol` - Used on private chain to track sealers, and authorize usage of functions on dependent contracts.
`solidity/Relayers.sol` - Used on main chain to authorize usage of functions on contracts such as the Payload Accumulator

`python/Relayer.py` - Used to watch for data swap approvals on the private chain, and forward them to the main chain
`python/PrivateDataBridge.py` - USed to watch for data swap proposals on the private chain and approve them
`python/Modules/IpfsModule.py` - Used to interact with IPFS
`python/Modules/Bridge.py` - Bridge logic
`python/Modules/Listener.py` - Used to listen to contract for events and optionally interact with them

# Usage Instructions:

## Usage Instructions - Factory.sol

`solidity/Factory.sol` can be used to generate the Private Data Bridge contract, Private Token Bridge Contract, and the Sealers contract for your private ethereum network.

Do note that until the MVP is complete you will have to fill out the various fields in the appropriate contracts (Payload Accumulator, Token Bridge, Sealers) and replace the hardcoded bytecode in the Factory file.

After deploying the factory, the first contract you should deploy is the Sealers contract. Afterwards you can deploy the data bridge or the token bridge, etiher one is fine.

## Usage Instructions - PrivateDataBridge.sol

`solidity/PrivateDataBridge.sol`Nothing special needed to be done here, just make sure to update the yaml config file. 

# Architecture

The overall architecture follows a "relay" principle, in which anyone who has locked up the appropriate amount of mainnet ethereum as a stake, and incentivization method to help deter malicious actors, act as relays. Relays are used to relay data between the mainnet and private networks. Data from here on out can either refer to tokens, tokenized assets, or data payloads. Data payloads is the "data" included in `msg.data` when transactions are made to contracts. The goal behind this is to allow the execution of mainnet contract functions from the private network, or the execution of private network contract functions from the mainnet.

The Architecture section will be broken up into two parts, one part detailing the relaying of tokens, and other similar assets. The second part will deal with the reelaying of data payloads. 

There will be two relays, one for data payloads, and one for token/asset swaps.

PChains utilize the following software suites, protocols, technologies, etc:
- IPFS
- Ethereum Mainnet
- Ethereum Private Networks (Clique, PoA)
- Python
- Solidity
- web3
- geth
- whisper

While inefficient, at first coordination will be done through smart contracts and web3 python programs. This will be abandon in the future for a more effective solution

# Architecture - Current Limitations

Single node relay

## Architecture: Data Paylods

There will be a contract on the private network, which users can use to send data payloads to a particular contract on the mainnet. When the data payload is submitted to the contract, and event will be broadcast containing the payload. Relay's will pick this up on a first come first serve basis (this is highly inefficient, and will be improved over time), and submit three pieces of data to IPFS (If a relay detects that the original copy of the data payload was already uploaded, it will cease further processing).

1) An *exact* copy of the data paylaod
2) A copy of the data payload signed with the relays private ethereum network address
3) A copy of the data payload signed with the relays public ethereum network address

The relay will then construct a transaction, and submit it to the payload accumulator on the mainnet. The data payload will be held in the accumulator an time `T`. Until time `T` has passed, *anyone* may submit a fraud proof to the accumulator, proving that the data paylaod passed on by the relayer, was fradulent. To mitigate spam attacks, and abuse, a temporary deposit will be made. If the fraud proof attempt was invalid, the deposit will be distributed to the various relayers. In such a situation in which malicious payload data was relayed, the node that relayed the data will be removed from the network as a node, and the ethereum that was staked to become a relayer will be awarded to the submitter of the fraud proof, along with the submitters temporary deposit.

After a relay has sent a transaction to the payload accumulator, an event will be sent out, notifying all relayers, upon which they will download the original versin of the data payload which was uploaded to IFPS, and pin it locally for persistent storage.


### Architecture: Data Payload Ipfs Files

To allow anyone to verify the payload of the fle, a record will be published to IPFS as a file with the following format:

mAddress: 	....
mContract:	....
payload:	....


- "mAddress" is the address which has deposited funds into the payload collector contract to pay for the payload transfer (aka function execution)
- "mContract" is the target contract to which the payload is to be delivered
- "payload" is the data payload to be sent the contract to trigger a function call


# How To

```
compiles
solc blah="." Bridges/PrivateDataBridge.sol
```


# To Do

the data brdge lets the same swap proposal be used multiple times this needs to be fixed

decouple user from payload accumulator so we can upgrade accumulator without touching the user records