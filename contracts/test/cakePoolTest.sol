pragma solidity ^0.8.0;

contract CakePool {
    struct UserInfo {
        uint256 userAmount;
        uint256 userDate;
    }

    mapping(address => UserInfo) public userDate;

    /**
     * @dev Deposit funds into the Cake Pool.
     * @param _amount: number of tokens to deposit (in CAKE)
     * @param _lockDuration: Token lock duration (is seconds)
     */
    function deposit(uint256 _amount, uint256 _lockDuration) external {
        userDate[msg.sender].userDate = _lockDuration;
        userDate[msg.sender].userAmount += _amount;
    }

    /**
     * @dev Withdraw funds from the Cake Pool.
     * @param _amount: Number of amount to withdraw
     */
    function withdrawByAmount(uint256 _amount) external {
        userDate[msg.sender].userAmount -= _amount;
    }

    /**
     * @dev Withdraw funds from the Cake Pool.
     * @param _shares: Number of shares to withdraw
     */
    function withdraw(uint256 _shares) external {
        userDate[msg.sender].userAmount -= _amount;
    }
    /**
     * @dev Withdraw all funds for a user
     */
    function withdrawAll() external {
        userDate[msg.sender].userAmount = 0;
    }

    /**
     * @dev Calculate Performance fee.
     * @param _user: User address
     * @return Returns Performance fee.
     */
    function calculatePerformanceFee(address _user) external view returns (uint256){
        return 3 ether;
    }

    /**
     * @dev Calculate overdue fee.
     * @param _user: User address
     * @return Returns Overdue fee.
     */
    function calculateOverdueFee(address _user) external view returns (uint256){
        return 0;
    }

    /**
     * @dev Calculate withdraw fee.
     * @param _user: User address
     * @param _shares: Number of shares to withdraw
     * @return Returns Withdraw fee.
     */
    function calculateWithdrawFee(address _user, uint256 _shares) external view returns (uint256){
        return 0;
    }

    /**
     * @dev Calculates the total pending rewards that can be harvested
     * @return Returns total pending cake rewards
     */
    function calculateTotalPendingCakeRewards() external view returns (uint256){
        return 30 ether;
    }

    /**
     * @dev Current pool available balance
     * @dev The contract puts 100% of the tokens to work.
     */
    function available() external view returns (uint256){
        return 30 ether;
    }

}
