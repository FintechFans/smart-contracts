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

contract('FintechFansCrowdsale', function(accounts) {
    const rate = new BigNumber(1000);

    const goal = ether(5);
    const cap = ether(50);
    const lessThanCap = ether(16);

    let token;

    let startTime;
    let endTime;

    let fintechfans_wallet = accounts[0];
    let bounties_wallet = accounts[1];
    let founders_wallet = accounts[2];

    before(async function() {
        // Requirement to correctly read "now" as interpreted by at least testrpc.
        await advanceBlock();
    });

    beforeEach(async function() {
        startTime = latestTime() + duration.weeks(1);
        endTime = startTime + duration.weeks(1);

        token = await FintechCoin.new();
        // console.log(token);
        this.crowdsale = await FintechFansCrowdsale.new(startTime, endTime, rate, fintechfans_wallet, bounties_wallet, founders_wallet, goal, cap, token.address, 0);

        await token.transferOwnership(this.crowdsale.address);
    });

    it('should be token owner', async function () {
        const owner = await token.owner();
        owner.should.equal(this.crowdsale.address);
    });

    describe('creating a valid crowdsale', async function() {
        it('should fail if cap lower than goal', async function() {
            await FintechFansCrowdsale.new(startTime, endTime, rate, accounts[0], accounts[1], goal, 1, token.address).should.be.rejectedWith(EVMThrow);
        });
    });

    describe("accepting payments", async function() {
        beforeEach(async function() {
            await increaseTimeTo(startTime);
        });

        it('Should accept payments within cap', async function(){
            await this.crowdsale.send(cap.minus(lessThanCap)).should.be.fulfilled;
            await this.crowdsale.send(lessThanCap).should.be.fulfilled;
        });

        it('does not accept payments when paused', async function() {
            await this.crowdsale.pause().should.be.fulfilled;
            await this.crowdsale.send(cap.minus(lessThanCap)).should.be.rejectedWith(EVMThrow);
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
            await this.crowdsale.send(new BigNumber(1000));

            let totalSupply = await token.totalSupply.call();
            const expectedTotalSupply = new BigNumber(1000 * 2.50 * rate);
            totalSupply.should.be.bignumber.equal(expectedTotalSupply);
        });

        it('should mint given amount of tokens to proper addresses', async function(){
            const eth = 1000;
            const expected_tokens = eth * rate;
            const expected_tokens_including_bonus = expected_tokens * 1.25;
            const result = await this.crowdsale.buyTokens(accounts[2], {value: new BigNumber(eth), from: accounts[2]});

            let totalSupply = await token.totalSupply();
            const expectedTotalSupply = new BigNumber(expected_tokens_including_bonus * 2);
            totalSupply.should.be.bignumber.equal(expectedTotalSupply);

            const balance = await token.balanceOf.call(accounts[2]);
            const balance_fintech_fans = await token.balanceOf.call(accounts[0]);
            const balance_founders = await token.balanceOf.call(accounts[1]);

            balance.should.be.bignumber.equal(new BigNumber(expected_tokens_including_bonus));
            balance_fintech_fans.should.be.bignumber.equal(new BigNumber(expected_tokens_including_bonus * 0.8));
            balance_founders.should.be.bignumber.equal(new BigNumber(expected_tokens_including_bonus * 0.2));
        });
    });

    // TODO Check costs.
});
