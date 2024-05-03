// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import { ITokenManager, IStakeManager, IOrderManager, IUserManager, IVerifier, Order, Deposit } from "./Interfaces.sol";
import { TokenManager } from './managers/TokenManager.sol';
import { StakeManager } from './managers/StakeManager.sol';
import { OrderManager } from './managers/OrderManager.sol';
import { UserManager } from './managers/UserManager.sol';

contract Ramp is ReentrancyGuard {
    // using SafeERC20 for IERC20;

    // event Staked(address indexed user, uint256 amount);
    // event Withdrawn(address indexed user, uint256 amount);

    // ITokenManager immutable tokenManager;
    // IStakeManager immutable stakeManager;
    // IOrderManager immutable orderManager;
    // IUserManager immutable userManager;
    // IVerifier immutable verifier;

    // constructor(
    //     address _tokenManager,
    //     address _stakeManager,
    //     address _orderManager,
    //     address _userManager,
    //     address _verifier
    // ) {
    //     tokenManager = ITokenManager(_tokenManager);
    //     stakeManager = IStakeManager(_stakeManager);
    //     orderManager = IOrderManager(_orderManager);
    //     userManager = IUserManager(_userManager);
    //     verifier = IVerifier(_verifier);
    // }

    // function getDepositID(
    //     address user,
    //     address token
    // ) external view returns (bytes32) {
    //     return stakeManager.getDepositID(user, token);
    // }

    // // function addValidTokens(address[] memory tokens) external {
    // //     tokenManager.addValidTokens(tokens);
    // // }

    // function removeValidTokens(address[] memory tokens) external {
    //     tokenManager.removeValidTokens(tokens);
    // }

    // function registerUser(uint256 _userId, string calldata email) external {
    //     // add the proof verification part here
    //     userManager.registerUser(msg.sender, _userId, email);
    // }

    // function addOrder(
    //     uint256 intentId,
    //     uint256 requestedAmount,
    //     uint256 minFiatAmount,
    //     address tokenAddress
    // ) external nonReentrant {
    //     require(tokenManager.isValidToken(tokenAddress), "Not a valid token!");
    //     //TODO: Add chainlink pricefeed. MCT:= Ratio between said stablecoin and USD. Chainlink price feed to verify min ratio difference is maintained
    //     orderManager.addOrder(
    //         intentId,
    //         requestedAmount,
    //         minFiatAmount,
    //         tokenAddress,
    //         msg.sender
    //     );
    // }

    // function getOrder(uint256 intentId) external view returns (Order memory) {
    //     return orderManager.getOrder(intentId);
    // }

    // function commitOrder(uint256 intentId) external {
    //     Order memory order = orderManager.getOrder(intentId);
    //     bytes32 depositKey = stakeManager.getDepositID(msg.sender, order.token);
    //     Deposit memory deposit = stakeManager.getDeposit(depositKey);

    //     require(order.token == deposit.token, "Not matching tokens");
    //     require(order.requestedAmount <= deposit.amount, "Not enough stake!");
    //     require(userManager.doesUserExist(msg.sender), "Not registered user!");

    //     orderManager.commitOrder(intentId, msg.sender);
    //     stakeManager.commitDeposit(depositKey, order.requestedAmount);
    // }

    // function uncommitOrder(uint256 intentId) external {
    //     Order memory order = orderManager.getOrder(intentId);
    //     require(order.offramper == msg.sender, "not offramper!");

    //     bytes32 depositKey = stakeManager.getDepositID(msg.sender, order.token);

    //     stakeManager.uncommitDeposit(depositKey, order.requestedAmount);
    //     orderManager.uncommitOrder(intentId);
    // }

    // function completeOrder(
    //     uint256 intentId,
    //     bytes calldata proof
    // ) external nonReentrant {
    //     Order memory order = orderManager.getOrder(intentId);

    //     (bool isValid, bytes memory _pubSignalsBytes) = verifier.verify(proof);

    //     uint[10] memory _pubSignals = abi.decode(_pubSignalsBytes, (uint[10]));

    //     // TODO: add more checks here

    //     require(isValid, "Not valid proof!");
    //     require(
    //         order.creationTimestamp != 0,
    //         "Order does not exist for the given intentId"
    //     );
    //     require(_pubSignals[4] > order.minFiatAmount, "Not enough payment!");
    //     require(
    //         orderManager.checkNullifier(_pubSignals[8]),
    //         "Nullifier before!"
    //     );
    //     require(
    //         orderManager.checkId(
    //             _pubSignals[9],
    //             _pubSignals[4],
    //             _pubSignals[5]
    //         ),
    //         "Not correct order!"
    //     );
    //     require(
    //         userManager.compareUserId(order.offramper, _pubSignals[6]),
    //         "not correct offramper!"
    //     );

    //     require(
    //         userManager.compareUserId(order.onramper, _pubSignals[7]),
    //         "not correct onramper!"
    //     );

    //     orderManager.completeOrder(intentId, _pubSignals[8]);

    //     IERC20 token = IERC20(order.token);
    //     token.safeTransfer(order.onramper, order.requestedAmount);
    // }

    // function createDeposit(
    //     address _token,
    //     uint256 _amount
    // ) external nonReentrant {
    //     IERC20 token = IERC20(_token);
    //     uint256 allowance = token.allowance(msg.sender, address(this));

    //     require(allowance >= _amount, "Insufficient allowance");
    //     require(_amount > 0, "Zero value deposit");
    //     require(tokenManager.isValidToken(_token), "Not a valid token!");

    //     stakeManager.createDeposit(_token, _amount, msg.sender);
    //     token.safeTransferFrom(msg.sender, address(this), _amount);
    // }

    /* TODO: Will work on this later */
    // function _removeDeposit(address _token, uint256 _amount) internal nonReentrant {
    //     // check if there are any orders pending
    //     // for now, not making this external
    //     // TODO: in future, need to keep track of committed orders also

    //     bytes32 depositKey = stakeManager.getDepositID(msg.sender, _token);
    //     Deposit storage deposit = stakeManager.getDeposit(depositKey);

    //     require(deposit.amount >= _amount, "Insufficient deposited amount");
    //     require(_amount > 0, "Zero value removal");

    //     IERC20 token = IERC20(_token);
    //     deposit.amount -= _amount;
    //     token.safeTransfer(msg.sender, _amount);
    // }
}
