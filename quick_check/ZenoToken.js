'use strict';

import EVMThrow from '../test/helpers/EVMThrow';

const BigNumber = web3.BigNumber;

const ZenoToken = artifacts.require("../test/ZenoToken.sol");

var jsc = require("jsverify");

contract('ZenoToken', function(accounts) {
    var instance;
    before(function(){
        this.total_supply = 1e36;
    });

    beforeEach(async function() {
        instance = await ZenoToken.new("MyZenoToken", "ZT", 18, this.total_supply);
    });


    describe("Transfers", async function() {
        jsc.property("transfers ensure proper token amounts change ownership", "nat", async function(amount, num) {
            // this.instance = await ZenoToken.new("MyZenoToken", "ZT", 18, this.total_supply);
            let account_one = accounts[0];
            let account_two = accounts[1];

            let account_one_starting_balance = await instance.balanceOf(account_one);
            let account_two_starting_balance = await instance.balanceOf(account_two);

            await instance.transfer(account_two, amount, {from: account_one});

            let account_one_ending_balance = await instance.balanceOf(account_one);
            let account_two_ending_balance = await instance.balanceOf(account_two);

            let result =
                    (account_one_ending_balance.toNumber() == account_one_starting_balance.toNumber() + amount)
                    && (account_two_ending_balance.toNumber() == account_two_starting_balance.toNumber() + amount);
            return result;
        });
    });

    // describe("Redistribution", async function() {
    //     jsc.property("redistributions ensures people get proper token amounts", "nat", async function(amount, num) {
    //         // this.instance = await ZenoToken.new("MyZenoToken", "ZT", 18, this.total_supply);
    //         let account_one = accounts[0];
    //         let account_two = accounts[1];

    //         let account_one_starting_balance = await instance.balanceOf(account_one);
    //         let account_two_starting_balance = await instance.balanceOf(account_two);

    //         await this.instance.transfer(account_two, amount, {from: account_one});
    //         await instance.redistribute(amount, {from: account_one});

    //         let account_one_ending_balance = await instance.balanceOf(account_one);
    //         let account_two_ending_balance = await instance.balanceOf(account_two);

    //         let result =
    //                 (account_one_ending_balance.toNumber() == account_one_starting_balance.toNumber() + amount)
    //                 && (account_two_ending_balance.toNumber() == totalSupply());
    //         return result;
    //     });
    // });

});
