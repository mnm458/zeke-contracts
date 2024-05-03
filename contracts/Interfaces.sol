// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

struct Order {
    uint120 creationTimestamp;
    uint120 offramperDeadline;
    uint16 status;
    address onramper;
    address offramper;
    address token;
    uint256 requestedAmount;
    uint256 minFiatAmount;
    uint256 intentId;
}

struct Deposit {
    uint256 creationTimestamp;
    address token;
    uint256 amount;
}

struct TokenAndFeed {
    address token; // ERC20 token
    address feed; // Chainlink feed - https://docs.chain.link/data-feeds/price-feeds/addresses?network=base&page=1
}

/* -------------------- Managers -------------------- */
interface IOrderManager {
    function addOrder(
        uint256 intentId,
        uint256 requestedAmount,
        uint256 minFiatAmount,
        address tokenAddress,
        address onramper
    ) external;

    function getOrder(uint256 intentId) external view returns (Order memory);

    function commitOrder(uint256 intentId, address offramper) external;

    function uncommitOrder(uint256 intentId) external;

    function completeOrder(uint256 intentId, uint256 nullifier) external;

    function checkNullifier(uint256 nullifier) external view returns (bool);

    function checkId(
        uint256 intentId,
        uint256 amount,
        uint256 timestamp
    ) external view returns (bool);
}

interface IEscrowManager {
    function getDepositID(
        address user,
        address token
    ) external view returns (bytes32);

    function createDeposit(
        address _token,
        uint256 _amount,
        address offramper
    ) external;

    function commitDeposit(bytes32 depositKey, uint256 _amount) external;

    function uncommitDeposit(bytes32 depositKey, uint256 _amount) external;

    function getDeposit(
        bytes32 _deposit
    ) external view returns (Deposit memory);
}

interface ITokenManager {
    function tokenFeed(address _token) external view returns (address);

    function addValidTokens(TokenAndFeed[] memory _tokenAndFeeds) external;

    function removeValidTokens(address[] memory _tokens) external;

    function isValidToken(address _token) external view returns (bool);
}

interface IUserManager {
    function registerUser(address _userAddress, uint256 _userId, string calldata email) external;

    function doesUserExist(address _userAddress) external view returns (bool);

    function compareUserId(address _userAddress, uint256 id) external view returns(bool);
}

/* -------------------- Verifiers -------------------- */
interface IMDV {
    function verifyProof(
        uint[2] calldata _pA,
        uint[2][2] calldata _pB,
        uint[2] calldata _pC,
        uint[2] calldata _pubSignals
    ) external view returns (bool);
}

interface IEmailVerifier {
    function verifyProof(
        uint[2] calldata _pA,
        uint[2][2] calldata _pB,
        uint[2] calldata _pC,
        uint[10] calldata _pubSignals
    ) external view returns (bool);
}

interface IOrderVerifier {
    function checkNullifier(uint256 nullifier) external view returns (bool);

    function checkId(
        uint256 intentId,
        uint256 onramper,
        uint256 offramper,
        uint256 amount,
        uint256 timestamp
    ) external view returns (bool);
}

interface IVerifier {
    /* This is to standardise future verifiers too */
    function verify(
        bytes calldata input
    ) external view returns (bool, bytes memory);
}
