// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "../Interfaces.sol";

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ITokenManager, TokenAndFeed } from "../Interfaces.sol";
import { ZekeErrors } from '../libraries/ZekeErrors.sol';

contract TokenManager is Ownable, ITokenManager {
    mapping(address => address) public tokenFeed;

    constructor(address _owner) Ownable(_owner) {}

    /**
     * VIEW FUNCTIONS
     */

    function isValidToken(address _token) external view returns (bool) {
        return tokenFeed[_token] != address(0);
    }

    /**
     * STATE MUTATING FUNCTIONS
     */

    function addValidTokens(TokenAndFeed[] memory _tokenAndFeeds) external onlyOwner {
        _addValidTokens(_tokenAndFeeds);
    }

    function removeValidTokens(address[] memory _tokens) external onlyOwner {
        uint256 tokenLength = _tokens.length;
        for (uint256 index = 0; index < tokenLength; index++) {
            address token = _tokens[index];
            tokenFeed[token] = address(0);
            // TODO - Emit event
        }
    }

    /**
     * INTERNAL HELPERS - STATE MUTATING FUNCTIONS
     */

    function _addValidTokens(TokenAndFeed[] memory _tokenAndFeeds) internal {
        uint256 tokenLength = _tokenAndFeeds.length;
        for (uint256 index = 0; index < tokenLength; index++) {
            address token = _tokenAndFeeds[index].token;
            address feed = _tokenAndFeeds[index].feed;
            if(token == address(0)) revert ZekeErrors.ZeroAddress();
            if(feed == address(0)) revert ZekeErrors.ZeroAddress();
            tokenFeed[token] = feed;
            // TODO - Emit event
        }
    }
}