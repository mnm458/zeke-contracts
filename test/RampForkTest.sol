// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

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
        vm.prank(DEPLOYER);
        
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
    }

    function test_AddValidTokens() public {
        vm.prank(DEPLOYER);
        TokenAndFeed[] memory tokenAndFeeds = new TokenAndFeed[](1);
        tokenAndFeeds[0] = TokenAndFeed({
            token: address(1),
            feed: address(1)
        });
        ramp.addValidTokens(tokenAndFeeds);
    }
}
