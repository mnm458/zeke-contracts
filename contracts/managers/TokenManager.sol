// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../Interfaces.sol";

contract TokenManager is Ownable, ITokenManager {
    using SafeERC20 for IERC20;
    
    mapping(address => uint256) public validTokens;

    constructor(address _owner, address[] memory stakingTokens) Ownable(_owner) {
        _addValidTokens(stakingTokens);
    }

    function isValidToken(address _token) external view returns(bool){
        return validTokens[_token] == 1;
    }


    function addValidTokens(address[] memory tokens) external onlyOwner {
        _addValidTokens(tokens);
    }

    function _addValidTokens(address[] memory tokens) internal {
        uint256 tokenLength = tokens.length;
        for (uint256 index = 0; index < tokenLength; index++) {
            validTokens[tokens[index]] = 1;
        }
    }

    function removeValidTokens(address[] memory tokens) external onlyOwner {
        uint256 tokenLength = tokens.length;
        for (uint256 index = 0; index < tokenLength; index++) {
            validTokens[tokens[index]] = 0;
        }
    }

}