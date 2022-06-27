//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./interfaces/IMFIRegularInvestmentRouter.sol";
import "./utils/MfiAccessControl.sol";

contract MFIRegularInvestmentRouter is MfiAccessControl {


    uint256[6] public LastAmount;
    mapping(uint256 => uint256) public amountPid;


    IMFIRegularInvestmentFactory public factory;

    function initialize(IMFIRegularInvestmentFactory _factoryAddress) public {
        factory = _factoryAddress;
        for (uint256 i = 0; i < 6; ++i) {
            LastAmount[i] = factory.getLockSpanData(i);
        }
    }


    // function userPledge(uint256 _amount) public {
    //     uint256[6] memory pid_ = findUsingPool();
    //     for (uint256 i = 0; i < 6; ++i) {
    //         if (amountPid[timeSpan[i]] != pid_[i])
    //             amountPid[timeSpan[i]] = pid_[i];1656604800

    //         ITradingContract tradingContract_ = ITradingContract(tradingContractFor(amountPid[timeSpan[i]] - 1, timeSpan[i]));["1656000000","1656000000","1656000000","1656000000","1656000000","1656000000"]

    //         //tradingContract_.zhiya();

    //     }
    // }




    // function findUsingPool() public view returns (uint256[6] memory pid_){
    //     for (uint256 i = 0; i < 6; ++i) {
    //         if (amountPid[timeSpan[i]] != 0) {
    //             ITradingContract tradingContract_ = ITradingContract(tradingContractFor(amountPid[timeSpan[i].sub(1)], timeSpan[i]));
    //             uint256 span_ = block.timestamp.sub(tradingContract_.startTime().add(factory.lockSpan[timeSpan[i]])).div(factory.lockSpan[timeSpan[i]]);
    //             pid_[i] = span_.add(1);
    //         }
    //     }
    // }


    function userPledge(uint256 _amount,uint256 _blockTimestamp, uint256[6] memory _startTime) public {
        uint256[6] memory pid_ = findUsingPool(_blockTimestamp, _startTime);
        factory.getPoolPledgeRatio(_amount);
        for (uint256 i = 0; i < 6; ++i) {
            if (amountPid[timeSpan[i]] != pid_[i])
                amountPid[timeSpan[i]] = pid_[i];

            //ITradingContract tradingContract_ = ITradingContract(tradingContractFor(amountPid[timeSpan[i]] - 1, timeSpan[i]));

            //tradingContract_.zhiya();

        }
    }

    function findUsingPool(uint256 _blockTimestamp, uint256[6] memory _startTime) public view returns (uint256[6] memory pid_){
        for (uint256 i = 0; i < 6; ++i) {
            uint256 timeSpans = timeSpan[i];
            if (amountPid[timeSpans] != 0) {
                uint256 span_;
                //ITradingContract tradingContract_ = ITradingContract(tradingContractFor(amountPid[timeSpan[i].sub(1)], timeSpan[i]));
                if (_blockTimestamp >= _startTime[i] + (factory.lockSpan(timeSpans) * 1 weeks)) {
                    pid_[i] = amountPid[timeSpan[i]];
                    span_ = (_blockTimestamp - (_startTime[i] + (factory.lockSpan(timeSpans) * 1 weeks))) / (factory.lockSpan(timeSpans) * 1 weeks);
                }
                pid_[i] += span_;
            }
            pid_[i] += 1;
        }
    }


    function tradingContractFor(uint256 _pid, uint256 _lockTime) public view returns (address tradingContract) {
        uint256 _contractVersion = factory.contractVersion();
        tradingContract = address(uint160(uint256(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(_contractVersion, _pid, _lockTime)),
                hex'920c98128e0b907c48115c22c58fe0ef3309959b9df33ed8a66e8d8f018bcb9c' // init code hash
            )))));
    }
}