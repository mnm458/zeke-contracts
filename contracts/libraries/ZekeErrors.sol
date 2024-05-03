// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

library ZekeErrors {
    // General
    error ZeroAddress();
    error ZeroUint();

    // UserManager.sol
    error UserAlreadyRegistered();


    error TokenNotAccepted();
    error NoCurrentOrderCommitment();
    error CurrentCommitment();
    error OrderCommitmentExpired();
    error OrderProofInvalid();
    error OrderNotFound();
    error OrderOpen();
    error OrderClosed();
    error NotCurrentCommittedOfframper();

    error InsufficientEscrowedFunds();
    error MinFiatRateInvalid();
    error MinFiatRateNotAccepted();
}