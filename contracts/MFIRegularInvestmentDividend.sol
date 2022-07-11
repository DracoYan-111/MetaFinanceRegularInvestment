//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./utils/MfiAccessControl.sol";
import "./events/MFIRegularInvestmentDividendEvent.sol";
import "./storages/MFIRegularInvestmentDividendStorage.sol";

/// @title MFIRegularInvestment dividend contract
/// @author Long
/// @notice This contract is only for cake dividend operation
contract MFIRegularInvestmentDividend is MfiAccessControl, ReentrancyGuardUpgradeable, MFIRegularInvestmentDividendEvent, MFIRegularInvestmentDividendStorage {
    using SafeMath for uint256;
    using SafeERC20 for IERC20Metadata;

    /* ========== STATE VARIABLES ========== */
    function initialize() public initializer {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        __ReentrancyGuard_init();
    }
    /* ========== VIEWS ========== */

    /**
    * @dev Determine if the end time is reached
    * @return The current time and the end time are smaller
    */
    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    /*
    * @dev Amount of rewards earned per staked token
    * @return Number of awards
    */
    function rewardPerToken() public view returns (uint256) {
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return
        rewardPerTokenStored.add(
            lastTimeRewardApplicable().sub(lastUpdateTime).mul(rewardRate).mul(1e18).div(_totalSupply)
        );
    }

    /**
    * @dev Query the number of rewards a user has received
    * @param account User address
    * @return The number of rewards the user has earned
    */
    function earned(address account) public view returns (uint256) {
        return _balances[account].mul(rewardPerToken().sub(userRewardPerTokenPaid[account])) .div(1e18).add(rewards[account]);
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    /**
    * @dev User pledges tokens
    * @param amount User pledge amount
    */
    function stake(uint256 amount) external nonReentrant updateReward(_msgSender()) {
        require(amount > 0 && address(stakingToken) != address(0), "Cannot stake 0");
        require(!blacklist[_msgSender()], "is blacklist");
        _totalSupply = _totalSupply.add(amount);
        _balances[_msgSender()] = _balances[_msgSender()].add(amount);
        stakingToken.safeTransferFrom(_msgSender(), address(this), amount);
        emit Staked(_msgSender(), amount);
    }

    /**
    * @dev User redeems principal
    * @param amount The amount of principal redeemed by the user
    */
    function withdraw(uint256 amount) public nonReentrant updateReward(_msgSender()) {
        require(amount > 0, "Cannot withdraw 0");
        require(!blacklist[_msgSender()], "is blacklist");
        _totalSupply = _totalSupply.sub(amount);
        _balances[_msgSender()] = _balances[_msgSender()].sub(amount);
        stakingToken.safeTransfer(_msgSender(), amount);
        emit Withdrawn(_msgSender(), amount);
    }

    /**
    * @dev Users receive rewards
    */
    function getReward() public nonReentrant updateReward(_msgSender()) {
        require(!blacklist[_msgSender()], "is blacklist");
        uint256 reward = rewards[_msgSender()];
        if (reward > 0) {
            rewards[_msgSender()] = 0;
            rewardsToken.safeTransfer(_msgSender(), reward);
            emit RewardPaid(_msgSender(), reward);
        }
    }

    /**
    * @dev User logout(withdraw and getReward)
    */
    function exit() external {
        withdraw(_balances[_msgSender()]);
        getReward();
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    /**
    * @dev Set user  blacklist
    * @param userAddrs User address array
    * @param condition User status
    *         true:add to blacklist
    *         false:Cancel from blacklist
    */
    function setBlacklist(address[] calldata userAddrs, bool condition) public onlyRole(PROJECT_ADMINISTRATOR) {
        for (uint256 i; i < userAddrs.length; i++) {
            blacklist[userAddrs[i]] = condition;
        }
    }

    /**
    * @dev Set the number of rewards per second
    * @param reward New number of rewards per second
    * @param timestamp New reward Duration
    */
    function notifyRewardAmount(uint256 reward, uint256 timestamp) external updateReward(address(0)) onlyRole(PROJECT_ADMINISTRATOR) {
        rewardRate = reward;

        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(timestamp);
        emit RewardAdded(reward);
    }

    /**
    * @dev Set the token address(token contract use once!!!)
    * @param _rewardsToken New Reward Token Address
    * @param _stakingToken New pledge token address
    */
    function setRewardsToken(IERC20Metadata _rewardsToken, IERC20Metadata _stakingToken) external onlyRole(PROJECT_ADMINISTRATOR) {
        rewardsToken = _rewardsToken;
        stakingToken = _stakingToken;
    }

    function claimTokens(
        address tokenAddress,
        address to,
        uint256 amount
    ) public onlyRole(MONEY_ADMINISTRATOR) {
        if (amount > 0) {
            if (tokenAddress == address(0)) {
                payable(to).transfer(amount);
            } else {
                IERC20Metadata(tokenAddress).safeTransfer(to, amount);
            }
        }
    }

    /* ========== MODIFIERS ========== */

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }
}