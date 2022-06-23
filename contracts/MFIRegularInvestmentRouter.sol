//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./interfaces/IMFIRegularInvestmentRouter.sol";

contract MFIRegularInvestmentRouter {

    IMFIRegularInvestmentFactory public factory;

    function initialize(IMFIRegularInvestmentFactory _factoryAddress) public  {
        factory = _factoryAddress;
    }


    // function getPoolContractAmount() public view returns (uint256 amount_){
    //     uint256[] memory lockSpanData = factory.getLockSpanData();
    // }


    function tradingContractFor(uint256 _pid, uint256 _lockTime) public view returns (address tradingContract) {
        uint256 _contractVersion = factory.contractVersion();
        tradingContract = address(uint160(uint256(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(_contractVersion, _pid, _lockTime)),
                hex'04939b921247672dc2bf92a415e69c71090532fb39bac07ef81ed59006f73013' // init code hash
            )))));
    }
}