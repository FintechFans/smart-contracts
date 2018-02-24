#!/bin/bash

echo "Ensuring up-to-date OpenZeppelin contracts..."
rm -rf ./contracts/zeppelin-solidity
cp -r ./node_modules/zeppelin-solidity ./contracts/zeppelin-solidity

echo "Starting flattening proces..."

solidity_flattener --solc-paths "zeppelin-solidity=./contracts/zeppelin-solidity" contracts/FintechCoin.sol --output flattened_contracts/FintechCoinFlattened.sol

echo "Done!"
