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

contract('FintechFansCrowdsale', function([_, wallet]) {
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
        console.log(this.token);
        this.crowdsale = await FintechFansCrowdsale.new(this.startTime, this.endTime, rate, wallet, wallet, goal, cap, this.token.address);

        await this.token.transferOwnership(this.crowdsale.address);
    });

    describe('creating a valid crowdsale', async function() {
        it('should fail if cap lower than goal', async function() {
            await FintechFansCrowdsale.new(this.startTime, this.endTime, rate, wallet, wallet, goal, 1, this.token.address).should.be.rejectedWith(EVMThrow);
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

            let totalSupply = await this.token.totalSupply();
            assert.equal(totalSupply, 42);
        });

        it('should mint given amount of tokens to proper addresses', async function(){
            const result = await this.crowdsale.send(new BigNumber(1000));

            assert.equal(result.logs[0].event, 'Mint');
            assert.equal(result.logs[0].args.to.valueOf(), accounts[0]);
            assert.equal(result.logs[0].args.amount.valueOf(), 100);
            assert.equal(result.logs[1].event, 'Transfer');
            assert.equal(result.logs[1].args.from.valueOf(), 0x0);


            assert.equal(totalSupply, 2000);
        });
    });
});
