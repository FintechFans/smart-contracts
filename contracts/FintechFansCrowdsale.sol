pragma solidity ^0.4.11;
/* Prevent overfow/underflow of arithmetic: */
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

/* Restrict certain actions to only the contract's owner: */
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

/* Restrict certain actions to only the contract's owner: */
import 'zeppelin-solidity/contracts/crowdsale/CappedCrowdsale.sol';
import 'zeppelin-solidity/contracts/crowdsale/RefundableCrowdsale.sol';

/* Reference to the FintechFansCoin contract, whose tokens are sold. */
import './FintechFansCoin.sol';

contract Pausable {
}

contract FintechFansCrowdsale is RefundableCrowdsale, CappedCrowdsale {
    uint256 tokenDecimals = 18;

    FintechFansCoin tokenContract;
    address public foundersWallet;

    function FintechFansCrowdsale (
        uint256 _startTime,
        uint256 _endTime,
        uint256 _rate,
        address _wallet,
        address _foundersWallet,
        uint256 _goal,
        uint256 _cap,
        FintechFansCoin _token
        )
        Crowdsale(_startTime, _endTime, _rate, _wallet)
        RefundableCrowdsale(_goal)
        CappedCrowdsale(_cap)
    {
        require(_goal < _cap);

        foundersWallet = _foundersWallet;
        token = _token;
    }


/*       TODO override createTokenContract()! */

    /*
      Overridden version of Crowdsale.buyTokens because:
      - The Wei->FFC rate depends on how many tokens have already been sold.
      - Also mint tokens sent to FintechFans and the Founders at the same time.
    */
    function buyTokens(address beneficiary) public payable {
        require(beneficiary != 0x0);
        require(validPurchase());

        uint256 weiAmount = msg.value;

        // calculate token amount to be created
        uint256 tokens = weiAmount.mul(rate);
        tokens = tokens.mul(currentBonusRate()).div(100);

        // update state
        weiRaised = weiRaised.add(weiAmount);

        // Mint tokens for beneficiary
        token.mint(beneficiary, tokens);
        TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

        // Mint tokens for FintechFans and Founders
        uint256 fintechfans_tokens = tokens.mul(/*0.*/8).div(10);
        uint256 founders_tokens = tokens.mul(/*0.*/2).div(10);
        token.mint(wallet, fintechfans_tokens);
        token.mint(foundersWallet, founders_tokens);/* TODO Locked vault, split */

        forwardFunds();
    }

    /*
      Returns a fixed-size number that is 100 * the bonus amount.
     */
    function currentBonusRate() public returns (uint) {
        /* TODO check how `rate' is used. */
        if(weiRaised < (1000000 * tokenDecimals) / rate) return 125/*.25*/; // 20% discount
        if(weiRaised < (2000000 * tokenDecimals) / rate) return 118/*.1764705882352942*/; // 15% discount
        if(weiRaised < (4000000 * tokenDecimals) / rate) return 111/*.1111111111111112*/; // 10% discount
        if(weiRaised < (5000000 * tokenDecimals) / rate) return 105/*.0526315789473684*/; // 5% discount
        return 100; // Should never happen, as 5 million is hard cap.
    }



}
