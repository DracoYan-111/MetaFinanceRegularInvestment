//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./storages/MFIRegularInvestmentRouterStorage.sol"; //["1","1","1","1","1","1"]["1","1","5","2","13","4"]
import "./utils/MfiAccessControl.sol";

contract MFIRegularInvestmentRouter is MfiAccessControl, MFIRegularInvestmentRouterStorage {
    using SafeMath for uint256;

    function initialize(IMFIRegularInvestmentFactory _factoryAddress, IMCake _mcake) public {
        mcake = _mcake;
        factory = _factoryAddress;
        uint256[6] memory lockSpanData = factory.getLockSpanData();
        for (uint256 i = 0; i < 6; ++i) {
            LastAmount[i] = lockSpanData[i];
        }

    }

    /**
    * @dev Get the pledge amount for each lock length
    * @param pledgeQuantity_ Pledge quantity
    */
    function getPledgeQuantity() external view returns (uint256[6] memory pledgeQuantity_){
        for (uint256 i = 0; i < 6; ++i) {
            pledgeQuantity_[i] = pledgeQuantity[i];
        }
    }

    error PledgeFailed(address userAddress, uint256 amount, string errorState);

    /**
    * @dev User pledges
    * @param _amount Number of pledged tokens
    */
    function userPledges(uint256 _amount) external {
        address[6] memory latestAddress = factory.getLatestAddress();
        uint256[6] memory pledgeRatio = factory.getPoolPledgeRatio(_amount);
        for (uint256 i = 0; i < 6; ++i) {
            pledgeQuantity[i] += pledgeRatio[i];
            try ITradingContract(latestAddress[i]).userPledge(false, pledgeRatio[i]) {
            } catch Error(string memory errorState){
                revert PledgeFailed(_msgSender(), _amount, errorState);
            }
        }
        totalNumberPledges += _amount;
        mcake.mint(_msgSender(), _amount);
    }

    /**
    * @dev Get unlocked trading contract rewards
    */
    function getRewarded(/*ITradingContract[] memory _tradingContractArray*/) external {
        address[] memory _tradingContractArray = factory.allSelectUnlockAddress();
        for (uint256 i = 0; i < _tradingContractArray.length; ++i) {
            try ITradingContract(_tradingContractArray[i]).receiveAll() returns (uint256 , uint256 numberPledges_) {
                pledgeQuantity[factory.addressSubscript(_tradingContractArray[i])] -= numberPledges_;
            } catch Error(string memory errorState){
                revert PledgeFailed(_msgSender(), 0, errorState);
            }
        }
    }

    /**
    * @dev User reverse conversion
    * @param _amount Reverse conversion amount
    */
    function reverseConversion(uint256 _amount) external {
        mcake.burn(_msgSender(), _amount);
        exchangeQuantity[_msgSender()] = _amount;
    }


}