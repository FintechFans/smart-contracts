pragma solidity ^0.4.11;
/* Prevent overfow/underflow of arithmetic: */
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

/* Restrict certain actions to only the contract's owner: */
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/lifecycle/Pausable.sol';

/* Crowdsale-specific logic: */
import 'zeppelin-solidity/contracts/crowdsale/CappedCrowdsale.sol';
import 'zeppelin-solidity/contracts/crowdsale/RefundableCrowdsale.sol';

/* Vault tokens are locked in until 24 months for Founders. */
/* import 'zeppelin-solidity/contracts/token/TokenTimelock.sol'; */
import './FoundersVault.sol';

/* Reference to the FintechCoin contract, whose tokens are sold. */
import './FintechCoin.sol';

/**
   @title The FintechFansCrowdsale contract handles the process of giving out tokens in exchange for Ether, during a limited amount of time.

   FintechFansCrowdsale is:

   - Pausable, which means that admins can pause the contract when something is going horribly wrong.
   - a RefundableCrowsale, which means that when the minimum `goal` is not reached, everyone can extract their funds.
   - a CappedCrowdsale, which means that no more tokens than the given `cap` will be given out.

*/
// TODO Pausable?
contract FintechFansCrowdsale is Pausable, RefundableCrowdsale, CappedCrowdsale {
        /**
           Address of the wallet of the founders.
           In this wallet, part of the facilitating tokens will be stored, and they will be locked for 24 months.
         */
        address public foundersWallet;
        FoundersVault public foundersVault;

        /**
           Address of the wallet used to pay out bounties.
           In this wallet, part of the facilitating tokens will be stored.
         */
        address public bountiesWallet;

        /**
           Keeps track of how many tokens have been raised so far.
           Used to know when `goal` and `cap` have been reached.
         */
        uint256 public purchasedTokensRaised;

        /**
           The amount of tokens that were sold in the Presale before the Crowdsale.
           Given during construction of this contract.
         */
        uint256 public purchasedTokensRaisedDuringPresale;

        /**
           Helper property to ensure that 1/12 of `cap` does not need to be re-calculated every time.
         */
        uint256 oneTwelfthOfCap;

        /**
           @dev Constructor of the FintechFansCrowdsale contract

           @param _startTime time (Solidity UNIX timestamp) from when it is allowed to buy FINC.
           @param _endTime time (Solidity UNIX timestamp) until which it is allowed to buy FINC. (Should be larger than startTime)
           @param _rate Number of wei that needs to be spent to buy 1 * 10^(-18) FINC.
           @param _wallet The wallet of FintechFans itself, to which some of the facilitating tokens will be sent.
           @param _bountiesWallet The wallet used to pay out bounties, to which some of the facilitating tokens will be sent.
           @param _foundersWallet The wallet used for the founders, to which some of the facilitating tokens will be sent.
           @param _goal The minimum goal (in 1 * 10^(-18) tokens) that the Crowdsale needs to reach.
           @param _cap The maximum cap (in 1 * 10^(-18) tokens) that the Crowdsale can reach.
           @param _token The address where the FintechCoin contract was deployed prior to creating this contract.
           @param _purchasedTokensRaisedDuringPresale The amount (in 1 * 18^18 tokens) that was purchased during the presale.
         */
        function FintechFansCrowdsale (
                uint64 _startTime,
                uint64 _endTime,
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

                oneTwelfthOfCap = _cap / 12;

                token = _token;
                weiRaised = 0;

                purchasedTokensRaisedDuringPresale = _purchasedTokensRaisedDuringPresale;
                purchasedTokensRaised = purchasedTokensRaisedDuringPresale;

                bountiesWallet = _bountiesWallet;
                foundersWallet = _foundersWallet;
                foundersVault = new FoundersVault(_token, _foundersWallet, _endTime + 2 years);
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
         * - The Wei->FFC rate depends on how many tokens have already been sold (see `currentBonusRate()`).
         * - Also mint tokens sent to FintechFans and the Founders at the same time.
         */
        function buyTokens(address beneficiary) public payable whenNotPaused {
                require(beneficiary != 0x0);

                uint256 weiAmount = msg.value;

                // calculate token amount to be created
                uint256 purchasedTokens = weiAmount.div(rate);
                require(validPurchase(purchasedTokens));
                purchasedTokens = purchasedTokens.mul(currentBonusRate()).div(100);
                require(purchasedTokens != 0);

                // update state
                weiRaised = weiRaised.add(weiAmount);
                purchasedTokensRaised = purchasedTokensRaised.add(purchasedTokens);

                // Mint tokens for beneficiary
                token.mint(beneficiary, purchasedTokens);
                TokenPurchase(msg.sender, beneficiary, weiAmount, purchasedTokens);

                mintTokensForFacilitators(purchasedTokens);

                forwardFunds();
        }

        /* Overrides RefundableCrowdsale#goalReached
           since we count the goal in purchased tokens, instead of in Wei.
           @return true if crowdsale has reached more funds than the minimum goal.
        */
        function goalReached() public constant returns (bool) {
                return purchasedTokensRaised >= goal;
        }

        /**
           Overrides CappedCrowdsale#hasEnded to add cap logic in tokens
           @return true if crowdsale event has ended
        */
        function hasEnded() public constant returns (bool) {
                bool capReached = purchasedTokensRaised >= cap;
                return Crowdsale.hasEnded() || capReached;
        }

        /**
           replaces CappedCrowdsale#validPurchase to add extra cap logic in tokens
           @param purchasedTokens Amount of tokens that were purchased (in the smallest, 1 * 10^(-18) denomination)
           @return true if investors are allowed to purchase tokens at the moment.
        */
        function validPurchase(uint256 purchasedTokens) internal constant returns (bool) {
                /* bool withinCap = purchasedTokensRaised.add(purchasedTokens) <= cap; */
                /* return Crowdsale.validPurchase() && withinCap; */
                bool withinCap = purchasedTokensRaised.add(purchasedTokens) <= cap;
                return Crowdsale.validPurchase() && withinCap;
        }

        /**
           @dev Mints the tokens for the facilitating parties.

           @dev In total, (20/13) * `purchasedTokens` tokens are created.
           @dev 13/13th of these are for the Beneficiary.
           @dev 7/13th of these are minted for the Facilitators as follows:
           @dev   1/13th -> Founders
           @dev   2/13th -> Bounties
           @dev   4/13th -> FintechFans

           @dev Note that all result rational amounts are floored since the EVM only works with integer arithmetic.
        */
        function mintTokensForFacilitators(uint256 purchasedTokens) internal {
                // Mint tokens for FintechFans and Founders
                uint256 fintechfans_tokens = purchasedTokens.mul(4).div(13);
                uint256 bounties_tokens = purchasedTokens.mul(2).div(13);
                uint256 founders_tokens = purchasedTokens.mul(1).div(13);
                token.mint(wallet, fintechfans_tokens);
                token.mint(bountiesWallet, bounties_tokens);
                token.mint(foundersVault, founders_tokens);/* TODO Locked vault? */
        }

        /**
           @dev returns the current bonus rate. This is a call that can be done at any time.

           @return a fixed-size number that is the total percentage of tokens that will be created. (100 * the bonus ratio)

           @dev When < 2 million tokens purchased, this will be 125%, which is equivalent to a 20% discount
           @dev When < 4 million tokens purchased, 118%, which is equivalent to a 15% discount.
           @dev When < 6 million tokens purchased, 111%, which is equivalent to a 10% discount.
           @dev When < 9 million tokens purchased, 105%, which is equivalent to a 5% discount.
           @dev Otherwise, there is no bonus and the function returns 100%.
        */
        function currentBonusRate() public constant returns (uint) {
                if(purchasedTokensRaised < (2 * oneTwelfthOfCap)) return 125/*.25*/; // 20% discount
                if(purchasedTokensRaised < (4 * oneTwelfthOfCap)) return 118/*.1764705882352942*/; // 15% discount
                if(purchasedTokensRaised < (6 * oneTwelfthOfCap)) return 111/*.1111111111111112*/; // 10% discount
                if(purchasedTokensRaised < (9 * oneTwelfthOfCap)) return 105/*.0526315789473684*/; // 5% discount
                return 100;
        }

        /**
         * TODO This function is added to have a wrapper for `foundersVault` working
         * with Truffle to check if code is working correctly.
         *
         * Obviously, it would be a whole lot better to make the normal automatic getters work properly.
         */
        function foundersVaultAddress() public returns (address) {
            return (address)(foundersVault);
        }
}
