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
    
    event OrderCreation(bytes32 indexed intentId);
    mapping(bytes32 => Order) public orders;
    mapping(uint256 => bool) public nullifierGraveyard;

    constructor(address _owner) Ownable(_owner) {}

    /**
     * VIEW FUNCTIONS
     */

    function getOrder(bytes32 orderId) external view returns (Order memory)
    {
        return orders[orderId];
    }

    function doesOrderExist(bytes32 orderId) external view returns (bool) {
        return orders[orderId].token != address(0);
    }

    function checkNullifier(uint256 nullifier) external view returns (bool) {
        return !nullifierGraveyard[nullifier];
    }
    
    function checkId(bytes32 _orderId, uint256 _amount, uint256 _timestamp) external view returns(bool) {
        Order memory order = orders[_orderId];
        // return (_amount >= order.minFiatAmount);
        /* TODO: add timestamp to the verification process */
    }


    /**
     * ONRAMPER FUNCTIONS
     */

    function addOrder(
        address _onramper, 
        address _token, 
        uint256 _amount,
        int256 _minFiatRate,
        uint64 _dstChainId
    ) external nonReentrant onlyOwner returns (bytes32) {
        // Assume input validation done in entrypoint in Ramp.sol

        // OrderID is hash of 'msg.sender', 'block.timestamp', '_token', '_amount'
        bytes32 orderId = keccak256(abi.encodePacked(_onramper, block.timestamp, _token, _amount));

        Order memory newOrder = Order({
            token: _token, 
            commitmentExpiryTime: 0,
            dstChainId: _dstChainId,
            onramper: _onramper,
            orderStatus: OrderStatus.OPEN,
            offramper: address(0),
            amount: _amount,
            minFiatRate: _minFiatRate
        });

        orders[orderId] = newOrder;

        emit OrderCreation(orderId);
        return orderId;
    }

    /**
     * OFFRAMPER FUNCTIONS
     */

    function commitOrder(address _offramper, bytes32 _orderId) external onlyOwner {
        Order storage order = orders[_orderId];
        order.orderStatus = OrderStatus.COMMITTED;
        order.commitmentExpiryTime = uint32(block.timestamp + COMMITMENT_EXPIRY_TIME);
        order.offramper = _offramper;

        // TODO - Emit event
    }

    function uncommitOrder(bytes32 _orderId) external onlyOwner {
        //** UPDATE STATE **//

        Order storage order = orders[_orderId];
        order.orderStatus = OrderStatus.OPEN;
        order.commitmentExpiryTime = 0;
        order.offramper = address(0);

        //** EMIT EVENT **//
    }

    /**
     * COMPLETE ORDER FUNCTION
     */

    function completeOrder(bytes32 _orderId, uint256 _nullifier) external nonReentrant onlyOwner {
        Order storage order = orders[_orderId];
        order.orderStatus = OrderStatus.CLOSED;

        // must be done by ramp
        nullifierGraveyard[_nullifier] = true;

        // TODO - Emit event
    }
}