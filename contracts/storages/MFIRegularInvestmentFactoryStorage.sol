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
    address[] public allContract;
    uint256 public contractVersion;
    uint256[6] public lockSpan;

    mapping(uint256 => uint256) public timeSpanPid;
    mapping(address => uint256) public addressSubscript;
    uint256[6] public  timeSpanDepositRatio;
    mapping(uint256 => address[]) public indexTradingContract;

    IMFIRegularInvestmentRouter public mfiRegularInvestmentRouter;

    ICakePool public constant cakePool = ICakePool(0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8);

    IMetaFinanceTriggerPool public constant metaFinanceTriggerPool = IMetaFinanceTriggerPool(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    /// @notice test chain
    //CakePool public constant cakePool = CakePool(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    //IMetaFinanceTriggerPool public constant metaFinanceTriggerPool = IMetaFinanceTriggerPool(0x10ED43C718714eb63d5aA57B78B54704E256024E);
}
