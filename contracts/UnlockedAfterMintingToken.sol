pragma solidity ^0.4.11;


import "zeppelin-solidity/contracts/token/MintableToken.sol";
/**
   @title the UnlockedAfterMintingToken is a token that can only be traded after its minting procedure has finished.
*/

contract UnlockedAfterMintingToken is MintableToken {

    /**
       Ensures certain calls can only be made when minting is finished.

       The calls that are restricted are any calls that allow direct or indirect transferral of funds.
     */
    modifier whenMintingFinished() {
        require(mintingFinished);
        _;
    }

    function transfer(address _to, uint256 _value) public whenMintingFinished returns (bool) {
        return super.transfer(_to, _value);
    }

    /**
      @dev Transfer tokens from one address to another
      @param _from address The address which you want to send tokens from
      @param _to address The address which you want to transfer to
      @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public whenMintingFinished returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    /**
      @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
      @dev NOTE: This call is considered deprecated, and only included for proper compliance with ERC20.
      @dev Rather than use this call, use `increaseApproval` and `decreaseApproval` instead, whenever possible.
      @dev The reason for this, is that using `approve` directly when your allowance is nonzero results in an exploitable situation:
      @dev https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

      @param _spender The address which will spend the funds.
      @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public whenMintingFinished returns (bool) {
        return super.approve(_spender, _value);
    }

    /**
      @dev approve should only be called when allowed[_spender] == 0. To alter the
      @dev allowed value it is better to use this function, because it is safer.
      @dev (And making `approve` safe manually would require making two calls made in separate blocks.)

      This method was adapted from the one in use by the MonolithDAO Token.
     */
    function increaseApproval(address _spender, uint _addedValue) public whenMintingFinished returns (bool success) {
        return super.increaseApproval(_spender, _addedValue);
    }

    /**
       @dev approve should only be called when allowed[_spender] == 0. To alter the
       @dev allowed value it is better to use this function, because it is safer.
       @dev (And making `approve` safe manually would require making two calls made in separate blocks.)

       This method was adapted from the one in use by the MonolithDAO Token.
    */
    function decreaseApproval(address _spender, uint _subtractedValue) public whenMintingFinished returns (bool success) {
        return super.decreaseApproval(_spender, _subtractedValue);
    }

    // TODO Prevent burning?
}
