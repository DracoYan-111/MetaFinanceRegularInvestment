//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

contract MFIRegularInvestmentDividendStorage {
    /// @dev tokens address
    IERC20Metadata public rewardsToken;
    IERC20Metadata public stakingToken;

    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    mapping(address => bool) public blacklist;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    uint256 public _totalSupply;
    mapping(address => uint256) public _balances;

}
