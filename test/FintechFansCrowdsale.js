'use strict';

import ether from './helpers/ether.js';
import {advanceBlock} from './helpers/advanceToBlock';
import {increaseTimeTo, duration} from './helpers/increaseTime';
import latestTime from './helpers/latestTime';
import EVMThrow from './helpers/EVMThrow';

const BigNumber = web3.BigNumber;

require('chai')
    .use(require('chai-as-promised'))
    .use(require('chai-bignumber')(BigNumber))
    .should();

const FintechFansCrowdsale = artifacts.require("FintechFansCrowdsale");
const FintechCoin = artifacts.require("FintechCoin");
const StandardTokenMock = artifacts.require("./stubs/StandardTokenMock");

contract('FintechFansCrowdsale', function(accounts) {
    const rate = new BigNumber(1000);

    const goal = ether(5);
    const cap = ether(50);
    const lessThanCap = ether(16);

    let crowdsale;
    let token;

    let startTime;
    let endTime;

    let fintechFansWallet = accounts[0];
    let bountiesWallet = accounts[1];
    let foundersWallet = accounts[2];
    let someUserWallet = accounts[3];

    const fintechFansReward = new BigNumber(4).div(13);
    const bountiesReward = new BigNumber(2).div(13);
    const foundersReward = new BigNumber(1).div(13);

    before(async function() {
        // Requirement to correctly read "now" as interpreted by at least testrpc.
        await advanceBlock();
    });

    beforeEach(async function() {
        startTime = latestTime() + duration.weeks(1);
        endTime = startTime + duration.weeks(1);

        token = await FintechCoin.new();
        crowdsale = await FintechFansCrowdsale.new(startTime, endTime, rate, fintechFansWallet, bountiesWallet, foundersWallet, goal, cap, token.address, 0);

        await token.transferOwnership(crowdsale.address);
    });

    it('should be token owner', async function () {
        const owner = await token.owner();
        owner.should.equal(crowdsale.address);
    });

    describe('creating a valid crowdsale', async function() {
        it('should fail if cap lower than goal', async function() {
            await FintechFansCrowdsale.new(startTime, endTime, rate, fintechFansWallet, foundersWallet, goal, 1, token.address).should.be.rejectedWith(EVMThrow);
        });
        it('should fail when given non-FINC token address', async function() {
            let fakeToken = await StandardTokenMock.new();
            console.log(fakeToken.address);
            await FintechFansCrowdsale.new(startTime, endTime, rate, fintechFansWallet, foundersWallet, goal, 1, fake_token.address).should.be.rejectedWith(EVMThrow);
        });
    });

    describe("accepting payments", async function() {
        beforeEach(async function() {
            await increaseTimeTo(startTime);
        });

        it('Should accept payments within cap', async function(){
            await crowdsale.send(cap.minus(lessThanCap)).should.be.fulfilled;
            await crowdsale.send(lessThanCap).should.be.fulfilled;
        });

        it('does not accept payments when paused', async function() {
            await crowdsale.pause().should.be.fulfilled;
            await crowdsale.send(cap.minus(lessThanCap)).should.be.rejectedWith(EVMThrow);
        });
    });

    describe("minting tokens", async function() {
        beforeEach(async function() {
            await increaseTimeTo(startTime);
        });

        it('did not mint tokens before anything was sold', async function() {
            assert.equal(await token.totalSupply(), 0);
        });

        it('minted tokens when something was sold', async function() {
            const wei_amount = 1000;
            const preTotalSupply = await token.totalSupply.call();
            await crowdsale.send(new BigNumber(wei_amount));

            let postTotalSupply = await token.totalSupply.call();
            postTotalSupply.should.be.bignumber.above(preTotalSupply);
        });

        let prebuyTokens = function(tokenAmount) {
            
        };

        let testTokenBuying = async function(tokenAmount, expectedBonusRate) {
            const oldTotalSupply = await token.totalSupply();
            const oldBalanceFintechFans = await token.balanceOf.call(fintechFansWallet);
            const oldBalanceBounties = await token.balanceOf.call(bountiesWallet);
            const oldBalanceFounders = await token.balanceOf.call(foundersWallet);

            const wei = new BigNumber(tokenAmount);
            const expectedTokens = wei.mul(rate).floor();
            const expectedTokensIncludingBonus = expectedTokens.mul(125).div(100).floor(); // 1.25

            await crowdsale.buyTokens(someUserWallet, {value: new BigNumber(wei), from: someUserWallet});
            const balance = await token.balanceOf.call(someUserWallet);

            const balanceFintechFans = await token.balanceOf.call(fintechFansWallet);
            const balanceBounties = await token.balanceOf.call(bountiesWallet);
            const balanceFounders = await token.balanceOf.call(foundersWallet);

            const currentBonusRate = await crowdsale.currentBonusRate();
            const totalSupply = await token.totalSupply();

            // current_bonus_rate.should.be.bignumber.equal(125);
            console.log(currentBonusRate);

            const expectedFintechFansReward = new BigNumber(expectedTokensIncludingBonus).mul(fintechFansReward).floor().add(oldBalanceFintechFans);
            const expectedBountiesReward = new BigNumber(expectedTokensIncludingBonus).mul(bountiesReward).floor().add(oldBalanceBounties);
            const expectedFoundersReward = new BigNumber(expectedTokensIncludingBonus).mul(foundersReward).floor().add(oldBalanceFounders);

            currentBonusRate.should.be.bignumber.equal(expectedBonusRate);

            balance.should.be.bignumber.equal(new BigNumber(expectedTokensIncludingBonus));
            balanceFintechFans.should.be.bignumber.equal(expectedFintechFansReward);
            balanceBounties.should.be.bignumber.equal(expectedBountiesReward);
            balanceFounders.should.be.bignumber.equal(expectedFoundersReward);

            const expectedTotalSupply = expectedTokensIncludingBonus.add(expectedFintechFansReward).add(expectedBountiesReward).add(expectedFoundersReward);
            totalSupply.should.be.bignumber.equal(expectedTotalSupply);
        };

        [10, 20, 30, 50, 100, 120, 200, 300, 500, 1000, 1500, 2000, 5000, 10000].forEach(function(wei){
            it('should mint given amount of tokens to proper addresses when spending (' + wei + ') wei', async function(){
                // TODO Repeat this test for different wei amounts, and different pre-conditions.
                await buyTokens(wei);
            });
        });

    });

    // TODO Check costs.
    // TODO ensure superclass behaviours still work.
});
