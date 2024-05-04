// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

library ZekeErrors {
    // General
    error ZeroAddress();
    error ZeroUint();

    // UserManager.sol
    error UserAlreadyRegistered();
    error UserNotRegistered();

    // OrderManager.sol
    error GeneratedOrderIdTooBig();

    // EscrowManager.sol
    error InsufficientEscrowedFunds();

    // Ramp.sol
    error TokenNotAccepted();
    error OrderNotFound();
    error OrderClosed();
    error CurrentCommitment();
    error NoCurrentOrderCommitment();
    error OrderCommitmentExpired();
    error OrderProofInvalid();
    error OrderOpen();
    error NotCurrentCommittedOfframper();
    error MinFiatRateInvalid();
    error MinFiatRateNotAccepted();

    // Ramp.completeOrder _pubSignals validation
    error IncorrectOfframper();
    error IncorrectOnramper();
    error NullifierConsumed();
    error IncorrectOrder();
    error ActualAmountInsufficient();
}