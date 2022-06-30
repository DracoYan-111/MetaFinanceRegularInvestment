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
        for(uint256 i = 0; i < 6; ++i){
            LastAmount[i] = lockSpanData[i];
        }
        
    }
    
    error PledgeFailed(address userAddress, uint256 amount, string errorState);


    function userPledges(uint256 _amount) external {
        address[6] memory latestAddress = factory.getLatestAddress();
        uint256[6] memory pledgeRatio = factory.getPoolPledgeRatio(_amount);
        for (uint256 i = 0; i < 6; ++i) {
            try ITradingContract(latestAddress[i]).userPledge(false, pledgeRatio[i]) {
            } catch Error(string memory errorState){
                revert PledgeFailed(_msgSender(), _amount, errorState);
            }
        }
        mcake.mint(_msgSender(), _amount);

    }
}