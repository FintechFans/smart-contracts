/*
A token that can only be traded after its minting procedure has finished.
*/

import "zeppelin-solidity/contracts/token/MintableToken.sol";

contract UnlockedAfterMintingToken is MintableToken {

    modifier whenMintingFinished() {
        require(mintingFinished);
        _;
    }

    function transfer(address _to, uint256 _value) public whenMintingFinished returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public whenMintingFinished returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public whenMintingFinished returns (bool) {
        return super.approve(_spender, _value);
    }

    function increaseApproval(address _spender, uint _addedValue) public whenMintingFinished returns (bool success) {
        return super.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public whenMintingFinished returns (bool success) {
        return super.decreaseApproval(_spender, _subtractedValue);
    }
}
