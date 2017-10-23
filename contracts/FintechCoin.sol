pragma solidity ^0.4.11;


import "zeppelin-solidity/contracts/token/MintableToken.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";

import "./ApprovedBurnableToken.sol";
import "./UnlockedAfterMintingToken.sol";

/**
   The FintechCoin is the coin used by the FintechFans platforms and services.

   It is its own separate cryptocurrency to ensure that fluctuations in prices of other cryptocurrencies
   do not (strongly) affect the prices of the Fintech services that use it.

   FintechCoin has the following properties:

   - It follows the ERC20 interface, meaning that you can use it from any ERC20-compliant Ethereum client in an easy way.
   - This also means that any tools that work well with ERC20 tokens will work with the FintechCoin.
   - It is Burnable, meaning that you can destroy some of it, with everyone in the network being able to check that this has occurred.
   - You can `approve' another party to use (either transfer or burn) a certain amount of your FintechCoin.
   - This, in combination with the burning is used to allow certain smart contracts to spend (burn) some of your tokens when certain actions are executed.

   FintechCoin is abbreviated as FINC.
   FintechCoin can be subdivided to 18 decimal places. (The smallest expressible denomination is 1 * 10^(-18) FINC).

   FintechCoin can only be used once Minting is completed.
   When the contract is created, minting can be done by the owner of the FintechCoin contract.
   This is the method that will be used to give out FintechCoin to companies participating in the presale.

   After this, the ownership of the FintechCoin will be moved to the FintechFansCrowdsale contract.
   This contract will mint FintechCoin when a corresponding amount of Ether is sent to it. (And will mint only then).
   Minting will be completed by the FintechFansCrowdsale contract once the crowdsale has finished.
*/
contract FintechCoin is UnlockedAfterMintingToken, ApprovedBurnableToken {
        /**
           We do not expect this to change ever after deployment,
           but it is a way to identify different versions of the FintechCoin during development.
        */
        uint8 public constant contractVersion = 1;

        string public constant name = "FintechCoin";
        string public constant symbol = "FINC";
        uint8 public constant decimals = 18;

        // TODO extractToken function to allow people to retrieve token-funds sent here by mistake.

        // TODO ERC223-interface
}
