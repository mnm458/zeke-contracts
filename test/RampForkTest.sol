// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { TestBase } from './TestBase.sol';
import { Ramp } from '../src/Ramp.sol';
import { Verifier } from '../src/Verifier.sol';
import { EmailVerifier } from "../src/verifiers/EmailVerifier.sol";
import { ITokenManager, IEscrowManager, IOrderManager, IUserManager, IVerifier, IRamp, Order, TokenAndFeed, OrderStatus } from "../src/Interfaces.sol";

import { ConstructorArgs } from "../script/ConstructorArgs.sol";
import { console } from "forge-std/Test.sol";

contract RampForkTest is TestBase {
    IRamp ramp;
    ITokenManager tokenManager;
    IEscrowManager escrowManager;
    IOrderManager orderManager;
    IUserManager userManager;

    address USDC = 0x036CbD53842c5426634e7929541eC2318f3dCF7e;

    function setUp() public {
        ConstructorArgs constructorArgs = new ConstructorArgs();
        // Unsure why syntax in deploy script is not allowed in test script
        TokenAndFeed[] memory tokenAndFeeds = new TokenAndFeed[](2);
        {
            (address token, address feed) = constructorArgs.tokenAndFeeds(block.chainid, 0);
            tokenAndFeeds[0] = TokenAndFeed(token, feed);
        }
        {
            (address token, address feed) = constructorArgs.tokenAndFeeds(block.chainid, 1);
            tokenAndFeeds[1] = TokenAndFeed(token, feed);
        }
        EmailVerifier emailVerifier = new EmailVerifier();    
        address[] memory verifiers = new address[](1);
        verifiers[0] = address(emailVerifier);
        Verifier verifier = new Verifier(verifiers);
        ramp = new Ramp(DEPLOYER, address(verifier), constructorArgs.ccipRouterAddress(block.chainid), tokenAndFeeds);    
    }

    function test_deploy() public {
        assertNotEq(address(ramp.tokenManager()), address(0));
        assertNotEq(address(ramp.escrowManager()), address(0));
        assertNotEq(address(ramp.orderManager()), address(0));
        assertNotEq(address(ramp.userManager()), address(0));
        assertNotEq(address(ramp.verifier()), address(0));
    }

    function test_ManagerContractsDirectlyCalled_ShouldRevert() public {
        vm.startPrank(DEPLOYER);
        
        TokenAndFeed[] memory tokenAndFeeds = new TokenAndFeed[](1);
        tokenAndFeeds[0] = TokenAndFeed(address(1), address(1));
        vm.expectRevert();
        tokenManager.addValidTokens(tokenAndFeeds);
        vm.expectRevert();
        tokenManager.removeValidTokens(new address[](1));
        vm.expectRevert();
        userManager.registerUser(address(1), 1, "email");

        vm.expectRevert();
        orderManager.addOrder(address(1), address(1), 1, 1, 1);

        vm.expectRevert();
        orderManager.commitOrder(address(1), bytes32(0));

        vm.expectRevert();
        orderManager.uncommitOrder(bytes32(0));

        vm.expectRevert();
        orderManager.completeOrder(bytes32(0), 1);

        vm.expectRevert();
        escrowManager.deposit(address(1), address(1), 1);

        vm.expectRevert();
        escrowManager.withdraw(address(1), address(1), 1);

        vm.expectRevert();
        escrowManager.commitDeposit(address(1), address(1), 1);

        vm.expectRevert();
        escrowManager.uncommitDeposit(address(1), address(1), 1);

        vm.stopPrank();
    }

    function test_AddValidTokens() public {
        TokenAndFeed[] memory tokenAndFeeds = new TokenAndFeed[](1);
        tokenAndFeeds[0] = TokenAndFeed({
            token: address(1),
            feed: address(1)
        });
        vm.prank(DEPLOYER);
        ramp.addValidTokens(tokenAndFeeds);
    }

    function test_AddOrder() public {
        vm.prank(USER);
        // Add order for USDC on Base testnet
        ramp.addOrder(address(1), USDC, 1, 1e8, 1);
    }

    function test_deposit() public {
        vm.startPrank(USER);
        deal(USDC, USER, 1e18);
        IERC20(USDC).approve(address(ramp), 1e18);
        // Add order for USDC on Base testnet
        ramp.deposit(USDC, 1);
        vm.stopPrank();
    }

    function test_commitOrder() public {
        vm.prank(USER);
        // Add order for USDC on Base testnet
        bytes32 orderId = ramp.addOrder(address(1), USDC, 1, 1e8, 1);

        vm.startPrank(USER_2);
        deal(USDC, USER_2, 1e18);
        IERC20(USDC).approve(address(ramp), 1e18);
        // Add order for USDC on Base testnet
        ramp.deposit(USDC, 1);
        ramp.commitOrder(orderId, 1e8);
    }
}
