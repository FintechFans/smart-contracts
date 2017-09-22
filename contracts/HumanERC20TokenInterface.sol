pragma solidity ^0.4.11;
import "./ERC20TokenInterface.sol";
/**
   An extended version of the ERC20 Interface,
   which specifies the Token `name`, `symbol` and amount of `decimal`s.
*/
contract HumanERC20TokenInterface is ERC20TokenInterface {
    string public name;
    string public symbol;
    uint8 public decimals;

    function HumanERC20TokenInterface(string _name, string _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }
}
