pragma solidity ^0.4.11;

import "./math/SafeMath.sol";
import "./HumanERC20TokenInterface.sol";

contract ZenoTokenRecipient { function receiveApproval(address from, uint256 value, address token, bytes _extraData); }

/**
   @title ZenoToken
   @author Wiebe-Marten Wijnja

   A ZenoToken is a token whose value can be redistributed proportionally
   across all token holders when someone spends a bit of it.

   ALL RIGHTS RESERVED by Wiebe-Marten Wijnja
 */
contract ZenoToken is HumanERC20TokenInterface("ZenoMarketToken", "☡", 27) {
    /* Public variables of the token */
    string public standard = 'ZenoToken v0.2.0';
    uint256 theTotalSupply = 1e36;
    uint256 constant originalWhole = 2**255;
    uint256 currentWhole = originalWhole;

    /* This creates an array with all balances */
    mapping (address => uint256) raw_balances;
    mapping (address => mapping (address => uint256)) raw_allowances;

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);
    event RawTransfer(address indexed from, address indexed to, uint256 raw_value);

    /* This notifies clients about the amount redistributet */
    event Redistribute(address indexed from, uint256 value);
    event RawRedistribute(address indexed from, uint256 raw_value);
    event UpdatedWhole(uint256 whole);

    /**
       @notice Initializes contract with initial supply tokens to the creator of the contract
     */
    function ZenoToken() {
        raw_balances[msg.sender] = currentWhole;
    }

    /**
       @notice Returns the total amount of tokens that exist.
       This is a constant amount, as tokens never get lost (but only proportionally redistributed).
     */
    function totalSupply() constant returns (uint256 total_supply) {
        return theTotalSupply;
    }

    /**
       @dev Transforms a balance relative to the `totalSupply` to the balance relative to `currentWhole`.
       @param balance a number between 0..totalSupply().
       @return The balance as a number between 0..currentWhole.
     */
    function balance2raw(uint256 balance) internal constant returns (uint256 raw_balance) {
        return balance * (currentWhole / theTotalSupply);
    }

    /**
       @dev Transforms a balance relative to the `currentWhole` to the balance relative to `totalSupply`.
       @param balance a number between 0..currentWhole
       @return The balance as a number between 0..totalSupply().
    */
    function raw2balance(uint256 raw_balance) internal constant returns (uint256 balance) {
        return raw_balance / (currentWhole / theTotalSupply);
    }

    /**
       @notice Returns the balance of `_owner` relative tot `totalSupply`.
       @param owner The address whose balance to look up.
       @return The balance as number 0..totalSupply()
     */
    function balanceOf(address owner) constant returns (uint256 balance) {
        return raw2balance(rawBalanceOf(owner));
    }

    /**
       @dev Returns the raw balance of `_owner`.
       This function exists for debug purposes only.
       @param owner The address whose balance to look up.
       @return The balance as number 0..currentWhole
     */
    function rawBalanceOf(address owner) constant returns (uint256 balance) {
        return raw_balances[owner];
    }

    /**
       @notice Looks up how much `spender` can spend of `owner`'s tokens.
       @param owner The owner who set up the allowance before
       @param spender the address that can spend tokens of the owner.
       @return The remaining balance that still can be spent as a number 0..totalSupply().
     */
    function allowance(address owner, address spender) constant returns (uint remaining) {
        return raw2balance(rawAllowance(owner, spender));
    }

    /**
       @dev Looks up how much `spender` can spend of `owner`'s tokens.
            Debug-only function.
       @param owner The owner who set up the allowance before
       @param spender the address that can spend tokens of the owner.
       @return The remaining balance that still can be spent as a number 0..currentWhole.
    */
    function rawAllowance(address owner, address spender) constant returns (uint remaining) {
        return raw_allowances[owner][spender];
    }

    /**
       @notice ERC20-compliant transfer function.
       @param to The recipient of the tokens
       @param value the amount of tokens to send.
       @return `false` if improper call, `true` if succeeded.
     */
    function transfer(address to, uint256 value) returns (bool success) {
        var raw_value = balance2raw(value);
        bool result =  rawTransfer(to, raw_value);
        Transfer(msg.sender, to, value);                         // Notify anyone listening that this transfer took place
        return result;
    }

    /**
       @notice Allows you to transfer raw amounts directly.
               In most cases, you should consider using `transfer(to, value)` instead.
       @param to The recipient of the tokens
       @param raw_value the amount of tokens to send, as a number between 0..currentWhole.
       @return `false` if improper call, `true` if succeeded.
    */
    function rawTransfer(address to, uint256 raw_value) returns (bool success) {
        if (to == 0x0) return false;                                        // Prevent transfer to 0x0 address. Use redistribute() instead
        if (raw_balances[msg.sender] < raw_value) return false;             // Check if the sender has enough
        if (raw_balances[to] + raw_value < raw_balances[to]) return false;  // Check for overflows

        raw_balances[msg.sender] -= raw_value;                     // Subtract from the sender
        raw_balances[to] += raw_value;                            // Add the same to the recipient
        RawTransfer(msg.sender, to, raw_value);
        UpdatedWhole(currentWhole);

        return true;
    }

    /**
       @notice Allow another person, `spender` to spend some tokens in your behalf
       @param spender the address that you'll allow to spend some tokens.
       @param value The amount of tokens that is allowed to be spent.
    */
    function approve(address spender, uint256 value) returns (bool success) {
        var raw_value = balance2raw(value);
        raw_allowances[msg.sender][spender] = raw_value;
        return true;
    }

    // TODO Should we keep this function or remove it?
    /**
       @notice Approve and then communicate the approved contract in a single transaction
         `receiveApproval` is called on the recipient contract.
    */
    function approveAndCall(address _spender, uint256 value, bytes _extraData) returns (bool success) {
        var raw_value = balance2raw(value);

        ZenoTokenRecipient spender = ZenoTokenRecipient(_spender);
        if (approve(_spender, raw_value)) {
            spender.receiveApproval(msg.sender, value, this, _extraData);
            return true;
        }
    }

    /**
       @notice Transfer function for when contracts attempt to transfer
               as a proxy for another address.
       @param from The originating address
       @param to The address to send the value to
       @param value The amount of tokens to send.
       @return `true` if succeeded, `false` if there was a problem (an invalid address, an improper value amount, etc).
    */
    function transferFrom(address from, address to, uint256 value) returns (bool success) {
        var raw_value = balance2raw(value);

        if (to == 0x0) return false;                                         // Prevent transfer to 0x0 address. Use redistribute() instead
        if (raw_balances[from] < raw_value) return false;                    // Check if the sender has enough
        if (raw_balances[to] + raw_value < raw_balances[to]) return false;  // Check for overflows
        if (raw_value > raw_allowances[from][msg.sender]) return false;      // Check allowance

        raw_balances[from] -= raw_value;                           // Subtract from the sender
        raw_balances[to] += raw_value;                             // Add the same to the recipient
        raw_allowances[from][msg.sender] -= raw_value;
        RawTransfer(from, to, raw_value);
        Transfer(from, to, value);
        UpdatedWhole(currentWhole);
        return true;
    }

    /**
       @notice Redistributes `value` over all token holders proportionally.
         This is a constant-time operation.
         Usually, this is called internally by the contract built on top of
         the ZenoToken, for actions that permanently consume tokens.
       @param value The amount of tokens to redistribute.
     */
    function redistribute(uint256 value) returns (bool success) {
        var raw_value = balance2raw(value);

        if (raw_balances[msg.sender] < raw_value) return false;     // Check if the sender has enough
        if (currentWhole <= raw_value) return false;                 // Check if total still has enough

        raw_balances[msg.sender] = SafeMath.sub(raw_balances[msg.sender], raw_value);                      // Subtract from the sender
        currentWhole = SafeMath.sub(currentWhole, raw_value);                                  // Updates the amount of raw tokens left.

        RawRedistribute(msg.sender, raw_value);
        Redistribute(msg.sender, value);
        UpdatedWhole(currentWhole);
        return true;
    }

    /**
       Variant of redistribute that allows a proxy to redistribute some of your tokens for you.
     */
    function redistributeFrom(address from, uint256 value) returns (bool success) {
        var raw_value = balance2raw(value);

        if (raw_balances[from] < raw_value) return false;                 // Check if the sender has enough
        if (raw_value > raw_allowances[from][msg.sender]) return false;   // Check allowance
        if (currentWhole <= raw_value) return false;                      // Check if total still has enough

        raw_balances[from] -= raw_value;                                  // Subtract from the sender
        currentWhole -= raw_value;                                        // Updates the amount of raw tokens left.

        RawRedistribute(from, raw_value);
        Redistribute(from, value);
        UpdatedWhole(currentWhole);
        return true;
    }
}
