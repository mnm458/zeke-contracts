// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IUserManager } from "../Interfaces.sol";
import { ZekeErrors } from '../libraries/ZekeErrors.sol';

contract UserManager is IUserManager, Ownable {
    mapping(address => uint256) public userId;

    event UserRegistered (uint256 indexed id, address indexed userAddress, string email);

    constructor(address _owner) Ownable(_owner) {}

    /**
     * VIEW FUNCTIONS
     */

    function doesUserExist(address _userAddress) external view returns (bool) {
        return (userId[_userAddress] != 0);
    }

    function compareUserId(address _userAddress, uint256 id) external view returns(bool){
        return (userId[_userAddress] == id);
    }

    /**
     * STATE-MUTATING FUNCTIONS
     */

    function registerUser(address _userAddress, uint256 _userId, string calldata email) external {
        // ** INPUT VALIDATION ** //
        // add the proof verification part here
        if (_userAddress == address(0)) revert ZekeErrors.ZeroAddress();
        if (_userId == 0) revert ZekeErrors.ZeroUint();
        if (userId[_userAddress] != 0) revert ZekeErrors.UserAlreadyRegistered();

        // ** UPDATE STATE ** //
        userId[_userAddress] = _userId;

        // ** EMIT EVENT ** //
        emit UserRegistered(_userId, _userAddress, email);
    }
}