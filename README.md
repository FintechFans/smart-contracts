# FintechFans Smart Contracts

This repository contains the Smart Contracts that are in use by the FintechFans Marketplace and the Decentralized Crowdsale leading up to it.

## Testing

Testing is done using Truffle, by running `yarn truffle test`. This does expect that a local testing  'blockchain' is running, wich can be started (with enough Ether in the test accounts to allow for the test transactions to all succeed) using `yarn run rpc` .

## Building + Deploying

The exact building and deployment process can be found and tracked in `FintechFansCrowdsale deployment steps.ods`.

Because it is difficult to verify a contract on EtherScan that has parameters you can fill in, the crowdsale-contract that will be deployed is `TheFintechFansCrowdsale`, which is a very simple wrapper of `FintechFansCrowdsale`, which fills in the arguments that the FintechFansCrowdsale contract requires.

The `flatten_fintech_coin.sh` and `flatten_the_fintech_fans_crowdsale.sh` scripts are used to combine them together into the `flattened_contracts/TheFintechCoin.sol` and `flattened_contracts/TheFintechFansCrowdsaleFlattened.sol` file, which is the Solidity file that is deployed on the blockchain.

The reason to combine everything together in flat files like this, is to be able to upload it to Etherscan for source code verification.

For this flattening process, [solc](https://solidity.readthedocs.io/en/develop/installing-solidity.html#binary-packages) and [solidity-flattener](https://github.com/BlockCatIO/solidity-flattener) are required.


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
    - Sets the `mintable` property of the FintechCoin contract to false, which also means that from that point onward, tokens can be traded and used.
