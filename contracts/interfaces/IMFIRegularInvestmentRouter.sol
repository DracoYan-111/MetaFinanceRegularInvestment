//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
/**
* @notice MFIRegularInvestmentFactory contract interfaces
*/
interface IMFIRegularInvestmentFactory {

    //=================== ROUTER ===================

    function createPair(uint256 _index) external;

    //=================== VIEW ===================
    function turnOn() external view returns (bool);

    /**
    * @dev Get the current contract version number
    * @return contract version number
    */
    function contractVersion() external view returns (uint256);

    function lockSpan(uint256 _timeSpan) external view returns (uint256 lockSpan_);

    function timeSpanPid(uint256 _timeSpan) external view returns (uint256 timeSpan_);

    function timeSpanDepositRatio(uint256 _timeSpan) external view returns (uint256 ratio_);

    function allTradingContract(uint256 _index) external view returns (address[] memory existingContract_);

    function getPoolPledgeRatio(uint256 _amount) external view returns (uint256[6] memory newAmount_);

    function allSelectUnlockAddress() external view returns (address[] memory addressTmp_);

    function getLockSpanData() external view returns (uint256[6] memory newData_);

    function getLatestAddress() external view returns (address[6] memory latestAddress_);

    function addressSubscript(address _tradingContract) external view returns (uint256 index_);

}

interface ITradingContract {
    function startTime() external view returns (uint256 startTime_);

    // called once by the factory at time of deployment
    function initialize(uint256 _pid, uint256 _lockTime, uint256 _startTime) external;

    function userPledge(bool _whitelist, uint256 _amount) external;

    function receiveAll() external returns (uint256 numberAwards_, uint256 numberPledges_);

}

interface IMCake {
    function mint(address _userAddress, uint256 _amount) external;

    function burn(address _userAddress, uint256 _amount) external;

}
