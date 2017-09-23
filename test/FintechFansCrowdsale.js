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

    const goal = new BigNumber(10);
    const cap = new BigNumber(30);
    const lessThanCap = new BigNumber(16);

    before(async function() {
        // Requirement to correctly read "now" as interpreted by at least testrpc.
        await advanceBlock();
    });
    
    beforeEach(async function() {
        this.startTime = latestTime() + duration.weeks(1);
        this.endTime = this.startTime + duration.weeks(1);

        this.token = await FintechFansCoin.new();
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
        
    });
});
