// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "../Interfaces.sol";
import "hardhat/console.sol";

contract UserManager is IUserManager {
    mapping(address => uint256) public userId;

    event UserRegistered (uint256 indexed id, address indexed userAddress, string email);
    function registerUser(address _userAddress, uint256 _userId, string calldata email) external {
        // add the proof verification part here
        require(userId[_userAddress] == 0, "Already in use!");
        userId[_userAddress] = _userId;

        emit UserRegistered(_userId, _userAddress, email);
    }

    function doesUserExist(address _userAddress) external view returns (bool){
        return (userId[_userAddress] != 0);
    }

    function compareUserId(address _userAddress, uint256 id) external view returns(bool){
        return (userId[_userAddress] == id);
    }

}