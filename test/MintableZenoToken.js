
'use strict';

import EVMThrow from './helpers/EVMThrow';

const BigNumber = web3.BigNumber;

require('chai')
    .use(require('chai-as-promised'))
    .use(require('chai-bignumber')(BigNumber))
    .should();

const MintableZenoToken = artifacts.require("./MintableZenoToken.sol");

contract('MintableZenoToken', function(accounts) {
    before(function(){
        this.total_supply = 1e36;
    });

    beforeEach(async function() {
        this.instance = await ZenoToken.new("MyZenoToken", "MZT", 18, this.total_supply);
    });

    describe("Minting", function(){
        it("Is mintable until minting is turned off by admin", async function(){
            let account_one = accounts[0];
            let account_two = accounts[1];
            let amount = 100;

            let mintingFinished = await this.instance.mintingFinished();
            assert(mintingFinished).to.equal(false);

            await this.instance.mint(account_two, amount, {from: account_one});
            await this.instance.finishMinting();
            let mintingFinishedAfter = await this.instance.mintingFinished();

            assert(mintingFinishedAfter).to.equal(true);
        });

        it("Properly mints when mintable", async function(){
            let account_one = accounts[0];
            let account_two = accounts[1];
            let amount = 100;

            let account_two_starting_balance = await this.instance.balanceOf(account_two);

            await this.instance.mint(account_two, amount, {from: account_one});
            let account_two_ending_balance = await this.instance.balanceOf(account_two);

            account_two_ending_balance.toNumber().should.be.equal(account_two_starting_balance.toNumber() + amount);
        });

        it("Disallows minting when not mintable", async function(){
            let account_one = accounts[0];
            let account_two = accounts[1];
            let amount = 100;

            await this.instance.finishMinting();
            await this.instance.mint(account_two, amount, {from: account_one});

            account_two_ending_balance.toNumber().should.be.equal(account_two_starting_balance.toNumber());
        });
    });
    // TODO test creation of events
});
