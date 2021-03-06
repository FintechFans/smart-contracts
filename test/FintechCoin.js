
'use strict';

import EVMThrow from './helpers/EVMThrow';
import EVMRevert from './helpers/EVMRevert';

const BigNumber = web3.BigNumber;

require('chai')
    .use(require('chai-as-promised'))
    .use(require('chai-bignumber')(BigNumber))
    .should();

const FintechCoin = artifacts.require("./FintechCoin.sol");

contract('FintechCoin', function(accounts) {
    let token;

    let account_one = accounts[0];
    let account_two = accounts[1];
    let amount = 100;

    beforeEach(async function() {
        token = await FintechCoin.new();
    });

    describe("Minting", function(){
        it("Is mintable until minting is turned off by admin", async function(){
            let mintingFinished = await token.mintingFinished();
            mintingFinished.should.be.false;

            await token.mint(account_two, amount, {from: account_one});
            await token.finishMinting();
            let mintingFinishedAfter = await token.mintingFinished();

            mintingFinishedAfter.should.be.true;
        });

        it("Properly mints when mintable", async function(){
            let account_two_starting_balance = await token.balanceOf(account_two);

            await token.mint(account_two, amount, {from: account_one});
            let account_two_ending_balance = await token.balanceOf(account_two);

            account_two_ending_balance.toNumber().should.be.equal(account_two_starting_balance.toNumber() + amount);
        });

        it("Disallows minting when not mintable", async function(){
            let account_two_starting_balance = await token.balanceOf(account_two);

            await token.finishMinting();
            await token.mint(account_two, amount, {from: account_one}).should.be.rejectedWith(EVMRevert);
            let account_two_ending_balance = await token.balanceOf(account_two);

            account_two_ending_balance.toNumber().should.be.equal(account_two_starting_balance.toNumber());
        });

        it("Is not tradeable while still mintable", async function(){
            await token.transfer(account_two, amount, {from: account_one}).should.be.rejectedWith(EVMRevert);
            // TODO similar tests for transferFrom, approve.
        });

        it("Is tradeable when no longer mintable", async function(){
            let account_two_starting_balance = await token.balanceOf(account_two);

            await token.mint(account_one, amount);
            await token.finishMinting();
            await token.transfer(account_two, amount, {from: account_one}).should.be.fulfilled;


            let account_two_ending_balance = await token.balanceOf(account_two);
            account_two_ending_balance.toNumber().should.be.bignumber.equal(account_two_starting_balance.add(amount));
        });
    });
    // TODO ensure superclass behaviours still work.
});
