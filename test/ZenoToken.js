var ZenoToken = artifacts.require("./ZenoToken.sol");

contract('ZenoToken', function(accounts) {
    beforeEach(async function() {
        this.instance = await ZenoToken.new();
    });

    it("should put 1e36 ZenoToken in the creator's account", async function() {
        let balance = await this.instance.balanceOf(accounts[0]);
        assert.equal(balance.valueOf(), 1e36, "10000 wasn't in the first account");
    });
    it("should transfer tokens correctly", async function() {

        // Get initial balances of first and second account.
        var account_one = accounts[0];
        var account_two = accounts[1];

        var account_one_starting_balance;
        var account_two_starting_balance;
        var account_one_ending_balance;
        var account_two_ending_balance;

        var amount = 10;

        account_one_starting_balance = await instance.balanceOf(account_one).toNumber();
        account_two_starting_balance = await instance.balanceOf(account_two).toNumber();

        await instance.transfer(account_two, amount, {from: account_one});

        account_one_ending_balance = await instance.balanceOf(account_one).toNumber();
        account_two_ending_balance = await instance.balanceOf(account_two).toNumber();


        assert.equal(account_one_ending_balance, account_one_starting_balance - amount, "Amount wasn't correctly taken from the sender");
        assert.equal(account_two_ending_balance, account_two_starting_balance + amount, "Amount wasn't correctly sent to the receiver");
    });
});

// contract('ZenoToken', function(accounts) {
//     it("Should redistribute tokens correctly", function(){
//         var instance;

//         // Get initial balances of first and second account.
//         var account_one = accounts[0];
//         var account_two = accounts[1];

//         var account_one_starting_balance;
//         var account_two_starting_balance;
//         var account_one_ending_balance;
//         var account_two_ending_balance;

//         var amount = 5e35;

//         return ZenoToken.deployed().then(function(instance_) {
//             instance = instance_;
//             return instance.balanceOf.call(account_one);
//         }).then(function(balance) {
//             account_one_starting_balance = balance.toNumber();
//             return instance.balanceOf.call(account_two);
//         }).then(function(balance) {
//             account_two_starting_balance = balance.toNumber();
//             return instance.transfer(account_two, amount, {from: account_one});
//         }).then(function() {
//             return instance.redistribute(amount, {from: account_one});
//         }).then(function(result){
//             // console.log("Result:", result);
//             return instance.balanceOf.call(account_one);
//         }).then(function(balance){
//             account_one_ending_balance = balance;
//             return instance.balanceOf.call(account_two);
//         }).then(function(balance){
//             account_two_ending_balance = balance;

//             // console.log(account_one_starting_balance);
//             // console.log(account_two_starting_balance);
//             // console.log(account_one_ending_balance.valueOf());
//             // console.log(account_two_ending_balance.valueOf());

//             assert.equal(account_two_ending_balance.valueOf(), 1e36, "Improper redistribution");
//             assert.equal(account_one_ending_balance.valueOf(), 0, "Improper redistribution");
//         });

//     });
// });
