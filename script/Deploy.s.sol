// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.24;

import { Script, console } from "forge-std/Script.sol";
import { Verifier } from "../src/Verifier.sol";
import { EmailVerifier } from "../src/verifiers/EmailVerifier.sol";
import { Ramp } from "../src/Ramp.sol";
import { TokenAndFeed } from "../src/Interfaces.sol";
import { ConstructorArgs } from "./ConstructorArgs.sol";

contract DeployScript is Script, ConstructorArgs {
    function run() public {
        // DEPLOYMENT PARAMS
        address rampOwner = vm.envAddress("RAMP_OWNER");
        uint256 chainId = vm.envUint("CHAIN_ID");
        TokenAndFeed[] memory tokenAndFeeds = tokenAndFeeds[chainId];

        // DEPLOYMENT SCRIPT
        console.log("Deploying Zeke contracts");
        uint256 deployerPrivateKey = vm.envUint("PRIV_KEY");
        vm.startBroadcast(deployerPrivateKey);
        EmailVerifier emailVerifier = new EmailVerifier();
        address[] memory verifiers = new address[](1);
        Verifier verifier = new Verifier(verifiers);
        Ramp ramp = new Ramp(rampOwner, address(verifier), ccipRouterAddress[chainId], tokenAndFeeds);
        vm.stopBroadcast();

        console.log("Deployed EmailVerifier contract to ", address(emailVerifier));
        console.log("Deployed Verifier contract to ", address(verifier));
        console.log("Deployed Ramp contract to ", address(ramp));
    }
}
