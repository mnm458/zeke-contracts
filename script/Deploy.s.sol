// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.24;

import { Script, console } from "forge-std/Script.sol";
import { PaypalVerifier } from "../src/Verifier.sol";
import { Ramp } from "../src/Ramp.sol";
import { TokenAndFeed } from "../src/Interfaces.sol";

contract DeployScript is Script {
    function run() public {
        // DEPLOYMENT PARAMS
        address rampOwner = vm.envAddress("RAMP_OWNER");
        TokenAndFeed[] memory tokenAndFeeds = new TokenAndFeed[](2);
        // usdc - base sepolia
        tokenAndFeeds[0] = TokenAndFeed({
            token: 0x036CbD53842c5426634e7929541eC2318f3dCF7e,
            feed: 0xd30e2101a97dcbAeBCBC04F14C3f624E67A35165
        });
        // usdt - base sepolia
        tokenAndFeeds[1] = TokenAndFeed({
            token: 0xaA8E23Fb1079EA71e0a56F48a2aA51851D8433D0,
            feed: 0x3ec8593F930EA45ea58c968260e6e9FF53FC934f
        });

        // DEPLOYMENT SCRIPT
        console.log("Deploying Verifier contract");
        uint256 deployerPrivateKey = vm.envUint("PRIV_KEY");
        vm.startBroadcast(deployerPrivateKey);
        address[] memory verifiers = new address[](2);
        PaypalVerifier verifier = new PaypalVerifier(verifiers);
        Ramp ramp = new Ramp(address(verifier), rampOwner, new TokenAndFeed[](0));
        vm.stopBroadcast();
        console.log("Deployed Test contract to ", address(verifier));
        console.log("Deployed Ramp contract to ", address(ramp));
    }
}
