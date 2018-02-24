'use strict';

import ether from './helpers/ether.js';
import {advanceBlock} from './helpers/advanceToBlock';
import {increaseTimeTo, duration} from './helpers/increaseTime';
import latestTime from './helpers/latestTime';
import EVMThrow from './helpers/EVMThrow';
import EVMRevert from './helpers/EVMRevert';

const BigNumber = web3.BigNumber;

require('chai')
    .use(require('chai-as-promised'))
    .use(require('chai-bignumber')(BigNumber))
    .should();
const expect = require('chai').expect;

const BurnableTokenMock = artifacts.require("./helpers/ApprovedBurnableTokenMock.sol");

contract('ApprovedBurnableToken', function (accounts) {
    let token;
    let expectedTokenSupply = new BigNumber(999);

    beforeEach(async function () {
        token = await BurnableTokenMock.new(accounts[0], 1000);
    });

    it('owner should be able to burn tokens', async function () {
        const { logs } = await token.burn(1, { from: accounts[0] });

        const balance = await token.balanceOf(accounts[0]);
        balance.should.be.bignumber.equal(expectedTokenSupply);

        const totalSupply = await token.totalSupply();
        totalSupply.should.be.bignumber.equal(expectedTokenSupply);

        const event = logs.find(e => e.event === 'Burn');
        expect(event).to.exist;
    });

    it('cannot burn more tokens than your balance', async function () {
        await token.burn(2000, { from: accounts[0] })
            .should.be.rejectedWith(EVMRevert);
    });

    it('burner should be able to burn tokens when allowed by owner', async function () {
        await token.approve(accounts[1], 1, {from: accounts[0]});
        const { logs } = await token.burnFrom(accounts[0], 1, { from: accounts[1] });

        const balance = await token.balanceOf(accounts[0]);
        balance.should.be.bignumber.equal(expectedTokenSupply);

        const totalSupply = await token.totalSupply();
        totalSupply.should.be.bignumber.equal(expectedTokenSupply);

        const event = logs.find(e => e.event === 'Burn');
        expect(event).to.exist;  // Still sends Burn event.

        const event2 = logs.find(e => e.event === 'BurnFrom');
        expect(event2).to.exist; // also sends BurnFrom event.
    });

    it('burner cannot burn more tokens than your balance', async function () {
        await token.approve(accounts[1], 1, {from: accounts[0]});
        await token.burnFrom(accounts[0], 2000, { from: accounts[1] })
            .should.be.rejectedWith(EVMRevert);
    });

    it('burner cannot burn more tokens than you allowed them', async function () {
        await token.approve(accounts[1], 1, {from: accounts[0]});
        await token.burnFrom(accounts[0], 2, { from: accounts[1] })
            .should.be.rejectedWith(EVMRevert);
    });

    // TODO Test with Smart Contract that burns for you. (Placeholder for the Marketplace)
});

