pragma solidity ^0.4.11;
/* Prevent overfow/underflow of arithmetic: */
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

/* Restrict certain actions to only the contract's owner: */
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/lifecycle/Pausable.sol';

/* Restrict certain actions to only the contract's owner: */
import 'zeppelin-solidity/contracts/crowdsale/CappedCrowdsale.sol';
import 'zeppelin-solidity/contracts/crowdsale/RefundableCrowdsale.sol';

/* Reference to the FintechCoin contract, whose tokens are sold. */
import './FintechCoin.sol';

contract FintechFansCrowdsale is Pausable, RefundableCrowdsale, CappedCrowdsale {
    uint256 tokenDecimals = 18;

    FintechCoin tokenContract;
    address public foundersWallet;
    address public bountiesWallet;

    uint256 public purchasedTokensRaised;
    uint256 public purchasedTokensRaisedDuringPresale;

    uint256 oneTwelfthOfCap;

    function FintechFansCrowdsale (
        uint256 _startTime,
        uint256 _endTime,
        uint256 _rate, // amount of wei needs to be paid for a single 1e-18th token.
        address _wallet,
        address _bountiesWallet,
        address _foundersWallet,
        uint256 _goal,
        uint256 _cap,
        FintechCoin _token,
        uint256 _purchasedTokensRaisedDuringPresale
        )
        Crowdsale(_startTime, _endTime, _rate, _wallet)
        RefundableCrowdsale(_goal)
        CappedCrowdsale(_cap)
    {
        require(_goal < _cap);

        bountiesWallet = _bountiesWallet;
        foundersWallet = _foundersWallet;
        token = _token;
        weiRaised = 0;

        purchasedTokensRaisedDuringPresale = _purchasedTokensRaisedDuringPresale; // TODO Actual value, since only count tokens that were purchased directly.
        purchasedTokensRaised = purchasedTokensRaisedDuringPresale;

        oneTwelfthOfCap = _cap / 12;
    }

    /*
      Overrides Crowdsale.createTokenContract,
      because the FintechFansCrowdsale uses an already-deployed
      token, so there is no need to internally deploy a contract.
     */
    function createTokenContract() internal returns (MintableToken) {
        return MintableToken(0x0);
  }

    /*
     * Overrides version of Crowdsale.buyTokens because:
     * - The Wei->FFC rate depends on how many tokens have already been sold.
     * - Also mint tokens sent to FintechFans and the Founders at the same time.
    */
    function buyTokens(address beneficiary) public payable whenNotPaused {
        require(beneficiary != 0x0);

        uint256 weiAmount = msg.value;

        /* // calculate token amount to be created */
        uint256 purchasedTokens = weiAmount.div(rate);
        require(validPurchase(purchasedTokens));
        purchasedTokens = purchasedTokens.mul(currentBonusRate()).div(100);
        require(purchasedTokens != 0);

        /* // update state */
        weiRaised = weiRaised.add(weiAmount);
        purchasedTokensRaised = purchasedTokensRaised.add(purchasedTokens);

        /* // Mint tokens for beneficiary */
        token.mint(beneficiary, purchasedTokens);
        TokenPurchase(msg.sender, beneficiary, weiAmount, purchasedTokens);

        mintTokensForFacilitators(purchasedTokens);

        forwardFunds();
    }

    // Overrides RefundableCrowdsale#goalReached
    // since we count the goal in purchased tokens, instead of in Wei.
    // @return true if crowdsale has reached more funds than the minimum goal.
    function goalReached() public constant returns (bool) {
        return purchasedTokensRaised >= goal;
    }

    // Overrides CappedCrowdsale#hasEnded to add cap logic in tokens
    // @return true if crowdsale event has ended
    function hasEnded() public constant returns (bool) {
        bool capReached = purchasedTokensRaised >= cap;
        return Crowdsale.hasEnded() || capReached;
    }

    // replace CappedCrowdsale#validPurchase to add extra cap logic in tokens
    // @return true if investors can buy at the moment
    function validPurchase(uint256 purchasedTokens) internal constant returns (bool) {
        /* bool withinCap = purchasedTokensRaised.add(purchasedTokens) <= cap; */
        /* return Crowdsale.validPurchase() && withinCap; */
        bool withinCap = purchasedTokensRaised.add(purchasedTokens) <= cap;
        return Crowdsale.validPurchase() && withinCap;
    }

    /*
     * @dev In total, (20/13) * `purchasedTokens` tokens are created.
     * @dev 13/13th of these are for the Beneficiary.
     * @dev 7/13th of these are minted for the Facilitators as follows:
     * @dev   1/13th -> Founders
     * @dev   2/13th -> Bounties
     * @dev   4/13th -> FintechFans
     * Note that all result rational amounts are floored since the EVM only works with integer arithmetic.
     */
    function mintTokensForFacilitators(uint256 purchasedTokens) internal {
        // Mint tokens for FintechFans and Founders
        uint256 fintechfans_tokens = purchasedTokens.mul(4).div(13);
        uint256 bounties_tokens = purchasedTokens.mul(2).div(13);
        uint256 founders_tokens = purchasedTokens.mul(1).div(13);
        token.mint(wallet, fintechfans_tokens);
        token.mint(bountiesWallet, bounties_tokens);
        token.mint(foundersWallet, founders_tokens);/* TODO Locked vault? */
    }

    /*
     * @return a fixed-size number that is the total percentage of tokens that will be created. (100 * the bonus ratio)
     * When < 2 million tokens purchased, this will be 125%, which is equivalent to a 20% discount
     * When < 4 million tokens purchased, 118%, which is equivalent to a 15% discount.
     * When < 6 million tokens purchased, 111%, which is equivalent to a 10% discount.
     * When < 9 million tokens purchased, 105%, which is equivalent to a 5% discount.
     * Otherwise, there is no bonus and the function returns 100%.
     */
    function currentBonusRate() public constant returns (uint) {
        /* TODO check how `rate' is used. */
        if(purchasedTokensRaised < (2 * oneTwelfthOfCap)) return 125/*.25*/; // 20% discount
        if(purchasedTokensRaised < (4 * oneTwelfthOfCap)) return 118/*.1764705882352942*/; // 15% discount
        if(purchasedTokensRaised < (6 * oneTwelfthOfCap)) return 111/*.1111111111111112*/; // 10% discount
        if(purchasedTokensRaised < (9 * oneTwelfthOfCap)) return 105/*.0526315789473684*/; // 5% discount
        return 100;
    }
}
