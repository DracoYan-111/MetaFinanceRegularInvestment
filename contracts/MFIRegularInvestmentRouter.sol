//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./storages/MFIRegularInvestmentRouterStorage.sol"; //["1","1","1","1","1","1"]["1","1","5","2","13","4"]
import "./utils/MfiAccessControl.sol";

contract MFIRegularInvestmentRouter is MfiAccessControl, MFIRegularInvestmentRouterStorage {
    using SafeMath for uint256;

    function initialize(IMFIRegularInvestmentFactory _factoryAddress) public {
        factory = _factoryAddress;
        for (uint256 i = 0; i < 6; ++i) {
            LastAmount[i] = factory.getLockSpanData(i);
        }
    }
    //
    //    function userPledge(uint256 _amount, uint256 _blockTimestamp, uint256[6] memory _startTime) public {
    //        uint256[6] memory pid_ = findUsingPool( _startTime);
    //        uint256[6] memory pledgeRatio = factory.getPoolPledgeRatio(_amount);
    //        for (uint256 i = 0; i < 6; ++i) {
    //            uint256 timeSpans = timeSpan[i];
    //            if (amountPid[timeSpans] != pid_[i])
    //                amountPid[timeSpans] = pid_[i];
    //
    //            //ITradingContract tradingContract_;
    //            //            if (amountPid[timeSpans] != 0) {
    //            //                tradingContract_ = tradingContractFor(amountPid[timeSpans] - 1, timeSpans);
    //            //            } else {
    //            //                tradingContract_ = tradingContractFor(amountPid[timeSpans], timeSpans);
    //            //            }
    //
    //            uint256 amountPids = amountPid[timeSpans] != 0 && amountPid[timeSpans] < LastAmount[i]
    //            ? amountPid[timeSpans] - 1 : 0;
    //
    //            ITradingContract tradingContract_ = tradingContractFor(amountPids, timeSpans);
    //            if (tradingContract_.startTime() == 0)
    //                tradingContract_.initialize(amountPids, timeSpans, block.timestamp);
    //
    //            tradingContract_.userPledge(false, pledgeRatio[i]);
    //
    //        }
    //    }
    //
    //    function findUsingPool(uint256[6] memory _startTime) public view returns (uint256[6] memory pid_){
    //        uint256 _blockTimestamp = block.timestamp;
    //        for (uint256 i = 0; i < 6; ++i) {
    //            uint256 timeSpans = timeSpan[i];
    //            uint256 lockSpans = factory.lockSpan(timeSpans).mul(1 weeks);
    //            if (amountPid[timeSpans] != 0) {
    //                uint256 span_;
    //                uint256 amountPids = amountPid[timeSpans] != 0 && amountPid[timeSpans] < LastAmount[i]
    //                ? amountPid[timeSpans] - 1 : 0;
    //
    //                ITradingContract tradingContract_ = tradingContractFor(amountPids, timeSpans);
    //
    //                uint256 starTime = tradingContract_.startTime();
    //                if (_blockTimestamp >= starTime.add(lockSpans)) {
    //                    pid_[i] = amountPid[timeSpans];
    //                    span_ = (_blockTimestamp.sub(starTime.add(lockSpans))).div(lockSpans);
    //                    pid_[i] += span_;
    //                }
    //            } else {
    //                pid_[i] += 1;
    //            }
    //        }
    //
    //        for (uint256 i = 0; i < 6; ++i) {
    //            if (pid_[i] > LastAmount[i]) {
    //                pid_[i] = LastAmount[i] - pid_[i];
    //            }
    //        }
    //    }
    //
    //
    //       function userPledges(uint256 _amount, uint256 _blockTimestamp, uint256[6] memory _startTime) public {
    //           uint256[6] memory pid_ = findUsingPool(_blockTimestamp, _startTime);
    //           uint256[6] memory pledgeRatio = factory.getPoolPledgeRatio(_amount);
    //           for (uint256 i = 0; i < 6; ++i) {
    //               uint256 timeSpans = timeSpan[i];
    //               if (amountPid[timeSpans] != pid_[i])
    //                   amountPid[timeSpans] = pid_[i];
    //
    //            //    //ITradingContract tradingContract_;
    //            //    //            if (amountPid[timeSpans] != 0) {
    //            //    //                tradingContract_ = tradingContractFor(amountPid[timeSpans] - 1, timeSpans);
    //            //    //            } else {
    //            //    //                tradingContract_ = tradingContractFor(amountPid[timeSpans], timeSpans);
    //            //    //            }
    //
    //            //    uint256 amountPids = amountPid[timeSpans] != 0 && amountPid[timeSpans] < LastAmount[i]
    //            //    ? amountPid[timeSpans] - 1 : 0;
    //
    //            //    ITradingContract tradingContract_ = tradingContractFor(amountPids, timeSpans);
    //            //    if (tradingContract_.startTime() == 0)
    //            //        tradingContract_.initialize(amountPids, timeSpans, block.timestamp);
    //
    //            //    tradingContract_.userPledge(false, pledgeRatio[i]);
    //
    //           }
    //       }
    //
    //       function findUsingPool(uint256 _blockTimestamp, uint256[6] memory _startTime) public view returns (uint256[6] memory pid_){
    //           for (uint256 i = 0; i < 6; ++i) {
    //               uint256 timeSpans = timeSpan[i];
    //               uint256 lockSpans = factory.lockSpan(timeSpans).mul(1 weeks);
    //               if (amountPid[timeSpans] != 0) {
    //                   pid_[i] = amountPid[timeSpans];
    //                   if (_blockTimestamp >= _startTime[i].add(lockSpans)) {
    //                       uint256 span_ = (_blockTimestamp.sub(_startTime[i].add(lockSpans))).div(lockSpans);
    //                       pid_[i] += span_.add(1);
    //                   }
    //               }else{
    //                      pid_[i] += 1;
    //
    //               }
    //
    //           }
    //
    //           for (uint256 i = 0; i < 6; ++i) {
    //            if (pid_[i] > LastAmount[i]) {
    //                pid_[i] = LastAmount[i] - pid_[i];
    //            }
    //        }
    //       }
    //
    //
    //    function tradingContractFor(uint256 _pid, uint256 _lockTime) public view returns (ITradingContract tradingContract) {
    //        uint256 _contractVersion = factory.contractVersion();
    //        tradingContract = ITradingContract(address(uint160(uint256(keccak256(abi.encodePacked(
    //                hex'ff',
    //                factory,
    //                keccak256(abi.encodePacked(_contractVersion, _pid, _lockTime)),
    //                hex'9aefb4c7db3a5bb893c21f1ef91b4f9759e45a4a8734ffd29e1c001604ce7daf' // init code hash
    //            ))))));
    //    }
    // 成功event
    event SuccessEvent();

    // 失败event
    event CatchEvent(string message);
    event CatchByte(bytes data);

    function userPledges(uint256 _amount) external {
        address[6] memory latestAddress = factory.getLatestAddress();
        uint256[6] memory pledgeRatio = factory.getPoolPledgeRatio(_amount);
        for (uint256 i = 0; i < 6; ++i) {
            try ITradingContract(latestAddress[i]).userPledge(false, pledgeRatio[i]){
                emit CatchEvent("chenggong");
            } catch Error(string memory shibai_){
                // call不成功的情况下
                emit CatchEvent(shibai_);
            }
        }
    }
}