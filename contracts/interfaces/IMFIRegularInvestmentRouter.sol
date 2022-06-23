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

    function getLockSpanData() external view returns (uint256[] memory);

}