// SPDX-License-Identifier: Unlicensed
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.0;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract USDT is ERC20, Ownable {
    constructor(
        address initialOwner
    ) ERC20("USDT", "USDT") Ownable(initialOwner) {
        // Mint 1M tokens to deployer
        _mint(msg.sender, 1e24);
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
