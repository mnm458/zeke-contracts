// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.24;

import { Script, console } from "forge-std/Script.sol";
import { PaypalVerifier } from "../src/Verifier.sol";
import { Ramp } from "../src/Ramp.sol";
import { TokenAndFeed } from "../src/Interfaces.sol";

contract DeployScript is Script {
    function run() public {
        // DEPLOYMENT SCRIPT
        console.log("Deploying Verifier contract");
        uint256 deployerPrivateKey = vm.envUint("PRIV_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address[] memory verifiers = new address[](2);
        PaypalVerifier verifier = new PaypalVerifier(verifiers);
        address mockSender = 0xC32e0d89e25222ABb4d2d68755baBF5aA6648F15;
        Ramp ramp = new Ramp(address(verifier), mockSender, new TokenAndFeed[](0));

        vm.stopBroadcast();
        console.log("Deployed Test contract to ", address(verifier));
        console.log("Deployed Ramp contract to ", address(ramp));
    }
}
