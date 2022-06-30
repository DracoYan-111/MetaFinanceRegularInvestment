//SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "./utils/MfiAccessControl.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MCake is ERC20, MfiAccessControl {
    constructor(uint256 initialSupply) ERC20("Meta Cake", "MCake") {
        _mint(msg.sender, initialSupply);
    }

    /**
    * @dev Mint to user address
    * @param _userAddress User address
    * @param _amount Mint amount
    */
    function mint(address _userAddress, uint256 _amount) external {
        super._mint(_userAddress, _amount);
    }
}
