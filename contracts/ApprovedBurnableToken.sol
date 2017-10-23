pragma solidity ^0.4.11;

import "zeppelin-solidity/contracts/token/BurnableToken.sol";
/**
   @title Expanded BurnableToken with an Approval system.

   @dev This token expands BurnableToken such that other accounts (such as Smart Contracts)
   @dev can burn (at most a certain amount of) tokens owned by you.
   @dev To approve someone to burn some of your tokens, you should call `approve`.
   @dev This allows them to either `transferFrom(your_address, amount_of_tokens)` or `burnFrom(your_address, amount_of_tokens)`.
*/
contract ApprovedBurnableToken is BurnableToken {

        /**
           Sent when `burner` burns some `value` of `owners` tokens.
        */
        event BurnFrom(address indexed owner, // The address whose tokens were burned.
                       address indexed burner, // The address that executed the `burnFrom` call
                       uint256 value           // The amount of tokens that were burned.
                );

        /**
           @dev Burns a specific amount of tokens of another account that `msg.sender`
           was approved to burn tokens for using `approveBurn` earlier.
           @param _owner The address to burn tokens from.
           @param _value The amount of token to be burned.
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
