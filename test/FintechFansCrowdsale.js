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

contract('FintechFansCrowdsale', function([_, wallet]) {
    const rate = new BigNumber(1000);
    
    const goal = ether(100);
    const cap = ether(300);
    const lessThanCap = ether(160);

    before(async function() {
        // Requirement to correctly read "now" as interpreted by at least testrpc.
        await advanceBlock();
    });

    beforeEach(async function() {
        this.startTime = latestTime() + duration.weeks(1);
        this.endTime = this.startTime + duration.weeks(1);

        this.crowdsale = await FintechFansCrowdsale.new(this.startTime, this.endTime, rate, wallet, /*wallet, goal,*/ cap);
        // this.token = FintechFansCoin.at(await this.crowdsale.token());
    });

    describe('creating a valid crowdsale', async function() {
        it('should fail if zero cap', async function() {
            await FintechFansCrowdsale.new(this.startTime, this.endTime, rate, wallet, 0).should.be.rejectedWith(EVMThrow);
        });
    });
});
