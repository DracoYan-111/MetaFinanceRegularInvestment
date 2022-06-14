//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "../interfaces/IMFIRegularInvestmentInterfaces.sol";

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

contract MFIRegularInvestmentStorage {

    /// @notice main chain
    CakePool public constant cakePool = CakePool(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    IMetaFinanceTriggerPool public constant metaFinanceTriggerPool = IMetaFinanceTriggerPool(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    /// @notice test chain
    //CakePool public constant cakePool = CakePool(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    //IMetaFinanceTriggerPool public constant metaFinanceTriggerPool = IMetaFinanceTriggerPool(0x10ED43C718714eb63d5aA57B78B54704E256024E);
}
