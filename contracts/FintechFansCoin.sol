pragma solidity ^0.4.11;
/* import "./HumanERC20TokenInterface.sol"; */
/**
   An extended version of the ERC20 Interface,
   which specifies the Token `name`, `symbol` and amount of `decimal`s.
*/
/* contract FintechCoin is HumanERC20TokenInterface { */
/*     function FintechCoin() */
/*         HumanERC20TokenInterface("FintechCoin", "FFC", 18) */
/*     { */
/*     } */
/* } */

import "zeppelin-solidity/contracts/token/MintableToken.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";

import "./ApprovedBurnableToken.sol";

contract FintechCoin is Ownable, MintableToken, ApprovedBurnableToken {
    uint8 public constant contractVersion = 1;

    string public constant name = "FintechCoin";
    string public constant symbol = "FINC";
    uint8 public constant decimals = 18;


    // TODO extractToken function to allow people to retrieve token-funds sent here by mistake.

    // TODO ERC223-interface
}
