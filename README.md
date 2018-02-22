# FintechFans Smart Contracts

This repository contains the Smart Contracts that are in use by the FintechFans Marketplace and the Decentralized Crowdsale leading up to it.

The Smart Contract source code can be found in 'contracts/'.
The `flatten_contracts.sh` script is used to combine them together into the `FintechFansCrowdsaleFlattened.sol` file, which is the Solidity file that is deployed on the blockchain.

The reason to combine everything together in one file like this, is to be able to upload it to Etherscan for source code verification.



## Technical Details



### Crowdsale Procedure

- Presale is held.
- FintechCoin contract is deployed.
- Amounts from presale are minted by admins.
  - Amounts for beneficiaries are minted in the proper amounts by admins as well.
- FintechFansCrowdsale contract is deployed, with the address of the token contract, the amount of tokens sold in the presale and the token price in wei as parameters.
- Admins transfer FintechCoin contract ownership to FintechFansCrowdsale contract.
- Crowdsale begins once startTime has passed.
  - When someone sends Ether to the FintechFansCrowdsale contract, the current number of sold tokens is used to decide how many bonus tokens are created for this person.
- Crowdsale ends once endTime has passed.
  - If less than the minimum goal of tokens was purchased, people are able to extract their sent Ether.
  - If more than the minimum goal of tokens was purchased, the process continues:
  - Admins then finalize the crowdsale, which: 
    - Extracts the stored Ether.
    - Sets the `mintable` property of the FintecCoin contract to false, which also means that from that point onward, tokens can be traded and used.
