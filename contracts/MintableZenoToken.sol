pragma solidity ^0.4.11;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import "zeppelin-solidity/contracts/ownership/Ownable.sol";

import "./ZenoToken.sol";

/**
 * @title Mintable variant of the ZenoToken
 * @dev Alters the ZenoToken contract to allow its owner to mint it, until minting is set as 'finished'.
 * Based on code by OpenZeppelin: https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/token/MintableToken.sol
 */
contract MintableZenoToken is Ownable, ZenoToken {
    event Mint(address indexed to, uint256 amount);
    event MintFinished();

    bool public mintingFinished = false;

    function MintableZenoToken(
        string name,
        string symbol,
        uint8 decimals,
        /* `startingCurrentWhole` is needed because:
           - During minting this value scales up.
           - During redistribution this value scales down.

           So a reasonable value should be carefully picked for this,
           depending on how many tokens are supposed to ever exist.
         */
        uint256 startingCurrentWhole
    )
        // A starting supply of `1` is needed, because `balance2raw` will not work with `0`.
        ZenoToken(name, symbol, decimals, 1)
    {
        currentWhole = startingCurrentWhole;
    }

    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    /**
     * @dev Function to mint tokens
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
        uint256 raw_amount = balance2raw(_amount);
        currentWhole = SafeMath.add(currentWhole, raw_amount);
        theTotalSupply = SafeMath.add(theTotalSupply, _amount);
        raw_balances[_to] = SafeMath.add(raw_balances[_to], raw_amount);

        return true;
    }

    /**
     * @dev Function to stop minting new tokens.
     * @return True if the operation was successful.
     */
    function finishMinting() onlyOwner public returns (bool) {
        mintingFinished = true;
        MintFinished();
        return true;
  }
}
