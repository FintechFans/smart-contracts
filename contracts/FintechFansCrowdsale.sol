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

contract FintechFansCrowdsale is CappedCrowdsale {
    FintechFansCoin tokenContract;
    address public foundersWallet;

    function FintechFansCrowdsale (
        uint256 _startTime,
        uint256 _endTime,
        uint256 _rate,
        address _wallet,
        address _foundersWallet,
        uint256 _cap,
        FintechFansCoin _tokenContract
        )
        Crowdsale(_startTime, _endTime, _rate, _wallet)
        CappedCrowdsale(_cap)
    {
        foundersWallet = _foundersWallet;
        tokenContract = _tokenContract;
    }

}

/* contract FintechFansCrowdsale is Ownable, RefundableCrowdsale, CappedCrowdsale, Pausable { */
/*     uint256 tokenDecimals = 18; */
/*     /\* Reference to the FintechFansCoin contract, whose tokens are sold. *\/ */
/*     FintechFansCoin tokenContract; */
/*     address public foundersWallet; */

/*     function FintechFansCrowdsale( */
/*         uint256 _startTime, */
/*         uint256 _endTime, */
/*         uint256 _rate,      // how many token units a buyer gets per Wei */
/*         address _multisigWallet, // Address FintechFans' tokens are sent to, and (when successful) Ether is sent to. */
/*         address _foundersWallet, // Address Founders' tokens are sent to. */
/*         uint256 _goal, // Minimum goal, in Wei */
/*         uint256 _cap   // Maximum cap, in Wei */
/*     ) */
/*         Crowdsale(_startTime, _endTime, rate, _multisigWallet) */
/*         RefundableCrowdsale(_goal) */
/*         CappedCrowdsale(/\*5000000 * tokenDecimals * _rate*\/ _cap) */
/*     { */
/*         foundersWallet = _foundersWallet; */
/*     } */

/*     /\* */
/*       TODO override createTokenContract()! */
/*      *\/ */

/*     /\* */
/*       Overridden version of Crowdsale.buyTokens because: */
/*       - The Wei->FFC rate depends on how many tokens have already been sold. */
/*       - Also mint tokens sent to FintechFans and the Founders at the same time. */
/*      *\/ */
/*   /\*   function buyTokens(address beneficiary) public payable { *\/ */
/*   /\*       require(beneficiary != 0x0); *\/ */
/*   /\*       require(validPurchase()); *\/ */

/*   /\*       uint256 weiAmount = msg.value; *\/ */

/*   /\*       // calculate token amount to be created *\/ */
/*   /\*       uint256 tokens = weiAmount.mul(rate); *\/ */
/*   /\*       tokens = tokens.mul(currentBonusRate()).div(100); *\/ */

/*   /\*       // update state *\/ */
/*   /\*       weiRaised = weiRaised.add(weiAmount); *\/ */

/*   /\*       // Mint tokens for beneficiary *\/ */
/*   /\*       token.mint(beneficiary, tokens); *\/ */
/*   /\*       TokenPurchase(msg.sender, beneficiary, weiAmount, tokens); *\/ */

/*   /\*       // Mint tokens for FintechFans and Founders *\/ */
/*   /\*       uint256 fintechfans_tokens = tokens.mul(/\\*0.*\\/8).div(10); *\/ */
/*   /\*       uint256 founders_tokens = tokens.mul(/\\*0.*\\/2).div(10); *\/ */
/*   /\*       token.mint(wallet, fintechfans_tokens); *\/ */
/*   /\*       token.mint(foundersWallet, founders_tokens);/\\* TODO Locked vault, split *\\/ *\/ */

/*   /\*       forwardFunds(); *\/ */
/*   /\* } *\/ */

/*     /\* */
/*       Returns a fixed-size number that is 100 * the bonus amount. */
/*      *\/ */
/*     /\* function currentBonusRate() public returns (uint) { *\/ */
/*     /\*     /\\* TODO check how `rate' is used. *\\/ *\/ */
/*     /\*     if(weiRaised < (1000000 * tokenDecimals) / rate) return 125/\\*.25*\\/; // 20% discount *\/ */
/*     /\*     if(weiRaised < (2000000 * tokenDecimals) / rate) return 118/\\*.1764705882352942*\\/; // 15% discount *\/ */
/*     /\*     if(weiRaised < (4000000 * tokenDecimals) / rate) return 111/\\*.1111111111111112*\\/; // 10% discount *\/ */
/*     /\*     if(weiRaised < (5000000 * tokenDecimals) / rate) return 105/\\*.0526315789473684*\\/; // 5% discount *\/ */
/*     /\*     return 100; // Should never happen, as 5 million is hard cap. *\/ */
/*     /\* } *\/ */
/* } */
