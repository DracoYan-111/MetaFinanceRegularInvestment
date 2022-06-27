//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./storages/MFIRegularInvestmentFactoryStorage.sol"; //["1","1","1","1","1","1"]["1","1","5","2","13","4"]
import "./utils/MfiAccessControl.sol";
import "./interfaces/IMFIRegularInvestmentFactory.sol";

contract MFIRegularInvestmentFactory is MfiAccessControl, ReentrancyGuardUpgradeable, MFIRegularInvestmentFactoryStorage {
    using SafeMath for uint256;

    bytes32 public constant INIT_CODE_PAIR_HASH = keccak256(abi.encodePacked(type(tradingContract).creationCode));

    function initialize() public initializer {
        proportion = 100;
        __ReentrancyGuard_init();
    }
    //=================== view ===================

    /**
    * @dev Query the number of trading contracts used for the lock time
    * @param _index Lock time index
    * @return newData_ Number of contracts used
    */
    function getLockSpanData(uint256 _index) external view returns (uint256 newData_){
        newData_ = (timeSpan[_index].div(1 weeks)).div(lockSpan[timeSpan[_index]]).add(1);
    }

    /**
    * @dev Get the mining pool pledge ratio(6 == timeSpan.length)
    * @param _amount Number of transactions
    * @return newAmount_ Real transaction ratio
    */
    function getPoolPledgeRatio(uint256 _amount) external view returns (uint256[6] memory newAmount_){
        require(turnOn, "MFIRI:E2");
        uint256 _internalQuantity;
        for (uint256 i = 0; i < 6; ++i) {
            if (i != 5) {
                newAmount_[i] = _amount.mul(timeSpanDepositRatio[timeSpan[i]]).div(proportion);
                _internalQuantity += newAmount_[i];
            } else {
                newAmount_[i] = _amount.sub(_internalQuantity);
            }
        }
    }

    //============================================

    /**
    * @dev Set the pledge ratio and lock-up period
    * @param _timeSpanDepositRatio Pledge ratio
    * @param _lockSpan Unlock time
    */
    function setTimeSpanDepositRatio(uint256[] calldata _timeSpanDepositRatio, uint256[] calldata _lockSpan) public {
        require(_timeSpanDepositRatio.length == 6 && _lockSpan.length == 6, "MFIRI:E0");
        for (uint256 i = 0; i < 6; ++i) {
            timeSpanDepositRatio[timeSpan[i]] = _timeSpanDepositRatio[i];
            lockSpan[timeSpan[i]] = _lockSpan[i];
        }
        turnOn = true;
    }

    /**
    * @dev Update contract version
    * @param _newVersion New contract version
    */
    function updateContractVersion(uint256 _newVersion) public {
        require(contractVersion < _newVersion, "MFIRI:E1");
        contractVersion = _newVersion;
    }

    /**
    * @dev Create tradingContract
    * @param _index Lock time array subscript
    */
    function createPair(uint256 _index,uint256 _amount) external {
        bytes memory bytecode = type(tradingContract).creationCode;
        uint256 time = timeSpan[_index];
        for (uint256 i = 0; i < _amount; ++i) {
        uint256 _pid = timeSpanPid[_index];
        bytes32 salt = keccak256(abi.encodePacked(contractVersion, _pid, time));
        address tradingContract_;

        assembly {
            tradingContract_ := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        //        uint256 oldEndTime =
        //        allTradingContract[_index].length != 0 ?
        //        tradingContract(allTradingContract[_index][_pid - 1]).endTime() : block.timestamp;
        //
        allTradingContract[_index].push(tradingContract_);
        //        tradingContract(tradingContract_).initialize(_pid, time, (lockSpan[time].mul(1 weeks)).add(oldEndTime));
        timeSpanPid[_index]++;
        }
    }
}


contract tradingContract {

    address public factory;
    uint256 public startTime;
    //uint256 public lockTime;
    uint256 public tradingContractId;

    //    // called once by the factory at time of deployment
    //    function initialize(
    //        uint256 _pid,
    //        uint256 _lockTime,
    //        uint256 _endTime
    //    ) external {
    //        factory = msg.sender;
    //        endTime = _endTime;
    //        lockTime = _lockTime;
    //        tradingContractId = _pid;
    //    }
    ICakePool public  constant cakePool = ICakePool(0x45c54210128a065de780C4B0Df3d16664f7f859e);

    uint256[6]  public lengths = [1 weeks, 2 weeks, 5 weeks, 10 weeks, 26 weeks, 52 weeks];

    mapping(uint256 => address[]) addrs;//跨度对应合约

    struct data {
        uint256 rewardAndLockAmount;
        uint256 lockEndTime;
    }

    //    constructor(){
    //        CakePool = ICakePool(0x45c54210128a065de780C4B0Df3d16664f7f859e);
    //
    //    }

    function getCakePoolRewardByCakePoolAddrAndUserAddr(address _addr) public view returns (uint256, uint256, uint256){
        uint256 cakePoolBalanceOf = cakePool.balanceOf();
        uint256 cakePoolTotalShares = cakePool.totalShares();
        if (cakePoolTotalShares == 0) return (0, 0, 0);
        (uint256 shares,, uint256 cakeAtLastUserAction,,, uint256 lockEndTime, uint256 userBoostedShare, bool lock, uint256 lockedAmount) = cakePool.userInfo(_addr);
        if (lock) {
            return (lockedAmount, (cakePoolBalanceOf * shares / cakePoolTotalShares) - userBoostedShare - lockedAmount, lockEndTime);
        } else {
            return (cakeAtLastUserAction, (cakePoolBalanceOf * shares / cakePoolTotalShares) - cakeAtLastUserAction, lockEndTime);
        }
    }

    function getBalanceOfByAddr() public view returns (data[6] memory addrBalanceOf_) {
        for (uint256 i = 0; i < 6; ++i) {
            uint256 value = 0;
            uint256 endTime = 0;
            address[] memory _addrs = addrs[lengths[i]];
            for (uint256 j = 0; j < _addrs.length; ++j) {
                (uint256 lockedAmount, uint256 rewardAmount, uint256 lockEndTime) = getCakePoolRewardByCakePoolAddrAndUserAddr(_addrs[j]);
                value += (lockedAmount + rewardAmount);
                endTime = lockEndTime;
            }
            addrBalanceOf_[i].rewardAndLockAmount += value;
            addrBalanceOf_[i].lockEndTime = endTime;
        }
    }


}

