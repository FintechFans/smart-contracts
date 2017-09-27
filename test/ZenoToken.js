'use strict';

import EVMThrow from './helpers/EVMThrow';

const BigNumber = web3.BigNumber;

require('chai')
    .use(require('chai-as-promised'))
    .use(require('chai-bignumber')(BigNumber))
    .should();

const ZenoToken = artifacts.require("./ZenoToken.sol");

contract('ZenoToken', function(accounts) {
    before(function(){
        this.total_supply = 1e36;
    });

    beforeEach(async function() {
        this.instance = await ZenoToken.new("MyZenoToken", "ZT", 18, this.total_supply);
    });

    it("Should return the set name", async function() {
        let name = await this.instance.name();
        name.should.be.equal("MyZenoToken");
    });

    it("Should return the set symbol", async function() {
        let name = await this.instance.symbol();
        name.should.be.equal("ZT");
    });

    it("Should return the set decimals amount", async function() {
        let name = await this.instance.decimals();
        name.should.be.bignumber.equal(18);
    });

    it("should put 1e36 ZenoToken in the creator's account", async function() {
        let balance = await this.instance.balanceOf(accounts[0]);
        balance.should.be.bignumber.equal(this.total_supply);
    });

    it("should transfer tokens correctly", async function() {

        // Get initial balances of first and second account.
        let account_one = accounts[0];
        let account_two = accounts[1];

        let amount = 100;

        let account_one_starting_balance = await this.instance.balanceOf(account_one);
        let account_two_starting_balance = await this.instance.balanceOf(account_two);

        await this.instance.transfer(account_two, amount, {from: account_one});

        let account_one_ending_balance = await this.instance.balanceOf(account_one);
        let account_two_ending_balance = await this.instance.balanceOf(account_two);

        account_one_ending_balance.toNumber().should.be.equal(account_one_starting_balance.toNumber() - amount);
        account_two_ending_balance.toNumber().should.be.equal(account_two_starting_balance.toNumber() + amount);
    });

    it("Should redistribute tokens correctly", async function(){
        // Get initial balances of first and second account.
        let account_one = accounts[0];
        let account_two = accounts[1];

        let amount = this.total_supply / 2; // Half of available tokens (TODO: Configurable)

        let account_one_starting_balance = await this.instance.balanceOf(account_one);
        let account_two_starting_balance = await this.instance.balanceOf(account_two);

        await this.instance.transfer(account_two, amount, {from: account_one});
        await this.instance.redistribute(amount, {from: account_one});

        let account_one_ending_balance = await this.instance.balanceOf(account_one);
        let account_two_ending_balance = await this.instance.balanceOf(account_two);

        account_two_ending_balance.toNumber().should.be.equal(this.total_supply);
        account_one_ending_balance.toNumber().should.be.equal(0);
    });
});
