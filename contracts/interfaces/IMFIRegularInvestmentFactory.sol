//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

/**
* @notice MetaFinanceTriggerPool contract interfaces
*/
interface IMetaFinanceTriggerPool {
    /**
    * @dev User pledge cake
    * @param amount_ User pledge amount
    */
    function userDeposit(uint256 amount_) external;

    /**
    * @dev User releases cake
    * @param amount_ User withdraw amount
    */
    function userWithdraw(uint256 amount_) external;

    /**
    * @dev Query the user's current principal amount
    * @param account_ Account address
    * @return User principal plus all reward
    */
    function rewardBalanceOf(address account_) external view returns (uint256);

    /**
    * @dev Query the user's pledge amount
    * @param account_ Account address
    * @return User principal
    */
    function userPledgeAmount(address account_) external view returns (uint256);
}

/**
* @notice CakePool contract interfaces
*/
interface ICakePool {
    /**
     * @dev Deposit funds into the Cake Pool.
     * @param _amount: number of tokens to deposit (in CAKE)
     * @param _lockDuration: Token lock duration (is seconds)
     */
    function deposit(uint256 _amount, uint256 _lockDuration) external;

    /**
     * @dev Withdraw funds from the Cake Pool.
     * @param _amount: Number of amount to withdraw
     */
    function withdrawByAmount(uint256 _amount) external;

    /**
     * @dev Withdraw funds from the Cake Pool.
     * @param _shares: Number of shares to withdraw
     */
    function withdraw(uint256 _shares) external;

    /**
     * @dev Withdraw all funds for a user
     */
    function withdrawAll() external;

    /**
     * @dev Calculate Performance fee.
     * @param _user: User address
     * @return Returns Performance fee.
     */
    function calculatePerformanceFee(address _user) external view returns (uint256);

    /**
     * @dev Calculate overdue fee.
     * @param _user: User address
     * @return Returns Overdue fee.
     */
    function calculateOverdueFee(address _user) external view returns (uint256);

    /**
     * @dev Calculate withdraw fee.
     * @param _user: User address
     * @param _shares: Number of shares to withdraw
     * @return Returns Withdraw fee.
     */
    function calculateWithdrawFee(address _user, uint256 _shares) external view returns (uint256);

    /**
     * @dev Calculates the total pending rewards that can be harvested
     * @return Returns total pending cake rewards
     */
    function calculateTotalPendingCakeRewards() external view returns (uint256);

    /**
     * @dev Current pool available balance
     * @dev The contract puts 100% of the tokens to work.
     */
    function available() external view returns (uint256);

    /**
     * @dev Calculates the total underlying tokens
     * @dev It includes tokens held by the contract and the boost debt amount.
     */
    function balanceOf() external view returns (uint256);

    /**
     * @dev total proportion
     */
    function totalShares() external view returns (uint256);

    /**
     * @dev User Info
     */
    function userInfo(address _account) external view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, bool, uint256);

    /**
     * @dev Unlock user cake funds.
     * @dev Only possible when contract not paused.
     * @param _user: User address
     */
    function unlock(address _user) external;
}
