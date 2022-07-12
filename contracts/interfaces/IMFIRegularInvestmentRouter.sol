//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

/**
* @notice MFIRegularInvestmentDividend contract interfaces
*/
interface IMFIRegularInvestmentDividend {
    function notifyRewardAmount(uint256 reward, uint256 timestamp) external;
}

/**
* @notice MFIRegularInvestmentFactory contract interfaces
*/
interface IMFIRegularInvestmentFactory {
    function getLockSpan() external view returns (uint256[6] memory lockSpan_);

    function getLatestAddress() external view returns (address[6] memory latestAddress_);

    function getPoolPledgeRatio(uint256 _amount) external view returns (uint256[6] memory poolPledgeRatio_);

    function allSelectUnlockAddress() external view returns (address[] memory addressTmp_);

    function addressSubscript(address _contractAddress) external view returns (uint256 index_);

}

/**
* @notice TradingContract contract interfaces
*/
interface ITradingContract {
    function endTime() external view returns (uint256 endTime_);

    function locking() external view returns (bool locking_);

    function useContract(uint256 _lockTime, uint256 _pledgeTime) external;

    function userPledge(bool _whitelist, uint256 _amount) external;

    function receiveAll() external returns (uint256 numberAwards_, uint256 numberPledges_);

}

/**
* @notice MCake contract interfaces
*/
interface IMCake {
    function mint(address _userAddress, uint256 _amount) external;

    function burn(address _userAddress, uint256 _amount) external;

}
