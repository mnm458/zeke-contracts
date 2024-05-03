// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../Interfaces.sol";
import "hardhat/console.sol";

contract EscrowManager is Ownable, ReentrancyGuard, IEscrowManager {


    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    mapping(bytes32 => Deposit) private deposits;

    constructor(address _owner) Ownable(_owner){}


    function getDepositID(address user, address token) external pure returns (bytes32) {
        bytes32 key = keccak256(abi.encodePacked(user, token));
        return key;
    }

    function getDeposit(bytes32 _deposit) external view returns (Deposit memory) {
        return deposits[_deposit];
    }


    /* Better to be handled by the Ramp contract itself */
    function createDeposit(address _token, uint256 _amount, address offramper) external nonReentrant onlyOwner {
        bytes32 depositKey = this.getDepositID(offramper, _token);
        Deposit storage deposit = deposits[depositKey];
        
        if (deposit.amount == 0) {
            // Create a new deposit entry
            deposits[depositKey] = Deposit({
                creationTimestamp: block.timestamp,
                token: _token,
                amount: _amount
            });

        } else {
            // Update an existing deposit entry
            require(deposit.token == _token, "Token must match!");
            deposit.amount += _amount;

        }
    }

    function commitDeposit(bytes32 depositKey, uint256 _amount) external onlyOwner nonReentrant {
        // check if there are any orders pending
        // for now, not making this external
        // TODO: in future, need to keep track of committed orders also

        Deposit storage deposit = deposits[depositKey];

        require(deposit.amount >= _amount, "Insufficient deposited amount");
        require(_amount > 0, "Zero value removal");

        deposit.amount -= _amount;
        
    }

    function uncommitDeposit(bytes32 depositKey, uint256 _amount) external onlyOwner nonReentrant {
        // check if there are any orders pending
        // for now, not making this external
        // TODO: in future, need to keep track of committed orders also

        Deposit storage deposit = deposits[depositKey];

        deposit.amount += _amount;
        
    }


}