// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/AccessControl.sol";


abstract contract MfiAccessControl is AccessControl {

    uint256 public proportion;

    uint256 public constant MAX = ~uint256(0);

    uint256[6] public timeSpan = [1 weeks, 2 weeks, 5 weeks, 10 weeks, 26 weeks, 52 weeks];

    // money administrator
    bytes32 public constant MONEY_ADMINISTRATOR = bytes32(keccak256(abi.encodePacked("MFI_Money_Administrator")));

    // data administrator
    bytes32 public constant DATA_ADMINISTRATOR = bytes32(keccak256(abi.encodePacked("MFI_Data_Administrator")));

    // project administrator
    bytes32 public constant PROJECT_ADMINISTRATOR = bytes32(keccak256(abi.encodePacked("MFI_Project_Administrator")));

}
