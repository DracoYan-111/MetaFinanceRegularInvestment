//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

/**
* @notice CakePool contract interfaces
*/
interface ICakePool {
    function balanceOf() external view returns (uint256);

    function totalShares() external view returns (uint256);

    function userInfo(address _account) external view returns (
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        bool,
        uint256);

    function deposit(uint256 _amount, uint256 _lockTime) external;

    function unlock(address _contractAddress) external;

    function withdrawAll() external;
}

/**
* @notice MetaFinanceTriggerPool contract interfaces
*/
interface IMetaFinanceTriggerPool {


}

/**
* @notice MFIRegularInvestmentRouter contract interfaces
*/
interface IMFIRegularInvestmentRouter {
    function totalNumberPledges() external view returns (uint256);

    function getPledgeQuantity() external view returns (uint256[6] memory);
}