// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Import this file to use console.log
import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract USDTToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("Tether", "USDT") {
        _mint(msg.sender, initialSupply);
    }
}
