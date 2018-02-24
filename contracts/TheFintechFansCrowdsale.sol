pragma solidity ^0.4.11;

import './FintechFansCrowdsale.sol';

contract TheFintechFansCrowdsale is FintechFansCrowdsale {
    function TheFintechFansCrowdsale() public
        FintechFansCrowdsale(
            1511380200, // _startTime time (Solidity UNIX timestamp) from when it is allowed to buy FINC.
            1511384400, // _endTime time (Solidity UNIX timestamp) until which it is allowed to buy FINC. (Should be larger than startTime)
            2, // _rate Number of tokens created per ether. (Since Ether and FintechCoin use the same number of decimal places, this can be read as direct conversion rate of Ether -> FintechCoin.)
            0xd5D29f18B8C2C7157B6BF38111C9318b9604BdED, // _wallet The wallet of FintechFans itself, to which some of the facilitating tokens will be sent.
            0x6B1964119841f3f5363D7EA08120642FE487410E, // _bountiesWallet The wallet used to pay out bounties, to which some of the facilitating tokens will be sent.
            0x9a123fDd708eD0931Fb4938C5b2E2462B6D23390, // _foundersWallet The wallet used for the founders, to which some of the facilitating tokens will be sent.
            1e16, // _goal The minimum goal (in 1 * 10^(-18) tokens) that the Crowdsale needs to reach.
            12e16, // _cap The maximum cap (in 1 * 10^(-18) tokens) that the Crowdsale can reach.
            0xaaC5b7048114d70b759E9EA17AFA4Ff969931a4a, // _token The address where the FintechCoin contract was deployed prior to creating this contract.
            0  // _purchasedTokensRaisedDuringPresale The amount (in 1 * 18^18 tokens) that was purchased during the presale.
            )
    {
    }
}
