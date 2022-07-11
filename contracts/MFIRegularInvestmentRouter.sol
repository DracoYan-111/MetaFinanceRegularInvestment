//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./storages/MFIRegularInvestmentRouterStorage.sol"; //["1","1","1","1","1","1"]["1","1","5","2","13","4"]
import "./utils/MfiAccessControl.sol";

contract MFIRegularInvestmentRouter is MfiAccessControl, MFIRegularInvestmentRouterStorage {
    using SafeMath for uint256;

    function initialize(IMFIRegularInvestmentFactory _mfiRegularInvestmentFactory, IMCake _mcake) public {
        mcake = _mcake;
        factory = _mfiRegularInvestmentFactory;
    }

    /**
    * @dev Get the pledge amount for each lock length
    * @param pledgeQuantity_ Pledge quantity
    */
    function getPledgeQuantity() external view returns (uint256[6] memory pledgeQuantity_){
        for (uint256 i = 0; i < 6; ++i)
            pledgeQuantity_[i] = pledgeQuantity[i];
    }

    error PledgeFailed(string errorState);

    /**
    * @dev User pledges
    * @param _amount Number of pledged tokens
    */
    function userPledges(uint256 _amount) external {
        address[6] memory latestAddress = factory.getLatestAddress();
        uint256[6] memory pledgeRatio = factory.getPoolPledgeRatio(_amount);
        uint256[6] memory lockSpan = factory.getLockSpan();
        for (uint256 i = 0; i < 6; ++i) {
            if (block.timestamp > ITradingContract(latestAddress[i]).endTime()) {
                ITradingContract(latestAddress[i]).useContract(lockSpan[i], timeSpan[i]);
            }
            try ITradingContract(latestAddress[i]).userPledge(false, pledgeRatio[i]) {
                pledgeQuantity[i] += pledgeRatio[i];
            } catch Error(string memory errorState){
                revert PledgeFailed(errorState);
            }
        }
        totalNumberPledges += _amount;
        mcake.mint(msg.sender, _amount);
    }

    /**
    * @dev Get rewarded
    */
    function getRewarded() external {
        address[] memory allSelectUnlock = factory.allSelectUnlockAddress();
        for (uint256 i = 0; i < allSelectUnlock.length; ++i) {
            try  ITradingContract(allSelectUnlock[i]).receiveAll() returns (uint256 numberAwards_, uint256 numberPledges_){
                totalNumberPledges -= numberPledges_;
                pledgeQuantity[factory.addressSubscript(allSelectUnlock[i])] -= numberPledges_;
            }catch Error(string memory errorState){
                revert PledgeFailed(errorState);
            }
        }
    }
}