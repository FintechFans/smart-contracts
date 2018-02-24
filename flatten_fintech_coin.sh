#!/bin/bash
solidity_flattener --solc-paths "zeppelin-solidity=`pwd`/node_modules/zeppelin-solidity" contracts/FintechCoin.sol --output flattened_contracts/FintechCoinFlattened.sol
