// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ZekeErrors } from '../libraries/ZekeErrors.sol';
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { IEscrowManager } from "../Interfaces.sol";

contract EscrowManager is Ownable, ReentrancyGuard, IEscrowManager {
    event Deposited(address indexed user, address indexed token, uint256 amount);
    event Withdrawn(address indexed user, address indexed token, uint256 amount);

    // offramper => token => deposit amount
    mapping(address => mapping(address => uint256)) private deposits;

    constructor(address _owner) Ownable(_owner){}

    /**
     * VIEW FUNCTIONS
     */

    function getDeposit(address _user, address _token) external view returns (uint256) {
        return deposits[_user][_token];
    }

    /**
     * OFFRAMPER FUNCTIONS
     */


    function deposit(address _offramper, address _token, uint256 _amount) external nonReentrant onlyOwner {
        if (_token == address(0)) revert ZekeErrors.ZeroAddress();
        if (_offramper == address(0)) revert ZekeErrors.ZeroAddress();
        if (_amount == 0) revert ZekeErrors.ZeroUint();
        deposits[_offramper][_token] += _amount;
        // TODO - Emit event
    }

    // Remove deposit from escrowed funds
    function commitDeposit(address _offramper, address _token, uint256 _amount) external onlyOwner nonReentrant {
        if (_token == address(0)) revert ZekeErrors.ZeroAddress();
        if (_offramper == address(0)) revert ZekeErrors.ZeroAddress();
        if (_amount == 0) revert ZekeErrors.ZeroUint();

        uint256 currentDeposit = deposits[_offramper][_token];
        if (currentDeposit < _amount) revert ZekeErrors.InsufficientDepositAmount();

        // TODO: in future, need to keep track of committed orders also
        deposits[_offramper][_token] = currentDeposit - _amount;
        // TODO - Emit event
    }

    // Return deposit to escrowed funds
    function uncommitDeposit(address _offramper, address _token, uint256 _amount) external onlyOwner nonReentrant {
        // check if there are any orders pending
        // for now, not making this external
        // TODO: in future, need to keep track of committed orders also
        if (_token == address(0)) revert ZekeErrors.ZeroAddress();
        if (_offramper == address(0)) revert ZekeErrors.ZeroAddress();
        if (_amount == 0) revert ZekeErrors.ZeroUint();

        deposits[_offramper][_token] += _amount;
        // TODO - Emit event
    }
}