// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { Test, console } from "forge-std/Test.sol";

abstract contract TestBase is Test {
    // CONSTANTS
    address internal constant DEPLOYER = address(bytes20(keccak256("DEPLOYER")));
    address internal constant USER = address(bytes20(keccak256("USER")));
    address internal constant USER_2 = address(bytes20(keccak256("USER_2")));

    modifier preSetup() {
        _;
    }

    function addressToBytes32(address x) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(x)));
    }
}