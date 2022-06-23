//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./storages/MFIRegularInvestmentFactoryStorage.sol"; //["1","1","1","1","1","1"]["1","1","5","2","13","4"]
import "./utils/MfiAccessControl.sol";

contract MFIRegularInvestmentFactory is MfiAccessControl, ReentrancyGuardUpgradeable, MFIRegularInvestmentFactoryStorage {
    using SafeMath for uint256;

    bytes32 public constant INIT_CODE_PAIR_HASH = keccak256(abi.encodePacked(type(tradingContract).creationCode));

    function initialize() public initializer {
        proportion = 100;
        __ReentrancyGuard_init();
    }
    //=================== view ===================

    function getLockSpanData(uint256 _index) external view returns (uint256 newData_){
        newData_ = (timeSpan[_index].div(1 weeks)).div(lockSpan[timeSpan[_index]]).add(1);
    }

    //============================================
    function setTimeSpanDepositRatio(uint256[] calldata _timeSpanDepositRatio, uint256[] calldata _lockSpan) public {
        require(_timeSpanDepositRatio.length == timeSpan.length && _lockSpan.length == timeSpan.length, "MFIRI:E0");
        for (uint256 i = 0; i < _timeSpanDepositRatio.length; ++i) {
            timeSpanDepositRatio[timeSpan[i]] = _timeSpanDepositRatio[i];
            lockSpan[timeSpan[i]] = _lockSpan[i];
        }
    }

    function updateContractVersion(uint256 _newVersion) public {
        require(contractVersion < _newVersion, "MFIRI:E1");
        contractVersion = _newVersion;
    }

    function createPair(uint256 _index) external {
        bytes memory bytecode = type(tradingContract).creationCode;
        uint256 time = timeSpan[_index];
        //for (uint256 i = 0; i < _amount; ++i) {
        uint256 _pid = timeSpanPid[_index];
        bytes32 salt = keccak256(abi.encodePacked(contractVersion, _pid, time));
        address tradingContract_;
        assembly {
            tradingContract_ := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        uint256 oldEndTime =
        allTradingContract[_index].length != 0 ?
        tradingContract(allTradingContract[_index][_pid - 1]).endTime() : block.timestamp;

        allTradingContract[_index].push(tradingContract_);
        tradingContract(tradingContract_).initialize(_pid, time, (lockSpan[time].mul(1 weeks)).add(oldEndTime));
        timeSpanPid[_index]++;
        //}
    }
}


contract tradingContract {

    address public factory;
    uint256 public endTime;
    uint256 public lockTime;
    uint256 public tradingContractId;

    // called once by the factory at time of deployment
    function initialize(
        uint256 _pid,
        uint256 _lockTime,
        uint256 _endTime
    ) external {
        factory = msg.sender;
        endTime = _endTime;
        lockTime = _lockTime;
        tradingContractId = _pid;
    }
}

