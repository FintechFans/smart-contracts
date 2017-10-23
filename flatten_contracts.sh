#!/bin/bash
solidity_flattener --solc-paths "zeppelin-solidity=`pwd`/node_modules/zeppelin-solidity" contracts/FintechFansCrowdsale.sol --output FintechFansCrowdsaleFlattened.sol
