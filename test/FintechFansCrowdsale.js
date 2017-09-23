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
const FintechFansCoin = artifacts.require("FintechFansCoin");

contract('FintechFansCrowdsale', function(accounts) {
    const rate = new BigNumber(1000);

    const goal = ether(5);
    const cap = ether(50);
    const lessThanCap = ether(16);

    before(async function() {
        // Requirement to correctly read "now" as interpreted by at least testrpc.
        await advanceBlock();
    });
    
    beforeEach(async function() {
        this.startTime = latestTime() + duration.weeks(1);
        this.endTime = this.startTime + duration.weeks(1);

        this.token = await FintechFansCoin.new();
        // console.log(this.token);
        this.crowdsale = await FintechFansCrowdsale.new(this.startTime, this.endTime, rate, accounts[0], accounts[1], goal, cap, this.token.address);

        await this.token.transferOwnership(this.crowdsale.address);
    });

    it('should be token owner', async function () {
        const owner = await this.token.owner();
        owner.should.equal(this.crowdsale.address);
    });

    describe('creating a valid crowdsale', async function() {
        it('should fail if cap lower than goal', async function() {
            await FintechFansCrowdsale.new(this.startTime, this.endTime, rate, accounts[0], accounts[1], goal, 1, this.token.address).should.be.rejectedWith(EVMThrow);
        });
    });

    describe("accepting payments", async function() {
        beforeEach(async function() {
            await increaseTimeTo(this.startTime);
        });

        it('Should accept payments within cap', async function(){
            await this.crowdsale.send(cap.minus(lessThanCap)).should.be.fulfilled;
            await this.crowdsale.send(lessThanCap).should.be.fulfilled;
        });
    });

    describe("minting tokens", async function() {
        beforeEach(async function() {
            await increaseTimeTo(this.startTime);
        });

        it('did not mint tokens before anything was sold', async function() {
            assert.equal(await this.token.totalSupply(), 0);
        });

        it('minted tokens when something was sold', async function() {
            await this.crowdsale.send(new BigNumber(1000));

            let totalSupply = await this.token.totalSupply.call();
            const expectedTotalSupply = new BigNumber(1000 * 2.50 * rate);
            totalSupply.should.be.bignumber.equal(expectedTotalSupply);
        });

        it('should mint given amount of tokens to proper addresses', async function(){
            const result = await this.crowdsale.buyTokens(accounts[2], {value: new BigNumber(1000), from: accounts[2]});

            console.log(result);
            console.log(result.logs);

            // TODO Why does this not work?
            // let totalSupply = await this.token.totalSupply();
            // const expectedTotalSupply = new BigNumber(42);
            // totalSupply.should.be.bignumber.equal(expectedTotalSupply);

            const balance = await this.token.balanceOf.call(accounts[2]);
            const balance_fintech_fans = await this.token.balanceOf.call(accounts[0]);
            const balance_founders = await this.token.balanceOf.call(accounts[1]);
            console.log(balance.valueOf(), balance_fintech_fans.valueOf(), balance_founders.valueOf());

            balance.should.be.bignumber.equal(new BigNumber(1000 * 1.25 * rate));

            balance_fintech_fans.should.be.bignumber.equal(new BigNumber(1000 * 1.25 * 0.8 * rate));


            balance_founders.should.be.bignumber.equal(new BigNumber(1000 * 1.25 * 0.2 * rate));
        });
    });
});
