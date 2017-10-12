pragma solidity ^0.4.11;

import "zeppelin-solidity/contracts/token/BurnableToken.sol";
/**
 * @title Expanded BurnableToken with an Approval system.
 *
 * @dev This token expands BurnableToken such that other accounts (such as Smart Contracts)
 * @dev can burn (at most a certain amount of) tokens owned by you.
 */
contract ApprovedBurnableToken is BurnableToken {

    // List whom allows whom to irrevocably spend so much tokens from their balance.
    mapping (address => mapping (address => uint256)) internal allowedBurning;

    event BurnFrom(address indexed owner, // The address whose tokens were burned.
                  address indexed burner, // The address that executed the `burnFrom` call
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
    function burnFrom(address _owner, uint256 _value) public {
        require(_value > 0);
        require(_value <= balances[_owner]);
        require(_value <= allowedBurning[_owner][msg.sender]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        address burner = msg.sender;
        balances[_owner] = balances[_owner].sub(_value);
        allowedBurning[_owner][burner] = allowedBurning[_owner][burner].sub(_value);
        totalSupply = totalSupply.sub(_value);

        BurnFrom(_owner, burner, _value);
        Burn(_owner, _value);
    }

    /* /\** */
    /*  * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender. */
    /*  * */
    /*  * Beware that changing an allowance with this method brings the risk that someone may use both the old */
    /*  * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this */
    /*  * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards: */
    /*  * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729 */
    /*  * */
    /*  * Therefore, using `increaseApproval` and `decreaseApproval` instead is advised. */
    /*  * */
    /*  * @param _burner The address which will spend the funds. */
    /*  * @param _value The amount of tokens to be spent. */
    /*  *\/ */
    /* function approveBurn(address _burner, uint256 _value) public returns (bool) { */
    /*     allowedBurning[msg.sender][_burner] = _value; */
    /*     BurnApproval(msg.sender, _burner, _value); */
    /*     return true; */
    /* } */

    /* /\** */
    /*  * approve might be called when allowedBurning[_burner] == 0. To increment */
    /*  * allowed value is better to use this function to avoid two calls (and wait until */
    /*  * the first transaction is mined) */
    /*  * */
    /*  * Adapted from MonolithDAO Token.sol */
    /*  *\/ */
    /* function increaseBurnApproval (address _burner, uint _addedValue) public returns (bool success) { */
    /*     allowedBurning[msg.sender][_burner] = allowedBurning[msg.sender][_burner].add(_addedValue); */
    /*     Approval(msg.sender, _burner, allowedBurning[msg.sender][_burner]); */
    /*     return true; */
    /* } */

    /* function decreaseBurnApproval (address _burner, uint _subtractedValue) public returns (bool success) { */
    /*     uint oldValue = allowedBurning[msg.sender][_burner]; */
    /*     if (_subtractedValue > oldValue) { */
    /*         allowedBurning[msg.sender][_burner] = 0; */
    /*     } else { */
    /*         allowedBurning[msg.sender][_burner] = oldValue.sub(_subtractedValue); */
    /*     } */
    /*     BurnApproval(msg.sender, _burner, allowedBurning[msg.sender][_burner]); */
    /*     return true; */
    /* } */
}
