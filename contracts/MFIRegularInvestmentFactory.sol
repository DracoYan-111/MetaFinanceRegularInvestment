//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./utils/MfiAccessControl.sol";
import "./interfaces/IMFIRegularInvestmentFactory.sol";
import "./storages/MFIRegularInvestmentFactoryStorage.sol"; //["10","15","25","20","13","17"]["1","1","5","2","13","4"]

contract MFIRegularInvestmentFactory is MfiAccessControl, ReentrancyGuardUpgradeable, MFIRegularInvestmentFactoryStorage {
    using SafeMath for uint256;

    bytes32 public constant INIT_CODE_PAIR_HASH = keccak256(abi.encodePacked(type(tradingContract).creationCode));

    function initialize(IMFIRegularInvestmentRouter _mfiRegularInvestmentRouter) public initializer {
        proportion = 100;
        __ReentrancyGuard_init();
        mfiRegularInvestmentRouter = _mfiRegularInvestmentRouter;
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

        uint256 _totalNumber = mfiRegularInvestmentRouter.totalNumberPledges();
        uint256 _total = _amount.add(_totalNumber);
        uint256[6] memory _pledgeQuantity = mfiRegularInvestmentRouter.getPledgeQuantity();

        for (uint256 i = 0; i < 6; ++i) {
            if (i != 5) {
                newAmount_[i] =
                _total.mul(timeSpanDepositRatio[timeSpan[i]]).div(proportion) > _pledgeQuantity[i] ?
                _total.mul(timeSpanDepositRatio[timeSpan[i]]).div(proportion).sub(_pledgeQuantity[i]) : 0;
                if (newAmount_[i] == 0)
                    continue;
                if (_amount < newAmount_[i])
                    newAmount_[i] = _amount;
                _internalQuantity += newAmount_[i];
            } else {
                newAmount_[i] = _amount.sub(_internalQuantity).sub(_totalNumber);
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

    /**
    * @dev Query all trading contracts
    * @return allContract_ Array of all trading contracts
    */
    function getAllContract() public view returns (address[] memory allContract_){
        allContract_ = new address[](allContract.length);
        for (uint256 i = 0; i < allContract.length; ++i) {
            allContract_[i] = allContract[i];
        }
    }

    //    /**
    //    * @dev Get rewards in cake pool through user address
    //    * @param _account User address
    //    */
    //    function getRewardByCakePoolAndUserAddress(address _account) public view returns (uint256, uint256, uint256){
    //        uint256 cakePoolBalanceOf = cakePool.balanceOf();
    //        uint256 cakePoolTotalShares = cakePool.totalShares();
    //        if (cakePoolTotalShares == 0) return (0, 0, 0);
    //        (
    //        uint256 shares,,
    //        uint256 cakeAtLastUserAction,,,
    //        uint256 lockEndTime,
    //        uint256 userBoostedShare,
    //        bool lock,
    //        uint256 lockedAmount
    //        ) = cakePool.userInfo(_account);
    //        if (lock) {
    //            return
    //            (lockedAmount,
    //            (cakePoolBalanceOf * (shares) / (cakePoolTotalShares)) - (userBoostedShare) - (lockedAmount),
    //            lockEndTime);
    //        } else {
    //            return
    //            (cakeAtLastUserAction,
    //            (cakePoolBalanceOf.mul(shares).div(cakePoolTotalShares)).sub(cakeAtLastUserAction),
    //            lockEndTime);
    //        }
    //    }

    /**
    * @dev Get rewards in cake pool through user address
    * @param _account User address
    */
    function getRewardByCakePoolAndUserAddressTest(address _account) public view returns (uint256, uint256){
        uint256 cakePoolBalanceOf = cakePool.balanceOf();
        uint256 cakePoolTotalShares = cakePool.totalShares();
        (uint256 shares,,
        uint256 cakeAtLastUserAction,,,
        uint256 lockEndTime,
        uint256 userBoostedShare,
        bool locked,
        uint256 lockedAmount) = cakePool.userInfo(_account);

        //        tokenAmount_ = locked ?
        //        (cakePoolBalanceOf.mul(shares).div(cakePoolTotalShares)).sub(userBoostedShare).sub(lockedAmount) :
        //        (cakePoolBalanceOf.mul(shares).div(cakePoolTotalShares)).sub(cakeAtLastUserAction);
        if (locked) {
            return (
            (cakePoolBalanceOf.mul(shares).div(cakePoolTotalShares)).sub(userBoostedShare).sub(lockedAmount),
            lockEndTime);
        } else {
            return (
            (cakePoolBalanceOf.mul(shares).div(cakePoolTotalShares)).sub(cakeAtLastUserAction),
            lockEndTime);
        }
    }

    /**
    * @dev all select unlock address
    * @return addressTmp_ Array of unlocked addresses
    */
    function allSelectUnlockAddress() public view returns (address[] memory addressTmp_){
        uint256 lens = allContract.length;
        address[] memory addressTmp = new address[](lens);
        uint256 num;
        for (uint256 i = 0; i < lens; ++i) {
            address add_tmp = allContract[i];
            (, uint end_Time) = getRewardByCakePoolAndUserAddressTest(add_tmp);
            if (block.timestamp >= end_Time) {
                addressTmp[i] = add_tmp;
                num ++;
            }
        }
        addressTmp_ = new address[](num);
        for (uint256 i = 0; i < lens; ++i) {
            if (addressTmp[i] != address(0)) {
                addressTmp_[num - 1] = addressTmp[i];
                num--;
            }
        }
    }

    //    /**
    //    * @dev
    //    *
    //    *
    //    *
    //    */
    //    function allSelectUnlockAddressTest() public view returns (address[] memory addressTmp_){
    //        uint256 lens = allContract.length;
    //        address[] memory addressTmp = new address[](lens);
    //        uint256 num;
    //        for (uint256 i = 0; i < lens; ++i) {
    //            address add_tmp = allContract[i];
    //            //(,,uint end_Time) = getCakePoolRewardByCakePoolAddressAndUserAddress(add_tmp);
    //            uint256 end_Time = tradingContract(add_tmp).endTime();
    //            //if (block.timestamp >= end_Time) {
    //            if (end_Time > 0) {
    //                addressTmp[i] = add_tmp;
    //                num ++;
    //            }
    //        }
    //        addressTmp_ = new address[](num);
    //        for (uint256 i = 0; i < lens; ++i) {
    //            if (addressTmp[i] != address(0)) {
    //                addressTmp_[num - 1] = addressTmp[i];
    //                num--;
    //            }
    //        }
    //    }

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

    mapping(address => uint256) public addressSubscript;

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

        addressSubscript[tradingContract_] = _index;
        allTradingContract[_index].push(tradingContract_);
        timeSpanPid[_index]++;
        allContract.push(tradingContract_);
        //}
    }

    /**
    * @dev Initialize the transaction contract
    * @param _index Lock time index
    * @param _tradContractAddress The address of the transaction contract that needs to be initialized
    */
    function initializeTradingContract(uint256[] calldata _index, tradingContract[] calldata _tradContractAddress) public {
        require(_index.length == _tradContractAddress.length, "MFIRI:E2");
        for (uint256 i = 0; i < _index.length; ++i) {
            _tradContractAddress[i].initialize(lockSpan[_index[i]], timeSpan[i], cakePool);
        }
    }

    /**
    * @dev Lock or unlock a transaction contract
    * @param _tradContractAddress Array of transaction contract addresses
    */
    function setLockTradingContract(tradingContract[] memory _tradContractAddress) public {
        for (uint256 i = 0; i < _tradContractAddress.length; ++i) {
            _tradContractAddress[i].setLock();
        }
    }
}


contract tradingContract {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    bool public locking;
    address public factory;
    uint256 public startTime;
    uint256 public lockTime;
    uint256 public endTime;
    uint256 public totalNumberPledges;
    ICakePool public cakePool;
    IERC20 public cakeToken;

    constructor(){
        factory = msg.sender;
    }

    // called once by the factory at time of deployment
    function initialize(
        uint256 _lockTime,
        uint256 _pledgeTime,
        ICakePool _cakePool
    ) external {
        locking = true;
        lockTime = _lockTime;
        startTime = block.timestamp;
        cakePool = _cakePool;
        endTime = startTime + lockTime + _pledgeTime;
    }


    uint256[6]  public lengths = [1 weeks, 2 weeks, 5 weeks, 10 weeks, 26 weeks, 52 weeks];

    mapping(uint256 => address[]) spanCorrespondingContract;//跨度对应合约SpanCorrespondContract

    struct data {
        uint256 rewardAndLockAmount;
        uint256 lockEndTime;
    }

    event CatchEvent(string);


    //============================================

    function userPledge(bool _whitelist, uint256 _amount) external {
        require(locking || _whitelist, "TC:E0");
        uint256 _lockTime = _whitelist ? 0 : endTime - (startTime + lockTime);

        try cakePool.deposit(_amount, _lockTime){
            totalNumberPledges += _amount;
            //emit CatchEvent("chenggong");
        } catch Error(string memory errorState){
            // call不成功的情况下
            emit CatchEvent(errorState);
        }
    }

    function receiveAll() external returns (uint256 numberAwards_, uint256 numberPledges_){
        require(block.timestamp >= endTime, "TC:E1");
        uint256 oldAmount = cakeToken.balanceOf(address(this));
        try cakePool.unlock(address(this)){
            cakePool.withdrawAll();
            uint256 newAmount = cakeToken.balanceOf(address(this));
            numberAwards_ = newAmount - totalNumberPledges - oldAmount;
            numberPledges_ = totalNumberPledges;
            // todo 发送给反向兑换合约
            cakeToken.safeTransfer(msg.sender, numberAwards_);
        }catch Error(string memory errorState){
            // call不成功的情况下
            emit CatchEvent(errorState);
        }
    }

    function setLock() external {
        locking = !locking;
        // todo 锁定事件
    }

}