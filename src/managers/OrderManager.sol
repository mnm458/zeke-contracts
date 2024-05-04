// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { Order, OrderStatus, IOrderManager } from "../Interfaces.sol";
import { ZekeErrors } from '../libraries/ZekeErrors.sol';

contract OrderManager is Ownable, ReentrancyGuard, IOrderManager {
    // 30 minute expiry time for commitment
    // Start as 'constant', can set as immutable or dynamic value later
    uint256 public constant COMMITMENT_EXPIRY_TIME = 1800;
    
    event OrderCreated(uint256 indexed orderId);
    event OrderCompleted(uint256 indexed orderId);
    event OrderCommitted(uint256 indexed orderId);
    event OrderUncommitted(uint256 indexed orderId);

    mapping(uint256 => Order) public orders;
    mapping(uint256 => bool) public nullifierGraveyard;

    constructor(address _owner) Ownable(_owner) {}

    /**
     * VIEW FUNCTIONS
     */

    function getOrder(uint256 orderId) external view returns (Order memory)
    {
        return orders[orderId];
    }

    function doesOrderExist(uint256 orderId) external view returns (bool) {
        return orders[orderId].token != address(0);
    }

    function isNullifierConsumed(uint256 nullifier) external view returns (bool) {
        return nullifierGraveyard[nullifier];
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
    ) external nonReentrant onlyOwner returns (uint256) {
        // Assume input validation done in entrypoint in Ramp.sol

        // OrderID is hash of 'msg.sender', 'block.timestamp', '_token', '_amount'
        bytes32 orderIdHash = keccak256(abi.encodePacked(_onramper, block.timestamp, _token, _amount));
        // Ensure orderId is <248 bits, while being a uint256 type - restraint for ZK Proof
        uint256 orderId = uint256(uint248(uint256(orderIdHash)));

        Order memory newOrder = Order({
            token: _token, 
            commitmentExpiryTime: 0,
            dstChainSelector: _dstChainSelector,
            onramper: _onramper,
            orderStatus: OrderStatus.OPEN,
            offramper: address(0),
            amount: _amount,
            minFiatRate: _minFiatRate
        });

        orders[orderId] = newOrder;

        emit OrderCreated(orderId);
        return orderId;
    }

    /**
     * OFFRAMPER FUNCTIONS
     */

    function commitOrder(address _offramper, uint256 _orderId) external nonReentrant onlyOwner {
        // Assume input validation done in entrypoint in Ramp.sol
        Order storage order = orders[_orderId];
        order.orderStatus = OrderStatus.COMMITTED;
        order.commitmentExpiryTime = uint32(block.timestamp + COMMITMENT_EXPIRY_TIME);
        order.offramper = _offramper;
        emit OrderCommitted(_orderId);
    }

    function uncommitOrder(uint256 _orderId) external nonReentrant onlyOwner {
        // Assume input validation done in entrypoint in Ramp.sol
        Order storage order = orders[_orderId];
        order.orderStatus = OrderStatus.OPEN;
        order.commitmentExpiryTime = 0;
        order.offramper = address(0);

        //** EMIT EVENT **//
        emit OrderUncommitted(_orderId);
    }

    /**
     * COMPLETE ORDER FUNCTION
     */

    function completeOrder(uint256 _orderId, uint256 _nullifier) external nonReentrant onlyOwner {
        Order storage order = orders[_orderId];
        order.orderStatus = OrderStatus.CLOSED;

        // must be done by ramp
        nullifierGraveyard[_nullifier] = true;
        emit OrderCompleted(_orderId);
    }
}