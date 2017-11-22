#!/bin/bash
solidity_flattener --solc-paths "zeppelin-solidity=`pwd`/node_modules/zeppelin-solidity" contracts/TheFintechFansCrowdsale.sol --output flattened_contracts/TheFintechFansCrowdsaleFlattened.sol
