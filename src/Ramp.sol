// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import { ZekeErrors } from './libraries/ZekeErrors.sol';
// COMMENT BACK FOR CCIP IMPLEMENTATION
// import { ChainlinkAdaptor } from './libraries/ChainlinkAdaptor.sol';
import { ITokenManager, IEscrowManager, IOrderManager, IUserManager, IVerifier, IRamp, Order, TokenAndFeed, OrderStatus } from "./Interfaces.sol";
import { TokenManager } from './managers/TokenManager.sol';
import { EscrowManager } from './managers/EscrowManager.sol';
import { OrderManager } from './managers/OrderManager.sol';
import { UserManager } from './managers/UserManager.sol';

contract Ramp is ReentrancyGuard, Ownable, IRamp {
    using SafeERC20 for IERC20;

    ITokenManager public immutable tokenManager;
    IEscrowManager public immutable escrowManager;
    IOrderManager public immutable orderManager;
    IUserManager public immutable userManager;
    IVerifier public immutable verifier;
    address public immutable ccipRouter;

    event TokensTransferredToCCIP(
        bytes32 indexed messageId, 
        uint64 indexed destinationChainSelector,
        address receiver,
        address token,
        uint256 tokenAmount,
        address feeToken,
        uint256 fees 
    );

    constructor(
        address _owner,
        address _verifier,
        address _ccipRouter,
        TokenAndFeed[] memory _tokenAndFeeds
    ) Ownable(_owner) {
        // Deploy Manager contracts, and make this contract the owner for all Manager contracts
        tokenManager = new TokenManager(address(this));
        escrowManager = new EscrowManager(address(this));
        orderManager = new OrderManager(address(this));
        userManager = new UserManager(address(this));
        ccipRouter = _ccipRouter;
        verifier = IVerifier(_verifier);
        tokenManager.addValidTokens(_tokenAndFeeds);
    }

    /**
     * VIEW FUNCTIONS
     */

    function getDeposit(address _user, address _token) external view returns (uint256) {
        return escrowManager.getDeposit(_user, _token);
    }

    function getOrder(bytes32 _orderId) external view returns (Order memory) {
        return orderManager.getOrder(_orderId);
    }

    function isValidToken(address _token) external view returns (bool) {
        return tokenManager.isValidToken(_token);
    }

    function doesUserExist(address _userAddress) external view returns (bool) {
        return userManager.doesUserExist(_userAddress);
    }

    function getTokenFiatRate(address _token) external view returns (int256 fiatRate, uint256 decimals) {
        return tokenManager.getTokenFiatRate(_token);
    }

    /**
     * ONRAMPER FUNCTIONS
     */

    function addOrder(
        address _onramper, 
        address _token, 
        uint256 _amount,
        int256 _minFiatRate,
        uint64 _dstChainSelector
    ) external nonReentrant returns (bytes32) {
        //** INPUT VALIDATION **//
        if (_onramper == address(0)) revert ZekeErrors.ZeroAddress();
        if (_token == address(0)) revert ZekeErrors.ZeroAddress();
        if (_amount == 0) revert ZekeErrors.ZeroUint();
        if (_minFiatRate == 0) revert ZekeErrors.ZeroUint();
        if (_dstChainSelector == 0) revert ZekeErrors.ZeroUint();

        if (!tokenManager.isValidToken(_token)) revert ZekeErrors.TokenNotAccepted();
        if (!tokenManager.isMinFiatRateValid(_minFiatRate, _token)) revert ZekeErrors.MinFiatRateInvalid();

        return orderManager.addOrder(
            _onramper,
            _token,
            _amount,
            _minFiatRate,
            _dstChainSelector
        );
    }

    /**
     * OFFRAMPER FUNCTIONS
     */

    function registerUser(uint256 _userId, string calldata email) external {
        // add the proof verification part here
        userManager.registerUser(msg.sender, _userId, email);
    }

    function commitOrder(bytes32 _orderId, int256 _minFiatRate) external nonReentrant {
        if (_minFiatRate == 0) revert ZekeErrors.ZeroUint();
        if (!orderManager.doesOrderExist(_orderId)) revert ZekeErrors.OrderNotFound();
        Order memory order = orderManager.getOrder(_orderId);

        if (order.orderStatus == OrderStatus.CLOSED) revert ZekeErrors.OrderClosed();
        if (order.orderStatus == OrderStatus.COMMITTED && order.commitmentExpiryTime > block.timestamp) revert ZekeErrors.CurrentCommitment();

        if (!tokenManager.isMinFiatRateValid(_minFiatRate, order.token)) revert ZekeErrors.MinFiatRateInvalid();
        if (_minFiatRate < order.minFiatRate) revert ZekeErrors.MinFiatRateNotAccepted();

        if (escrowManager.getDeposit(msg.sender, order.token) < order.amount) revert ZekeErrors.InsufficientEscrowedFunds();
        if (userManager.doesUserExist(msg.sender)) revert ZekeErrors.UserNotRegistered();

        // Uncommit previous expired commitment by another user
        if (order.orderStatus == OrderStatus.COMMITTED && order.offramper != msg.sender) {
            orderManager.uncommitOrder(_orderId);
            escrowManager.uncommitDeposit(order.offramper, order.token, order.amount);
        }

        orderManager.commitOrder(msg.sender, _orderId);
        escrowManager.commitDeposit(msg.sender, order.token, order.amount);
    }

    function uncommitOrder(bytes32 _orderId) external nonReentrant {
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
        Order memory order = orderManager.getOrder(_orderId);

        if (!orderManager.doesOrderExist(_orderId)) revert ZekeErrors.OrderNotFound();
        if (order.orderStatus != OrderStatus.COMMITTED) revert ZekeErrors.NoCurrentOrderCommitment();
        if (order.commitmentExpiryTime < block.timestamp) revert ZekeErrors.OrderCommitmentExpired();
    
        (bool isValid, bytes memory _pubSignalsBytes) = verifier.verify(_proof);
        if (!isValid) revert ZekeErrors.OrderProofInvalid();

        uint[10] memory _pubSignals = abi.decode(_pubSignalsBytes, (uint[10]));

        /**
         * Validate _pubSignals
         * TODO: add more checks here
         * 
         * [0] modulus_hash;
         * [1] email_hash_poseidon
         * [2] post_compute_hash
         * [3] from_regex_reveal_poseidon
         * [4] actual_amount
         * [5] actual_timestamp
         * [6] packed_offramper_id_hashed
         * [7] packed_onramper_id_hashed
         * [8] email_nullifier
         * [9] intent_hash (public input)
        */

       if (userManager.compareUserId(order.offramper, _pubSignals[6])) revert ZekeErrors.IncorrectOfframper();
       if (userManager.compareUserId(order.onramper, _pubSignals[7])) revert ZekeErrors.IncorrectOnramper();
       if (orderManager.isNullifierConsumed(_pubSignals[8])) revert ZekeErrors.NullifierConsumed();
       // TODO - Check if uint256 cast here works, or should we have just casted the keccak256 hash to uint256 straight away
       if (_pubSignals[9] != uint256(_orderId)) revert ZekeErrors.IncorrectOrder();
       if (!tokenManager.isActualAmountSufficient(_pubSignals[4], order.minFiatRate, order.token, order.amount)) revert ZekeErrors.ActualAmountInsufficient();

        orderManager.completeOrder(_orderId, _pubSignals[8]);

        IERC20(order.token).safeTransfer(order.onramper, order.amount);

        // COMMENT BACK FOR CCIP IMPLEMENTATION - must also make function payable
        // if (order.dstChainSelector == block.chainid) {
        //     IERC20(order.token).safeTransfer(order.onramper, order.amount);
        // } else {
        //     // https://docs.chain.link/ccip/tutorials/cross-chain-tokens

        //     IERC20(order.token).approve(ccipRouter, order.amount);
        //     bytes32 ccipMessageId = ChainlinkAdaptor.transferTokensPayNative(
        //         order.dstChainSelector,
        //         order.onramper,
        //         order.token,
        //         order.amount,
        //         ccipRouter
        //     );

        //     emit TokensTransferredToCCIP(
        //         ccipMessageId,
        //         order.dstChainSelector,
        //         order.onramper,
        //         order.token,
        //         order.amount,
        //         address(0),
        //         msg.value
        //     );
        // }
    }

    function deposit(
        address _token,
        uint256 _amount
    ) external nonReentrant {
        if (_token == address(0)) revert ZekeErrors.ZeroAddress();
        if (_amount == 0) revert ZekeErrors.ZeroUint();
        if (!tokenManager.isValidToken(_token)) revert ZekeErrors.TokenNotAccepted();

        escrowManager.deposit(msg.sender, _token, _amount);
        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
    }

    function withdraw(
        address _token,
        uint256 _amount
    ) external nonReentrant {
        if (_token == address(0)) revert ZekeErrors.ZeroAddress();
        if (_amount == 0) revert ZekeErrors.ZeroUint();
        if (!tokenManager.isValidToken(_token)) revert ZekeErrors.TokenNotAccepted();
        if (escrowManager.getDeposit(msg.sender, _token) < _amount) revert ZekeErrors.InsufficientEscrowedFunds();
        escrowManager.withdraw(msg.sender, _token, _amount);
        IERC20(_token).safeTransfer(msg.sender, _amount);
    }

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
