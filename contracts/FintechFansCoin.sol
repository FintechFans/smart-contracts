pragma solidity ^0.4.11;
import "./HumanERC20TokenInterface.sol";
/**
   An extended version of the ERC20 Interface,
   which specifies the Token `name`, `symbol` and amount of `decimal`s.
*/
contract FintechFansCoin is HumanERC20TokenInterface {
    function FintechFansCoin()
        HumanERC20TokenInterface("FintechFansCoin", "FFC", 18)
    {
    }
}
