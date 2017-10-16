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

    let fintech_fans_wallet = accounts[0];
    let bounties_wallet = accounts[1];
    let founders_wallet = accounts[2];
    let some_user_wallet = accounts[3];

    const fintech_fans_reward = new BigNumber(4).div(13);
    const bounties_reward = new BigNumber(2).div(13);
    const founders_reward = new BigNumber(1).div(13);

    before(async function() {
        // Requirement to correctly read "now" as interpreted by at least testrpc.
        await advanceBlock();
    });

    beforeEach(async function() {
        startTime = latestTime() + duration.weeks(1);
        endTime = startTime + duration.weeks(1);

        token = await FintechCoin.new();
        crowdsale = await FintechFansCrowdsale.new(startTime, endTime, rate, fintech_fans_wallet, bounties_wallet, founders_wallet, goal, cap, token.address, 0);

        await token.transferOwnership(crowdsale.address);
    });

    it('should be token owner', async function () {
        const owner = await token.owner();
        owner.should.equal(crowdsale.address);
    });

    describe('creating a valid crowdsale', async function() {
        it('should fail if cap lower than goal', async function() {
            await FintechFansCrowdsale.new(startTime, endTime, rate, fintech_fans_wallet, founders_wallet, goal, 1, token.address).should.be.rejectedWith(EVMThrow);
        });
        it('should fail when given non-FINC token address', async function() {
            let fake_token = await StandardTokenMock.new();
            console.log(fake_token.address);
            await FintechFansCrowdsale.new(startTime, endTime, rate, fintech_fans_wallet, founders_wallet, goal, 1, fake_token.address).should.be.rejectedWith(EVMThrow);
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

        it('should mint given amount of tokens to proper addresses', async function(){
            // TODO Repeat this test for different wei amounts, and different pre-conditions.
            const wei = new BigNumber(1000);
            const expected_tokens = wei.mul(rate).floor();
            const expected_tokens_including_bonus = expected_tokens.mul(125).div(100).floor(); // 1.25


            await crowdsale.buyTokens(some_user_wallet, {value: new BigNumber(wei), from: some_user_wallet});
            const balance = await token.balanceOf.call(some_user_wallet);

            const balance_fintech_fans = await token.balanceOf.call(fintech_fans_wallet);
            const balance_bounties = await token.balanceOf.call(bounties_wallet);
            const balance_founders = await token.balanceOf.call(founders_wallet);

            const current_bonus_rate = await crowdsale.currentBonusRate();
            const totalSupply = await token.totalSupply();

            // current_bonus_rate.should.be.bignumber.equal(125);
            console.log(current_bonus_rate);

            const expected_fintech_fans_reward = new BigNumber(expected_tokens_including_bonus).mul(fintech_fans_reward).floor();
            const expected_bounties_reward = new BigNumber(expected_tokens_including_bonus).mul(bounties_reward).floor();
            const expected_founders_reward = new BigNumber(expected_tokens_including_bonus).mul(founders_reward).floor();

            balance.should.be.bignumber.equal(new BigNumber(expected_tokens_including_bonus));
            balance_fintech_fans.should.be.bignumber.equal(expected_fintech_fans_reward);
            balance_bounties.should.be.bignumber.equal(expected_bounties_reward);
            balance_founders.should.be.bignumber.equal(expected_founders_reward);

            const expectedTotalSupply = expected_tokens_including_bonus.add(expected_fintech_fans_reward).add(expected_bounties_reward).add(expected_founders_reward);

            totalSupply.should.be.bignumber.equal(expectedTotalSupply);
        });
    });

    // TODO Check costs.
    // TODO ensure superclass behaviours still work.
});
