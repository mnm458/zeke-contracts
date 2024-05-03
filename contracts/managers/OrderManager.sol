// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../Interfaces.sol";

import "hardhat/console.sol";

contract OrderManager is Ownable, ReentrancyGuard, IOrderManager {
    
    event OrderCreation(uint256 indexed intentId);

    
    mapping(uint256 => Order) public orders;

    mapping(address => uint256) public userId;
    mapping(uint256 => bool) public nullifierGraveyard;

    constructor(address _owner) Ownable(_owner) {}

    function addOrder(
        uint256 intentId,
        uint256 requestedAmount,
        uint256 minFiatAmount,
        address tokenAddress,
        address onramper
    ) external nonReentrant onlyOwner {
        Order memory order = orders[intentId];
        require(order.creationTimestamp == 0, "Order already exists for the given intentId");
        require(order.status == uint16(0), "cannot overwrite order!");
        require(order.onramper == address(0), "cannot overwrite order!");

        orders[intentId] = Order({
            creationTimestamp: uint120(block.timestamp),
            offramperDeadline: uint120(block.timestamp + 1_800),
            status: uint16(0),
            onramper: onramper,
            offramper: address(0),
            token: tokenAddress,
            requestedAmount: requestedAmount,
            minFiatAmount: minFiatAmount,
            intentId: intentId
        });
        // orders[intentId] = newOrder;
        emit OrderCreation(intentId);
    }

    function getOrder(uint256 intentId)
        external
        view
        returns (Order memory)
    {
        return orders[intentId];
    }


    function commitOrder(uint256 intentId, address offramper) external onlyOwner {
        Order storage order = orders[intentId];

        require(order.creationTimestamp != 0, "Order does not exist");
        require(order.status == uint16(0), "wrong stage");

        order.offramper = offramper;
        order.status = uint16(1);
    }

    function uncommitOrder(uint256 intentId) external onlyOwner {
        Order storage order = orders[intentId];
        require(order.creationTimestamp != 0, "Order does not exist");
        require(order.status == uint16(1), "wrong stage");

        order.offramper = address(0);
        order.status = uint16(0);
    }

    function completeOrder(uint256 intentId, uint256 nullifier) external nonReentrant onlyOwner {


        Order storage order = orders[intentId];
        require(order.creationTimestamp != 0, "Order does not exist for the given intentId");
        
        require(order.status == uint16(1), "wrong stage!");

        if(msg.sender == order.onramper){
            require(block.timestamp > order.offramperDeadline, "offramper first!");
        }

        // 2 for "complete"
        order.status = uint16(2);

        // must be done by ramp
        nullifierGraveyard[nullifier] = true;

    }


    function checkNullifier(uint256 nullifier) external view returns (bool) {
        return !nullifierGraveyard[nullifier];
    }
    
    function checkId(uint256 intentId, uint256 amount, uint256 timestamp) external view returns(bool) {
        Order memory order = orders[intentId];

        return (amount >= order.minFiatAmount);

        /* TODO: add timestamp to the verification process */
    }
}