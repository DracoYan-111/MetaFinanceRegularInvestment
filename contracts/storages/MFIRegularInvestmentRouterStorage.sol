//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "../interfaces/IMFIRegularInvestmentRouter.sol";

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

contract MFIRegularInvestmentRouterStorage {

    uint256 public totalNumberPledges;
    uint256[] public shareRatio;
    address[] public paymentAddress;
    mapping(uint256 => uint256)  public pledgeQuantity;

    IMCake public mcake;

    IMFIRegularInvestmentFactory public factory;

}
