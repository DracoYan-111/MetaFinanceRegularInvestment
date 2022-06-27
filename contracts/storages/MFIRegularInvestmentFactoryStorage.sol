//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "../interfaces/IMFIRegularInvestmentFactory.sol";

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

contract MFIRegularInvestmentFactoryStorage {
    bool public turnOn;

    uint256 public contractVersion;

    mapping(uint256 => uint256) public lockSpan;
    mapping(uint256 => uint256) public timeSpanPid;
    mapping(uint256 => uint256) public timeSpanDepositRatio;
    mapping(uint256 => address[]) public allTradingContract;

    /// @notice main chain
    ICakePool public constant cakePool = ICakePool(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    IMetaFinanceTriggerPool public constant metaFinanceTriggerPool = IMetaFinanceTriggerPool(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    /// @notice test chain
    //CakePool public constant cakePool = CakePool(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    //IMetaFinanceTriggerPool public constant metaFinanceTriggerPool = IMetaFinanceTriggerPool(0x10ED43C718714eb63d5aA57B78B54704E256024E);
}
