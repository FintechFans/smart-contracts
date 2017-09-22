pragma solidity ^0.4.11;
/* Prevent overfow/underflow of arithmetic: */
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

/* Restrict certain actions to only the contract's owner: */
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

/* Restrict certain actions to only the contract's owner: */
import 'zeppelin-solidity/contracts/crowdsale/CappedCrowdsale.sol';

/* Reference to the FintechFansCoin contract, whose tokens are sold. */
import './FintechFansCoin.sol'

contract FintechFansCrowdsale is Ownable, CappedCrowdsale {
    public uint256 tokenDecimals = 18;
    /* Reference to the FintechFansCoin contract, whose tokens are sold. */
    FintechFansCoin tokenContract;
    address public foundersWallet;

    function FintechFansCrowdsale(
        uint256 _startTime,
        uint256 _endTime,
        uint256 _rate, // how many token units a buyer gets per Wei
        address _multisigWallet,
        address _foundersWallet,
        uint256 _cap
    )
        Crowdsale(_startTime, _endTime, rate, _multisigWallet)
        CappedCrowdsale(5000000 * tokenDecimals * _rate)
    {
        foundersWallet = _foundersWallet;
    }


    /*
      Overridden version of Crowdsale.buyTokens because:
      - The Wei->FFC rate depends on where we are inside the Crowdsale time range.
     */
    function buyTokens(address beneficiary) public payable {
        require(beneficiary != 0x0);
        require(validPurchase());

        uint256 weiAmount = msg.value;

        // calculate token amount to be created
        uint256 tokens = weiAmount.mul(rate);
        tokens = tokens.mul(currentBonusRate());

        // update state
        weiRaised = weiRaised.add(weiAmount);

        // Send tokens to beneficiary
        token.mint(beneficiary, tokens);
        TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

        // Send tokens to FintechFans and Founders
        uint256 fintechfans_tokens = tokens.mul(0.8);
        uint256 founders_tokens = tokens.mul(0.2);
        token.mint(multisigWallet, fintechfans_tokens);
        token.mint(foundersWallet, tokens.mul(0.2));/* TODO Locked vault, split */

        forwardFunds();
  }

    function currentBonusRate() public constant {
        /* TODO check how `rate' is used. */
        if(weiRaised < (1000000 * tokenDecimals) / rate) return 1.25; // 20% discount
        if(weiRaised < (2000000 * tokenDecimals) / rate) return 1.1764705882352942; // 15% discount
        if(weiRaised < (4000000 * tokenDecimals) / rate) return 1.1111111111111112; // 10% discount
        if(weiRaised < (5000000 * tokenDecimals) / rate) return 1.0526315789473684; // 5% discount
        return 1; // Should never happen, as 5 million is hard cap.
    }
}