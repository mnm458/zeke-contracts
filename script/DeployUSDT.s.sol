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
        IRamp ramp = IRamp(0xcc6F072eC6ED45Dbdb722728d0905A0930F63889);
        address rampOwner = vm.envAddress("RAMP_OWNER");

        // DEPLOYMENT SCRIPT
        console.log("Deploying USDT contracts");
        uint256 deployerPrivateKey = vm.envUint("PRIV_KEY");
        vm.startBroadcast(deployerPrivateKey);
        USDT usdt = new USDT(rampOwner);
        TokenAndFeed[] memory tokenAndFeed = new TokenAndFeed[](1);
        tokenAndFeed[0] = TokenAndFeed({
            token: address(usdt),
            feed: 0xd30e2101a97dcbAeBCBC04F14C3f624E67A35165
        });        
        ramp.addValidTokens(tokenAndFeed);
        vm.stopBroadcast();
        console.log("Deployed USDT contract to ", address(usdt));
    }
}
