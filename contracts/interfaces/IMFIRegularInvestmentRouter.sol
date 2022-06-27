pragma solidity ^0.8.0;

/**
* @notice MFIRegularInvestmentFactory contract interfaces
*/
interface IMFIRegularInvestmentFactory {

    /**
    * @dev Get the current contract version number
    * @return contract version number
    */
    function contractVersion() external view returns (uint256);

    function getPoolPledgeRatio(uint256 _amount) external view returns (uint256[6] memory newAmount_);

    function timeSpanPid(uint256 _timeSpan) external view returns (uint256 timeSpan_);

    function createPair(uint256 _index) external;

    function lockSpan(uint256 _timeSpan) external view returns (uint256 lockSpan_);

    function getLockSpanData(uint256 _index) external view returns (uint256 newData_);

    function allTradingContract(uint256 _index) external view returns (address[] memory existingContract_);
}

interface ITradingContract {
    function startTime() external view returns (uint256 startTime_);
}