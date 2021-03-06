pragma solidity ^0.4.13;

import '../../contracts/ApprovedBurnableToken.sol';

contract ApprovedBurnableTokenMock is ApprovedBurnableToken {

    function ApprovedBurnableTokenMock(address initialAccount, uint initialBalance) public {
        balances[initialAccount] = initialBalance;
        totalSupply = initialBalance;
    }
}
