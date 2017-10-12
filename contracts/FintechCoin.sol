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
}
