// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ITokenManager, TokenAndFeed } from "../Interfaces.sol";
import { ZekeErrors } from '../libraries/ZekeErrors.sol';
import { AggregatorV3Interface } from "@chainlink/interfaces/feeds/AggregatorV3Interface.sol";
import { SafeCast } from '@openzeppelin/contracts/utils/math/SafeCast.sol';

contract TokenManager is Ownable, ITokenManager {
    // MAX 1% difference between Chainlink feed rate and minFiatRate
    // Start as 'constant', can set as immutable or dynamic value later
    int256 public constant MAX_FEED_RATE_DIFF = 1e16; 
    mapping(address => address) public tokenFeed;

    event TokenAdded(address indexed token, address indexed feed);
    event TokenRemoved(address indexed token);

    constructor(address _owner) Ownable(_owner) {}

    /**
     * VIEW FUNCTIONS
     */

    function isValidToken(address _token) external view returns (bool) {
        return tokenFeed[_token] != address(0);
    }

    function getTokenFiatRate(address _token) external view returns (int256 fiatRate, uint256 decimals) {
        address _feed = tokenFeed[_token];
        uint8 decimalsRaw = AggregatorV3Interface(_feed).decimals();
        (
            /* uint80 roundID */,
            int256 chainlinkFeedRate,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = AggregatorV3Interface(_feed).latestRoundData();
        return (chainlinkFeedRate, uint256(decimalsRaw));
    }

    function isMinFiatRateValid(int256 _minFiatRate, address _token) external view returns (bool) {
        // https://docs.chain.link/data-feeds/using-data-feeds
        address _feed = tokenFeed[_token];
        (
            /* uint80 roundID */,
            int256 chainlinkFeedRate,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = AggregatorV3Interface(_feed).latestRoundData();

        int256 _maxToleratedFiatRate = chainlinkFeedRate * (1e18 + MAX_FEED_RATE_DIFF) / 1e18;
        int256 _minToleratedFiatRate = chainlinkFeedRate * (1e18 - MAX_FEED_RATE_DIFF) / 1e18;
        
        if (_minFiatRate < _minToleratedFiatRate || _minFiatRate > _maxToleratedFiatRate) {
            return false;
        }

        return true;
    }

    function isActualAmountSufficient(uint256 _actualAmount, int256 _minFiatRate, address _token, uint256 _tokenAmount) external view returns (bool) {
        uint8 decimals = AggregatorV3Interface(tokenFeed[_token]).decimals();
        
        // Will revert if _minFiatRate is a negative value
        uint256 _minFiatRateCasted = SafeCast.toUint256(_minFiatRate);

        // Convert tokenAmount to actual amount
        // TODO - Check this maths works
        uint256 _tokenAmountConverted = _tokenAmount * _minFiatRateCasted / uint256(decimals);

        if (_actualAmount < _tokenAmountConverted) return false;
        return true;
    }

    function getFeed(address _token) external view returns (address) {
        return tokenFeed[_token];
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
            emit TokenRemoved(token);
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
            emit TokenAdded(token, feed);
        }
    }
}