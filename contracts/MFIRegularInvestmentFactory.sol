//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./storages/MFIRegularInvestmentFactoryStorage.sol"; //["10","15","25","20","13","17"]["1","1","5","2","13","4"]
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
    * @return newData_ Number of contracts used
    */
    function getLockSpanData() public view returns (uint256[6] memory newData_){
        for (uint256 i = 0; i < 6; ++i) {
            newData_[i] = (timeSpan[i].div(1 weeks)).div(lockSpan[timeSpan[i]]).add(1);
        }
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

    /**
    * @dev Return the latest mining pool address
    * @return latestAddress_ Latest address array
    */
    function getLatestAddress() external view returns (address[6] memory latestAddress_){
        for (uint256 i = 0; i < 6; ++i) {
            uint256 length = allTradingContract[i].length;
            for (uint256 j = 0; j < length; ++j) {
                if (tradingContract(allTradingContract[i][j]).locking()) {
                    latestAddress_[i] = allTradingContract[i][j];
                    break;
                }
            }
        }
    }

    function getAllContract() external view returns (address[] memory allContract_){
        allContract_ = new address[](allContract.length);
        for (uint256 i = 0; i < allContract.length; ++i) {
            allContract_[i] = allContract[i];
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
    * @dev Create trading contracts in batches
    * @param _index Time index
    */
    function bulkCreation(uint256 _index, uint256 _amount) external {
        for (uint256 i = 0; i < _amount; ++i) {
            createPair(_index);
        }
    }

    /**
    * @dev Create tradingContract
    * @param _index Lock time array subscript
    */
    function createPair(uint256 _index/*, uint256 _amount*/) public {
        bytes memory bytecode = type(tradingContract).creationCode;
        uint256 time = timeSpan[_index];
        //for (uint256 i = 0; i < _amount; ++i) {
        uint256 _pid = timeSpanPid[_index];
        bytes32 salt = keccak256(abi.encodePacked(contractVersion, _pid, time));
        address tradingContract_;

        assembly {
            tradingContract_ := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        allTradingContract[_index].push(tradingContract_);
        timeSpanPid[_index]++;
        allContract.push(tradingContract_);
        //}
    }

    function initializeTradingContract(uint256[] calldata _index, tradingContract[] calldata _tradContractAddress) public {
        require(_index.length == _tradContractAddress.length, "MFIRI:E2");
        for (uint256 i = 0; i < _index.length; ++i) {
            _tradContractAddress[i].initialize(lockSpan[_index[i]], cakePool);
        }
    }

    function setLockTradingContract(tradingContract _tradContractAddress) public {
        _tradContractAddress.setLock();
    }
}


contract tradingContract {

    bool public locking;
    address public factory;
    uint256 public startTime;
    uint256 public lockTime;

    ICakePool public  cakePool;

    constructor(){
        factory = msg.sender;
    }

    // called once by the factory at time of deployment
    function initialize(
        uint256 _lockTime,
        ICakePool _cakePool
    ) external {
        locking = true;
        lockTime = _lockTime;
        startTime = block.timestamp;
        cakePool = _cakePool;
    }


    uint256[6]  public lengths = [1 weeks, 2 weeks, 5 weeks, 10 weeks, 26 weeks, 52 weeks];

    mapping(uint256 => address[]) spanCorrespondingContract;//跨度对应合约SpanCorrespondContract

    struct data {
        uint256 rewardAndLockAmount;
        uint256 lockEndTime;
    }

    //    constructor(){
    //        CakePool = ICakePool(0x45c54210128a065de780C4B0Df3d16664f7f859e);
    //
    //    }

    //=================== view ===================
    function getCakePoolRewardByCakePoolAddrAndUserAddr(address _account) public view returns (uint256, uint256, uint256){
        uint256 cakePoolBalanceOf = cakePool.balanceOf();
        uint256 cakePoolTotalShares = cakePool.totalShares();
        if (cakePoolTotalShares == 0) return (0, 0, 0);
        (
        uint256 shares,,
        uint256 cakeAtLastUserAction,,,
        uint256 lockEndTime,
        uint256 userBoostedShare,
        bool lock,
        uint256 lockedAmount
        ) = cakePool.userInfo(_account);
        if (lock) {
            return
            (
            lockedAmount,
            (cakePoolBalanceOf * shares / cakePoolTotalShares) - userBoostedShare - lockedAmount,
            lockEndTime
            );
        } else {
            return
            (
            cakeAtLastUserAction,
            (cakePoolBalanceOf * shares / cakePoolTotalShares) - cakeAtLastUserAction,
            lockEndTime
            );
        }
    }

    //    function getBalanceOfByAddress() public view returns (data[6] memory addressBalanceOf_) {
    //        for (uint256 i = 0; i < 6; ++i) {
    //            uint256 value = 0;
    //            uint256 endTime = 0;
    //            address[] memory _addrs = spanCorrespondingContract[lengths[i]];
    //            for (uint256 j = 0; j < spanCorrespondingContract.length; ++j) {
    //                (uint256 lockedAmount, uint256 rewardAmount, uint256 lockEndTime) = getCakePoolRewardByCakePoolAddrAndUserAddr(spanCorrespondingContract[j]);
    //                value += (lockedAmount + rewardAmount);
    //                endTime = lockEndTime;
    //            }
    //            addressBalanceOf_[i].rewardAndLockAmount += value;
    //            addressBalanceOf_[i].lockEndTime = endTime;
    //        }
    //    }

    event CatchEvent(string);


    //============================================

    function userPledge(bool _whitelist, uint256 _amount) external {
        require(locking || _whitelist, "TC:E0");

        try cakePool.deposit(_amount, lockTime){
            //emit CatchEvent("chenggong");
        } catch Error(string memory shibai_){
            // call不成功的情况下
            emit CatchEvent(shibai_);
        }
    }

    function setLock() external {
        locking = !locking;
        // todo 锁定事件
    }

}

