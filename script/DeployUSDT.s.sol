// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.24;

import { Script, console } from "forge-std/Script.sol";
import { Verifier } from "../src/Verifier.sol";
import { EmailVerifier } from "../src/verifiers/EmailVerifier.sol";
import { Ramp } from "../src/Ramp.sol";
import { TokenAndFeed, IRamp } from "../src/Interfaces.sol";
import { ConstructorArgs } from "./ConstructorArgs.sol";
import { USDT } from "../src/USDT.sol";

// Quick script to deploy own USDT contract on Base Sepolia
contract DeployUSDTScript is Script, ConstructorArgs {
    function run() public {
        // Ramp address
        IRamp ramp = IRamp(0x7a4137fC69d2460B52c0eb85BC1B9B6aE5e781f6);
        address rampOwner = vm.envAddress("RAMP_OWNER");

        // DEPLOYMENT SCRIPT
        console.log("Deploying USDT contracts");
        uint256 deployerPrivateKey = vm.envUint("PRIV_KEY");
        vm.startBroadcast(deployerPrivateKey);
        // USDT usdt = new USDT(rampOwner);
        TokenAndFeed[] memory tokenAndFeed = new TokenAndFeed[](1);
        tokenAndFeed[0] = TokenAndFeed({
            token: 0xb736F7EFd4e7823250e063283d2AB6ED2df84E34,
            feed: 0xd30e2101a97dcbAeBCBC04F14C3f624E67A35165
        });        
        ramp.addValidTokens(tokenAndFeed);
        vm.stopBroadcast();
        // console.log("Deployed USDT contract to ", address(usdt));
    }
}
