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
    /* mapping (address => mapping (address => uint256)) internal allowed; */

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
        require(_value <= allowed[_owner][msg.sender]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        address burner = msg.sender;
        balances[_owner] = balances[_owner].sub(_value);
        allowed[_owner][burner] = allowed[_owner][burner].sub(_value);
        totalSupply = totalSupply.sub(_value);

        BurnFrom(_owner, burner, _value);
        Burn(_owner, _value);
    }
}
