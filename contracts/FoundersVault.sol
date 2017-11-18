pragma solidity ^0.4.11;


import 'zeppelin-solidity/contracts/token/TokenTimelock.sol';
import 'zeppelin-solidity/contracts/token/ERC20Basic.sol';

contract FoundersVault is TokenTimelock {

        function FoundersVault(ERC20Basic _token, address _beneficiary, uint64 _releaseTime)

                TokenTimelock(_token, _beneficiary, _releaseTime)
        {}
}
