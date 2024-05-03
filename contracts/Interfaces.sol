// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

enum OrderStatus { OPEN, COMMITTED, CLOSED }

struct Order {
    // Slot - 20 + 4 + 8
    address token; // 'token == address(0)' means order does not exist, we take care to ensure valid order cannot have token == address(0)
    uint32 commitmentExpiryTime;
    uint64 dstchainId;
    // Slot - 20 + 1
    address onramper;
    OrderStatus orderStatus;
    // 1 slot each
    address offramper;
    uint256 amount;
    int256 minFiatRate;
}

struct TokenAndFeed {
    address token; // ERC20 token
    address feed; // Chainlink feed - https://docs.chain.link/data-feeds/price-feeds/addresses?network=base&page=1
}

/* -------------------- Managers -------------------- */
interface IOrderManager {
    function getOrder(bytes32 orderId) external view returns (Order memory);

    function doesOrderExist(bytes32 orderId) external view returns (bool);

    function addOrder(
        address _onramper, 
        address _token, 
        uint256 _amount,
        int256 _minFiatRate,
        uint64 _dstchainId
    ) external returns (bytes32);

    function commitOrder(address _offramper, bytes32 _orderId) external;

    function uncommitOrder(bytes32 _orderId) external;

    function completeOrder(bytes32 _orderId, uint256 nullifier) external;

    function checkNullifier(uint256 nullifier) external view returns (bool);

    function checkId(
        bytes32 _orderId,
        uint256 _amount,
        uint256 _timestamp
    ) external view returns (bool);
}

interface IEscrowManager {
    function getDeposit(address _offramper, address _token) external view returns (uint256);
    function deposit(address _offramper, address _token, uint256 _amount) external;
    function commitDeposit(address _offramper, address _token, uint256 _amount) external;
    function uncommitDeposit(address _offramper, address _token, uint256 _amount) external;
}

interface ITokenManager {
    function tokenFeed(address _token) external view returns (address);

    function isMinFiatRateValid(int256 _minFiatRate, address _token) external view returns (bool);

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
