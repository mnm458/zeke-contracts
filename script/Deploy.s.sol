// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.24;

import { Script, console } from "forge-std/Script.sol";
import { Verifier } from "../src/Verifier.sol";
import { EmailVerifier } from "../src/verifiers/EmailVerifier.sol";
import { MDV_512 } from "../src/verifiers/MDV_512.sol";
import { MDV_1024 } from "../src/verifiers/MDV_1024.sol";
import { MDV_2048 } from "../src/verifiers/MDV_2048.sol";
import { MDV_4096 } from "../src/verifiers/MDV_4096.sol";

import { Ramp } from "../src/Ramp.sol";
import { TokenAndFeed } from "../src/Interfaces.sol";
import { ConstructorArgs } from "./ConstructorArgs.sol";

contract DeployScript is Script, ConstructorArgs {
    function run() public {
        // DEPLOYMENT PARAMSA
        address rampOwner = vm.envAddress("RAMP_OWNER");
        uint256 chainId = vm.envUint("CHAIN_ID");
        TokenAndFeed[] memory tokenAndFeeds = tokenAndFeeds[chainId];

        // DEPLOYMENT SCRIPT
        console.log("Deploying Zeke contracts");
        uint256 deployerPrivateKey = vm.envUint("PRIV_KEY");
        vm.startBroadcast(deployerPrivateKey);

        EmailVerifier emailVerifier = new EmailVerifier();
        MDV_512 mdv512 = new MDV_512();
        MDV_1024 mdv1024 = new MDV_1024();
        MDV_2048 mdv2048 = new MDV_2048();
        MDV_4096 mdv4096 = new MDV_4096();
        address[] memory verifiers = new address[](5);
        verifiers[0] = address(emailVerifier);
        verifiers[1] = address(mdv512);
        verifiers[2] = address(mdv1024);
        verifiers[3] = address(mdv2048);
        verifiers[4] = address(mdv4096);
        Verifier verifier = new Verifier(verifiers);

        Ramp ramp = new Ramp(rampOwner, address(verifier), ccipRouterAddress[chainId], tokenAndFeeds);
        vm.stopBroadcast();

        console.log("Deployed EmailVerifier contract to ", address(emailVerifier));
        console.log("Deployed MDV_512 contract to ", address(mdv512));
        console.log("Deployed MDV_1024 contract to ", address(mdv1024));
        console.log("Deployed MDV_2048 contract to ", address(mdv2048));
        console.log("Deployed MDV_4096 contract to ", address(mdv4096));

        console.log("Deployed Verifier contract to ", address(verifier));
        console.log("Deployed Ramp contract to ", address(ramp));
    }
}
