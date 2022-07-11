//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./utils/MfiAccessControl.sol";
import "./interfaces/IMFIRegularInvestmentFactory.sol";
import "./storages/MFIRegularInvestmentFactoryStorage.sol"; //["10","15","25","20","13","17"]["1","1","5","2","13","4"]

contract MFIRegularInvestmentFactory is MfiAccessControl, ReentrancyGuardUpgradeable, MFIRegularInvestmentFactoryStorage {
    using SafeMath for uint256;
    using SafeERC20 for IERC20Metadata;

    function initialize(IMFIRegularInvestmentRouter _mfiRegularInvestmentRouter) public {
        proportion = 100;
        mfiRegularInvestmentRouter = _mfiRegularInvestmentRouter;
    }
    //=================== VIEW ===================

    /**
    * @dev Query the number of trading contracts used for the lock time
    * @return newData_ Number of contracts used
    */
    function getLockSpanData() public view returns (uint256[6] memory newData_){
        require(turnOn, "MFIRI:E2");
        for (uint256 i = 0; i < 6; ++i)
            newData_[i] = (timeSpan[i].div(1 weeks)).div(lockSpan[i]).add(1);
    }

    /**
    * @dev Get the mining pool pledge ratio(6 == timeSpan.length)
    * @param _amount Number of transactions
    * @return newAmount_ Real transaction ratio
    */
    function getPoolPledgeRatio(uint256 _amount) external view returns (uint256[6] memory newAmount_){
        require(turnOn, "MFIRI:E2");
        uint256 internalQuantity;

        uint256 totalNumbers = mfiRegularInvestmentRouter.totalNumberPledges();
        uint256 totals = _amount.add(totalNumbers);
        uint256[6] memory pledgeQuantity = mfiRegularInvestmentRouter.getPledgeQuantity();
        uint256[6] memory spanDepositRatio = timeSpanDepositRatio;
        for (uint256 i = 0; i < 6; ++i) {
            if (i != 5) {
                newAmount_[i] =
                totals.mul(spanDepositRatio[i]).div(proportion) > pledgeQuantity[i] ?
                totals.mul(spanDepositRatio[i]).div(proportion).sub(pledgeQuantity[i]) : 0;
                if (newAmount_[i] == 0)
                    continue;
                if (_amount < newAmount_[i])
                    newAmount_[i] = _amount;
                internalQuantity += newAmount_[i];
            } else {
                newAmount_[i] = _amount.sub(internalQuantity).sub(totalNumbers);
            }
        }
    }

    /**
    * @dev Return the latest mining pool address
    * @return latestAddress_ Latest address array
    */
    function getLatestAddress() external view returns (address[6] memory latestAddress_){
        for (uint256 i = 0; i < 6; ++i) {
            uint256 length = indexTradingContract[i].length;
            for (uint256 j = 0; j < length; ++j) {
                if (tradingContract(indexTradingContract[i][j]).locking()) {
                    latestAddress_[i] = indexTradingContract[i][j];
                    break;
                }
            }
        }
    }

    /**
    * @dev Get the number of suspended pledges
    * @return lockSpan_ Stop staking time
    */
    function getLockSpan() external view returns (uint256[6] memory lockSpan_){
        for (uint256 i = 0; i < 6; ++i)
            lockSpan_[i] = lockSpan[i].mul(1 weeks);
    }

    /**
    * @dev Query all trading contracts
    * @return allContract_ Array of all trading contracts
    */
    function getAllContract() public view returns (address[] memory allContract_){
        allContract_ = allContract;
    }

    /**
    * @dev Get rewards in cake pool through user address
    * @param _account User address
    */
    function getRewardByCakePoolAndUserAddressTest(address _account) public view returns (uint256 numberAwards_, uint256 lockEndTime_){
        uint256 cakePoolBalanceOf = cakePool.balanceOf();
        uint256 cakePoolTotalShares = cakePool.totalShares();
        (uint256 shares,,
        uint256 cakeAtLastUserAction,,,
        uint256 lockEndTime,
        uint256 userBoostedShare,
        bool locked,
        uint256 lockedAmount) = cakePool.userInfo(_account);

        numberAwards_ = locked ?
        (cakePoolBalanceOf.mul(shares).div(cakePoolTotalShares)).sub(userBoostedShare).sub(lockedAmount) :
        (cakePoolBalanceOf.mul(shares).div(cakePoolTotalShares)).sub(cakeAtLastUserAction);
        lockEndTime_ = lockEndTime;
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
            address addTmp = allContract[i];
            (, uint endTime) = getRewardByCakePoolAndUserAddressTest(addTmp);
            if (block.timestamp >= endTime) {
                addressTmp[i] = addTmp;
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

    /**
    * @dev Get the contract that has expired after the last update
    * @return expiredAddress_ contract that has expired
    */
    function getExpiredAddress() public view returns (tradingContract[] memory expiredAddress_){
        uint256 lens = expiredAddress.length;
        tradingContract[] memory addressTmp = new tradingContract[](lens);
        uint256 num;
        for (uint256 i = 0; i < lens; ++i) {
            uint256 endTime = expiredAddress[i].endTime();
            if (endTime > 0 && endTime < block.timestamp) {
                addressTmp[i] = expiredAddress[i];
                num ++;
            }
        }
        expiredAddress_ = new tradingContract[](num);
        for (uint256 i = 0; i < lens; ++i) {
            if (addressTmp[i] != tradingContract(address(0))) {
                expiredAddress_[num - 1] = addressTmp[i];
                num--;
            }
        }
    }
    //============================================


    function setMFIRegularInvestmentRouter(IMFIRegularInvestmentRouter _mfiRegularInvestmentRouter) public {
        mfiRegularInvestmentRouter = _mfiRegularInvestmentRouter;
    }

    /**
    * @dev Set the pledge ratio and lock-up period
    * @param _timeSpanDepositRatio Pledge ratio
    * @param _lockSpan Unlock time
    */
    function setTimeSpanDepositRatio(uint256[6] calldata _timeSpanDepositRatio, uint256[6] calldata _lockSpan) public {
        require(_timeSpanDepositRatio.length == 6 && _lockSpan.length == 6, "MFIRI:E0");
        turnOn = true;
        lockSpan = _lockSpan;
        timeSpanDepositRatio = _timeSpanDepositRatio;
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
        for (uint256 i = 0; i < _amount; ++i)
            createPair(_index);
    }

    //    /**
    //    * @dev Create tradingContract
    //    * @param _index Lock time array subscript
    //    */
    //    function createPair(uint256 _index) public {
    //        bytes memory bytecode = type(tradingContract).creationCode;
    //        uint256 pid = timeSpanPid[_index];
    //        bytes32 salt = keccak256(abi.encodePacked(contractVersion, pid));
    //        address tradingContracts;
    //
    //        assembly {
    //            tradingContracts := create2(0, add(bytecode, 32), mload(bytecode), salt)
    //        }
    //
    //        timeSpanPid[_index]++;
    //        allContract.push(tradingContracts);
    //        addressSubscript[tradingContracts] = _index;
    //        indexTradingContract[_index].push(tradingContracts);
    //    }


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
        address tradingContracts;

        assembly {
            tradingContracts := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        addressSubscript[tradingContracts] = _index;
        indexTradingContract[_index].push(tradingContracts);
        timeSpanPid[_index]++;
        allContract.push(tradingContracts);
        //}
    }

    tradingContract[] public  expiredAddress;

    /**
    * @dev Initialize the transaction contract
    * @param _index Lock time index
    * @param _tradContractAddress The address of the transaction contract that needs to be initialized
    */
    function initializeTradingContract(uint256[] calldata _index, tradingContract[] calldata _tradContractAddress) public {
        require(_index.length == _tradContractAddress.length, "MFIRI:E2");
        setLockTradingContract(getExpiredAddress());
        for (uint256 i = 0; i < _index.length; ++i)
            _tradContractAddress[i].initialize(cakePool);
        expiredAddress = _tradContractAddress;
    }

    /**
        * @dev Lock or unlock a transaction contract
        * @param _tradContractAddress Array of transaction contract addresses
        */
    function setLockTradingContract(tradingContract[] memory _tradContractAddress) public {
        for (uint256 i = 0; i < _tradContractAddress.length; ++i)
            _tradContractAddress[i].setLock();
    }
}

contract tradingContract {
    using SafeMath for uint256;
    using SafeERC20 for IERC20Metadata;

    bool public locking;
    uint256 public endTime;
    uint256 public lockTime;
    uint256 public startTime;
    uint256 public totalNumberPledges;

    ICakePool public cakePool;
    IERC20Metadata public cakeToken;

    error PledgeFailed(string errorState);

    function initialize(ICakePool _cakePool) external {
        locking = !locking;
        cakePool = _cakePool;
    }

    event UseContractEvent(uint256 startTime, uint256 endTime);

    function useContract(uint256 _lockTime, uint256 _pledgeTime) public {
        startTime = block.timestamp;
        lockTime = block.timestamp.add(_lockTime);
        endTime = startTime.add(_lockTime).add(_pledgeTime);

        emit UseContractEvent(startTime, endTime);
    }

    function setLock() external {
        locking = !locking;
    }

    //============================================

    event UserPledgeEvent(uint256 amount);

    function userPledge(bool _whitelist, uint256 _amount) external {
        require(locking || _whitelist, "TC:E0");
        uint256 _lockTime = _whitelist ? 0 : endTime.sub(startTime.add(lockTime));

        try cakePool.deposit(_amount, _lockTime){
            totalNumberPledges = totalNumberPledges.add(_amount);

            emit UserPledgeEvent(_amount);
        } catch Error(string memory errorState){
            revert PledgeFailed(errorState);
        }
    }

    event ReceiveAllEvent(uint256 amount);

    function receiveAll() external returns (uint256 numberAwards_, uint256 numberPledges_){
        require(block.timestamp >= endTime, "TC:E1");
        uint256 oldAmount = cakeToken.balanceOf(address(this));
        try cakePool.unlock(address(this)){
            cakePool.withdrawAll();
            locking = !locking;
            uint256 newAmount = cakeToken.balanceOf(address(this));
            numberAwards_ = newAmount.sub(totalNumberPledges.add(oldAmount));
            numberPledges_ = totalNumberPledges;
            cakeToken.safeTransfer(msg.sender, numberAwards_);

            emit ReceiveAllEvent(numberPledges_);
        }catch Error(string memory errorState){
            revert PledgeFailed(errorState);
        }
    }

}