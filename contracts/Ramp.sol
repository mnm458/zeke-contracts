// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import { ZekeErrors } from './libraries/ZekeErrors.sol';

import { ITokenManager, IEscrowManager, IOrderManager, IUserManager, IVerifier, Order, TokenAndFeed, OrderStatus } from "./Interfaces.sol";
import { TokenManager } from './managers/TokenManager.sol';
import { EscrowManager } from './managers/EscrowManager.sol';
import { OrderManager } from './managers/OrderManager.sol';
import { UserManager } from './managers/UserManager.sol';

contract Ramp is ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;

    ITokenManager public immutable tokenManager;
    IEscrowManager public immutable escrowManager;
    IOrderManager public immutable orderManager;
    IUserManager public immutable userManager;
    IVerifier public immutable verifier;

    constructor(
        address _verifier,
        address _owner,
        TokenAndFeed[] memory _tokenAndFeeds
    ) Ownable(_owner) {
        // Deploy Manager contracts, and make this contract the owner for all Manager contracts
        tokenManager = new TokenManager(address(this));
        escrowManager = new EscrowManager(address(this));
        orderManager = new OrderManager(address(this));
        userManager = new UserManager(address(this));
        verifier = IVerifier(_verifier);
        tokenManager.addValidTokens(_tokenAndFeeds);
    }

    /**
     * VIEW FUNCTIONS
     */

    function getOrder(bytes32 _orderId) external view returns (Order memory) {
        return orderManager.getOrder(_orderId);
    }


    /**
     * ONRAMPER FUNCTIONS
     */

    function addOrder(
        address _onramper, 
        address _token, 
        uint256 _amount,
        int256 _minFiatRate,
        uint64 _dstchainId
    ) external nonReentrant {
        //** INPUT VALIDATION **//
        if (_onramper == address(0)) revert ZekeErrors.ZeroAddress();
        if (_token == address(0)) revert ZekeErrors.ZeroAddress();
        if (_amount == 0) revert ZekeErrors.ZeroUint();
        if (_minFiatRate == 0) revert ZekeErrors.ZeroUint();
        if (_dstchainId == 0) revert ZekeErrors.ZeroUint();

        if (!tokenManager.isValidToken(_token)) revert ZekeErrors.TokenNotAccepted();
        if (!tokenManager.isMinFiatRateValid(_minFiatRate, _token)) revert ZekeErrors.MinFiatRateInvalid();

        orderManager.addOrder(
            _onramper,
            _token,
            _amount,
            _minFiatRate,
            _dstchainId
        );
    }

    /**
     * OFFRAMPER FUNCTIONS
     */

    function registerUser(uint256 _userId, string calldata email) external {
        // add the proof verification part here
        userManager.registerUser(msg.sender, _userId, email);
    }

    function commitOrder(bytes32 _orderId, int256 _minFiatRate) external {
        if (_minFiatRate == 0) revert ZekeErrors.ZeroUint();
        if (!orderManager.doesOrderExist(_orderId)) revert ZekeErrors.OrderNotFound();
        Order memory order = orderManager.getOrder(_orderId);

        if (order.orderStatus == OrderStatus.CLOSED) revert ZekeErrors.OrderClosed();
        if (order.orderStatus == OrderStatus.COMMITTED && order.commitmentExpiryTime > block.timestamp) revert ZekeErrors.CurrentCommitment();

        if (!tokenManager.isMinFiatRateValid(_minFiatRate, order.token)) revert ZekeErrors.MinFiatRateInvalid();
        if (_minFiatRate < order.minFiatRate) revert ZekeErrors.MinFiatRateNotAccepted();

        if (escrowManager.getDeposit(msg.sender, order.token) < order.amount) revert ZekeErrors.InsufficientEscrowedFunds();
        if (userManager.doesUserExist(msg.sender)) revert ZekeErrors.UserNotRegistered();

        orderManager.commitOrder(msg.sender, _orderId);
        escrowManager.commitDeposit(msg.sender, order.token, order.amount);
    }

    function uncommitOrder(bytes32 _orderId) external {
        if (!orderManager.doesOrderExist(_orderId)) revert ZekeErrors.OrderNotFound();
        Order memory order = orderManager.getOrder(_orderId);
        if (order.orderStatus == OrderStatus.CLOSED) revert ZekeErrors.OrderClosed();
        if (order.orderStatus == OrderStatus.OPEN) revert ZekeErrors.OrderOpen();
        if (order.offramper != msg.sender) revert ZekeErrors.NotCurrentCommittedOfframper();

        orderManager.uncommitOrder(_orderId);
        escrowManager.uncommitDeposit(msg.sender, order.token, order.amount);
    }

    function completeOrder(
        bytes32 _orderId,
        bytes calldata _proof
    ) external nonReentrant {
    //     Order memory order = orderManager.getOrder(_orderId);

    //     if (!orderManager.doesOrderExist(_orderId)) revert ZekeErrors.OrderNotFound();
    //     if (order.orderStatus != OrderStatus.COMMITTED) revert ZekeErrors.NoCurrentOrderCommitment();
    //     if (order.commitmentExpiryTime < block.timestamp) revert ZekeErrors.OrderCommitmentExpired();
    
    //     (bool isValid, bytes memory _pubSignalsBytes) = verifier.verify(_proof);
    //     if (!isValid) revert ZekeErrors.OrderProofInvalid();

    //     uint[10] memory _pubSignals = abi.decode(_pubSignalsBytes, (uint[10]));

    //     // ** Validate _pubSignals ** //
    //     // TODO: add more checks here

    //     require(_pubSignals[4] > order.minFiatRate, "Not enough payment!");
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

    //     orderManager.completeOrder(_orderId, _pubSignals[8]);

    //     IERC20 token = IERC20(order.token);
    //     token.safeTransfer(order.onramper, order.requestedAmount);
    }

    function deposit(
        address _token,
        uint256 _amount
    ) external nonReentrant {
    //     IERC20 token = IERC20(_token);
    //     uint256 allowance = token.allowance(msg.sender, address(this));

    //     require(allowance >= _amount, "Insufficient allowance");
    //     require(_amount > 0, "Zero value deposit");
    //     require(tokenManager.isValidToken(_token), "Not a valid token!");

    //     stakeManager.createDeposit(_token, _amount, msg.sender);
    //     token.safeTransferFrom(msg.sender, address(this), _amount);
    }

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

    /**
     * ADMIN ONLY FUNCTIONS
     */

    function addValidTokens(TokenAndFeed[] memory _tokenAndFeeds) external onlyOwner {
        tokenManager.addValidTokens(_tokenAndFeeds);
    }

    function removeValidTokens(address[] memory tokens) external onlyOwner {
        tokenManager.removeValidTokens(tokens);
    }
}
