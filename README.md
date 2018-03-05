# Postables-Sidechains (PChains) - WIP

Repository intended for experimentating with linking up a private ethereum network, to the main ethereum network. No claims are made to the "security" and "decentralization" of using this setup. There are pros and cons that one has to make when using a setup like this. While anyone on the private network can use the smart contracts to submit "proposals" to exchange assets to the main network, only the pre-defined sealers for the PoA network are able to authorize those transactions, broadcasting a transaction to a smart contract on the main ethereum network, which then transfers the mainnet assets to the private network users associated mainnet ethereum address.

If one has their own private network, there currently exists very few ways to transfer various assets between the different networks. While technologies like Plasma are incredibly promising, if the private (or side chain) is not intended for public consumption, say, an organizations personal ethereum network, one doesn't neccessarily need the benefits that a decentralized technology like plasma offers, that combined with the fact that production ready Plasma implementations aren't here, but production ready private ethereum networks are being used is what inspired me to work on this project.

The actual work is done in a private repository I maintain, which is periodically synced with this one.

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

## Architecture: Data Paylods

There will be a contract on the private network, which users can use to send data payloads to a particular contract on the mainnet. When the data payload is submitted to the contract, and event will be broadcast containing the payload. Relay's will pick this up on a first come first serve basis (this is highly inefficient, and will be improved over time), and submit three pieces of data to IPFS (If a relay detects that the original copy of the data payload was already uploaded, it will cease further processing).

1) An *exact* copy of the data paylaod
2) A copy of the data payload signed with the relays private ethereum network address
3) A copy of the data payload signed with the relays public ethereum network address

The relay will then construct a transaction, and submit it to the payload accumulator on the mainnet. The data payload will be held in the accumulator an time `T`. Until time `T` has passed, *anyone* may submit a fraud proof to the accumulator, proving that the data paylaod passed on by the relayer, was fradulent. To mitigate spam attacks, and abuse, a temporary deposit will be made. If the fraud proof attempt was invalid, the deposit will be distributed to the various relayers. In such a situation in which malicious payload data was relayed, the node that relayed the data will be removed from the network as a node, and the ethereum that was staked to become a relayer will be awarded to the submitter of the fraud proof, along with the submitters temporary deposit.

After a relay has sent a transaction to the payload accumulator, an event will be sent out, notifying all relayers, upon which they will download the original versin of the data payload which was uploaded to IFPS, and pin it locally for persistent storage.
