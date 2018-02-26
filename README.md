# What is this?

Repository intended for experimentating with linking up a private ethereum network, to the main ethereum network. No claims are made to the "security" and "decentralization" of using this setup. There are pros and cons that one has to make when using a setup like this. While anyone on the private network can use the smart contracts to submit "proposals" to exchange assets to the main network, only the pre-defined sealers for the PoA network are able to authorize those transactions, broadcasting a transaction to a smart contract on the main ethereum network, which then transfers the mainnet assets to the private network users associated mainnet ethereum address.

If one has their own private network, there currently exists very few ways to transfer various assets between the different networks. While technologies like Plasma are incredibly promising, if the private (or side chain) is not intended for public consumption, say, an organizations personal ethereum network, one doesn't neccessarily need the benefits that a decentralized technology like plasma offers, that combined with the fact that production ready Plasma implementations aren't here, but production ready private ethereum networks are being used is what inspired me to work on this project.

The actual work is done in a private repository I maintain, which is periodically synced with this one.
