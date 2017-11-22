pragma solidity ^0.4.11;

import './FintechFansCrowdsale.sol';

contract TheFintechFansCrowdsale is FintechFansCrowdsale {
    function TheFintechFansCrowdsale()
        FintechFansCrowdsale(
            1511345700, // @param _startTime time (Solidity UNIX timestamp) from when it is allowed to buy FINC.
            1511347800, // @param _endTime time (Solidity UNIX timestamp) until which it is allowed to buy FINC. (Should be larger than startTime)
            2, // @param _rate Number of wei that needs to be spent to buy 1 * 10^(-18) FINC.
            0xd5D29f18B8C2C7157B6BF38111C9318b9604BdED, // @param _wallet The wallet of FintechFans itself, to which some of the facilitating tokens will be sent.
            0x6B1964119841f3f5363D7EA08120642FE487410E, // @param _bountiesWallet The wallet used to pay out bounties, to which some of the facilitating tokens will be sent.
            0x9a123fDd708eD0931Fb4938C5b2E2462B6D23390, // @param _foundersWallet The wallet used for the founders, to which some of the facilitating tokens will be sent.
            1e16, // @param _goal The minimum goal (in 1 * 10^(-18) tokens) that the Crowdsale needs to reach.
            12e16, // @param _cap The maximum cap (in 1 * 10^(-18) tokens) that the Crowdsale can reach.
            FintechCoin(0xaaC5b7048114d70b759E9EA17AFA4Ff969931a4a), // @param _token The address where the FintechCoin contract was deployed prior to creating this contract.
            0  // @param _purchasedTokensRaisedDuringPresale The amount (in 1 * 18^18 tokens) that was purchased during the presale.
            )
    {
    }
}
