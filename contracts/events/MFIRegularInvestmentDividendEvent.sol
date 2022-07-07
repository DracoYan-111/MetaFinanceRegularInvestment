//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

contract MFIRegularInvestmentDividendEvent {
    /**
    * @dev Reward added event
    * @param reward Number of awards
    */
    event RewardAdded(uint256 reward);

    /**
    * @dev User staked event
    * @param user User address
    * @param amount User staked amount
    */
    event Staked(address indexed user, uint256 amount);

    /**
    * @dev User withdrawn event
    * @param user User address
    * @param amount User withdrawn amount
    */
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

}
