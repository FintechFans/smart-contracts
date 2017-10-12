pragma solidity ^0.4.11;
/* import "./HumanERC20TokenInterface.sol"; */
/**
   An extended version of the ERC20 Interface,
   which specifies the Token `name`, `symbol` and amount of `decimal`s.
*/
/* contract FintechFansCoin is HumanERC20TokenInterface { */
/*     function FintechFansCoin() */
/*         HumanERC20TokenInterface("FintechFansCoin", "FFC", 18) */
/*     { */
/*     } */
/* } */

import "zeppelin-solidity/contracts/token/MintableToken.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";

import "./ApprovedBurnableToken.sol";

contract FintechFansCoin is Ownable, MintableToken, BurnableToken {

    mapping (address => mapping (address => uint256)) internal allowedBurning;

    event BurnFor(address indexed owner,  // The address whose tokens were burned.
                  address indexed burner, // The address that executed the `burnFor` call
                  uint256 value           // The amount of tokens that were burned.
        );

    event BurnApproval(address indexed owner,  // The address that approved someone
                       address indexed burner, // The address that was approved
                       uint256 value           // The maximum amount that `burner` can burn of `owner`s funds.
        );

    /**
     * @dev Burns a specific amount of tokens of another account that `msg.sender`
     * was approved to burn tokens for using `approveBurn` earlier.
     * @param _owner The address to burn tokens from.
     * @param _value The amount of token to be burned.
     */
    function burnFor(address _owner, uint256 _value) public {
        require(_value > 0);
        require(_value <= balances[_from]);
        require(_value <= allowedBurning[_from][msg.sender])
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        address burner = msg.sender;
        balances[_from] = balances[_from].sub(_value);
        allowanceBurning[_from][burner] = allowanceBurning[_from][burner].sub(_value);
        totalSupply = totalSupply.sub(_value);

        BurnFor(_owner, burner, _value);
        Burn(_owner, _value);
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     *
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approveBurn(address _burner, uint256 _value) public returns (bool) {
        allowed[msg.sender][_burner] = _value;
        BurnApproval(msg.sender, _burner, _value);
        return true;
  }
}
