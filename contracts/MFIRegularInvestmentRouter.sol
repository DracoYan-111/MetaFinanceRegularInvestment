//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./utils/MfiAccessControl.sol";
import "./interfaces/IMFIRegularInvestmentRouter.sol";
import "./storages/MFIRegularInvestmentRouterStorage.sol"; //["1","1","1","1","1","1"]["1","1","5","2","13","4"]


contract MFIRegularInvestmentRouter is MfiAccessControl, MFIRegularInvestmentRouterStorage {
    using SafeMath for uint256;
    error PledgeFailed(string errorState);

    function initialize(IMFIRegularInvestmentFactory _mfiRegularInvestmentFactory, IMCake _mcake) public {
        proportion = 100;
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


    /**
    * @dev Set minting ratio and payment address
    * @param _newShareRatio Array of new casting scale
    * @param _newPaymentAddress Array of new payment addresses
    */
    function setShareRatio(uint256[3] memory _newShareRatio, address[3] memory _newPaymentAddress) external {
        shareRatio = _newShareRatio;
        paymentAddress = _newPaymentAddress;
    }

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
        uint256 totalAwards;
        for (uint256 i = 0; i < allSelectUnlock.length; ++i) {
            try ITradingContract(allSelectUnlock[i]).receiveAll() returns (uint256 numberAwards_, uint256 numberPledges_){
                totalAwards += numberAwards_;
                totalNumberPledges -= numberPledges_;
                pledgeQuantity[factory.addressSubscript(allSelectUnlock[i])] -= numberPledges_;
            }catch Error(string memory errorState){
                revert PledgeFailed(errorState);
            }
        }
        uint256[3] memory mintRatio = getMintRatio(totalAwards);
        for (uint256 i = 0; i < 3; ++i) {
            address paymentPerAddress = paymentAddress[i];
            uint256 mintPerRatio = mintRatio[i];
            mcake.mint(paymentPerAddress, mintPerRatio);
            if (i == 0)
                IMFIRegularInvestmentDividend(paymentPerAddress).notifyRewardAmount(mintPerRatio, 1);
            if (i == 1)
                IMFIRegularInvestmentDividend(paymentPerAddress).notifyRewardAmount(mintPerRatio, 1);
        }
    }

    /**
    * @dev Get casting scale
    * @param _numberAwards Number of awards
    * @return mintRatio_ Cast quantity array
    */
    function getMintRatio(uint256 _numberAwards) public view returns (uint256[3] memory mintRatio_){
        uint256 count;
        for (uint256 i = 0; i < 3; ++i) {
            if (i != 2) {
                mintRatio_[i] = _numberAwards * shareRatio[i] / proportion;
                count += mintRatio_[i];
            } else {
                mintRatio_[i] = _numberAwards - count;
            }
        }
    }
}