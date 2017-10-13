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
    uint256 public weiRaisedDuringPresale;

    function FintechFansCrowdsale (
        uint256 _startTime,
        uint256 _endTime,
        uint256 _rate,
        address _wallet,
        address _bountiesWallet,
        address _foundersWallet,
        uint256 _goal,
        uint256 _cap,
        FintechCoin _token,
        uint256 _weiRaisedDuringPresale
        )
        Crowdsale(_startTime, _endTime, _rate, _wallet)
        RefundableCrowdsale(_goal)
        CappedCrowdsale(_cap)
    {
        require(_goal < _cap);

        bountiesWallet = _bountiesWallet;
        foundersWallet = _foundersWallet;
        token = _token;
        weiRaised = weiRaisedDuringPresale = _weiRaisedDuringPresale;
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
      Overridden version of Crowdsale.buyTokens because:
      - The Wei->FFC rate depends on how many tokens have already been sold.
      - Also mint tokens sent to FintechFans and the Founders at the same time.
    */
    function buyTokens(address beneficiary) public payable whenNotPaused {
        require(beneficiary != 0x0);
        require(validPurchase());

        uint256 weiAmount = msg.value;

        // calculate token amount to be created
        uint256 purchasedTokens = weiAmount.mul(rate);
        purchasedTokens = purchasedTokens.mul(currentBonusRate()).div(100);

        // update state
        weiRaised = weiRaised.add(weiAmount);

        // Mint tokens for beneficiary
        token.mint(beneficiary, purchasedTokens);
        TokenPurchase(msg.sender, beneficiary, weiAmount, purchasedTokens);

        mintTokensForFacilitators(purchasedTokens);

        forwardFunds();
    }

    /*
     * @dev In total, (20/13) * `purchasedTokens` tokens are created.
     * @dev 13/13th of these are for the Beneficiary.
     * @dev 7/13th of these are minted for the Facilitators as follows:
     * @dev   1/13th -> Founders
     * @dev   2/13th -> Bounties
     * @dev   4/13th -> FintechFans
     */
    function mintTokensForFacilitators(uint256 purchasedTokens) internal {
        // Mint tokens for FintechFans and Founders
        uint256 fintechfans_tokens = purchasedTokens.mul(4).div(13);
        uint256 bounties_tokens = purchasedTokens.mul(2).div(13);
        uint256 founders_tokens = purchasedTokens.mul(1).div(13);
        token.mint(wallet, fintechfans_tokens);
        token.mint(bountiesWallet, bounties_tokens);
        token.mint(foundersWallet, founders_tokens);/* TODO Locked vault */

        // TODO Think about maybe also generating events for these minting actions?
    }

    /*
      Returns a fixed-size number that is 100 * the bonus amount.
     */
    function currentBonusRate() public returns (uint) {
        /* TODO check how `rate' is used. */
        if(weiRaised < (2000000 * tokenDecimals) / rate) return 125/*.25*/; // 20% discount
        if(weiRaised < (4000000 * tokenDecimals) / rate) return 118/*.1764705882352942*/; // 15% discount
        if(weiRaised < (6000000 * tokenDecimals) / rate) return 111/*.1111111111111112*/; // 10% discount
        if(weiRaised < (9000000 * tokenDecimals) / rate) return 105/*.0526315789473684*/; // 5% discount
        return 100;
    }



}
