// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { TestBase } from './TestBase.sol';
import { Ramp } from '../src/Ramp.sol';
import { Verifier } from '../src/Verifier.sol';
import { EmailVerifier } from "../src/verifiers/EmailVerifier.sol";
import { ITokenManager, IEscrowManager, IOrderManager, IUserManager, IVerifier, IRamp, Order, TokenAndFeed, OrderStatus } from "../src/Interfaces.sol";
import { ZekeErrors } from '../src/libraries/ZekeErrors.sol';

import { ConstructorArgs } from "../script/ConstructorArgs.sol";
import { console } from "forge-std/Test.sol";

contract RampBaseForkTest2 is TestBase {
    IRamp ramp = IRamp(0x3964F59949364488F740AA18eD41d3127cB0a5C3);

    function setUp() public {}

    function test_deploy() public {
        vm.prank(DEPLOYER);
        uint256 orderId = 1;
        bytes memory proof = hex"00000000000000000000000000000000000000000000000000000000000002e000000000000000000000000000000000000000000000000000000000000003c0000000000000000000000000000000000000000000000000000000000000056000000000000000000000000000000000000000000000000000000000000008800000000000000000000000000000000000000000000000000000000000000a202a9d25016ae279b7759c0a5ce8bb081712938be5788ba6a449c12fc41b22978c1b11f22cf91851e578b81cafef16512fb5b65332cfa0907aa8b8c65e11df74161903cc1eaa22debf555e60e1b4a551d29793dd5d1b1566cc50d25a7c5af3ee5a154c7734ef63117bc58ed3e977c3610ccdf3bae59da34f8080e8ee79b88618e42a6de71759f9d7882fb84bb1bfedd810f0de0a094b98476e8292b75a4d8765b80530c6348baeb1e73f91bafaba2109cc70927055ba0d573bd3561b04a2de531e042774e9a0edb29483a7bad718be388b368ab23c72214a06174766d1d4fea5632218c162093db1edde06f8a75e709e7653d272a5239e9eadf582a3858aabc3840557ce6a3e5f8c671ba7c5d174c4d63f3368c0e3c279a2e2cd3f5d8378bf26fe0d6dcb6b2403b0a0110761bfd0e55ba4e318cab8c344fc5b7d366492cd5831792c6b58f57c1a17d7a47fb41efd7a0c5a447ac3337210e40a0fcd8c93b44710b90b5d24a80fd21dd7ef241f6241a39f18a50955f08889a6e17f91a0a7a8cadc0c00000000000000000000000000000000000000000000000000000000000003e8000000000000000000000000000000000000000000000000000000006636537a135b63b257a914f172befc9f9fd4fb3c04b57e3a42feb8696d4384d9fc4b4ad1110f942a3846bc8d6f8a5ccec234ec1777641961eea6a93e20a5bf2125481ca70802277b70465ba2ec785cec192c72b2fbd1287863f4595b06f4c3c471b789e00000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000063033f5170fec40de6810999d4c38cebe7b3527e81063d29545e58582e40152af13a8943ed618905a4f604eef5928330b603bf3e1ddb583fb53c6dca0e7a74b8a0f2871942324653c3bde5315f69f3d30833eee5c0f5cc3786cee28483820241e1dc9b5881d71524577435fb500cc35f50655baebfcf52215e255e75f36bb90b80794a0b549949abd8da35ae436cf2e40625747848c10010d6e3bb4b3255730002a8f12c79da272668d7b9a079993450d78e1b3091a1f5dead9cbbe6bf34dfe552fc503b26b06753646805434da954cedd8bf18b0fb46dd07b18111d89252ec42201cf5b52902e308601376f4eaf6340b159504ac82b27ff24708f0cabb9fbbcf14c73f5815218a2af908d6f2e840ab93d75499277139c66fd948fb1c4c2e575306bbd28dbbeabe8738f301a255511468a011e26e9034fd2a609790232565e52d03d7df5081317ae54604e3935edb0823df8d2a7bd6f254090b0b85bd7c6580ce000fabdb395115b8ce5f6edc7d6318ecce7757e6a9f4d706a0751555e9a4503c000000000000000000000000000000000000000000000000000000000000000610b23350f9371e15418eff824fadd6afb116e9ef93b56b554f469e132da6db972a764f569b705bcd884d3756103f7f0a1c07dc50bd427414ee7577e1317a38a50e46003f1fdb1977eddcd3b28ba815fe8f93c1f68667d88cd37ab6b240b2e4231fe02234ef24e6f1a04e45b700d587685fc3780711b448210ff0bd3a87cd41602e7b102824f9639fcbee88a5d4e772f5da4c92eeda141742a26c8902ff4617611674ab863480d231b7928843fe62092e14fb0197a1d0331c55ca81c0276b95fe164add516d692ae93422912b699f3c14c018e3a5861413357c9542e7f7bc403003a735d8e76eab1eb113fd8bd1846ce422f60450da498d10f03d7d01c13f96ea2905f911297f0b21570d18cc17bab9d874731ef17b609b15669e0cc7f90a74c02b5737ababfb97b714b123e97621fd5dbf187f8d5c241bafb08de5abecaa95b6196d97cc12b1323a625cae272222c7aff48a7d1bbba89ff6e43f677daa85f3371922b453d330324c54440cbd77ab85a37e2b16abc6a29073383c77bb6a094dfe0e0e720b28583c00c26b5b882fef40765a82f239ac32032322ba0d37bcd162552605e2831b8dc966a2cd342694a49c09a8d07e746c66cd3e976f101dbc6d9fd7276fafbc527eaaf6a808beb637bad718086702be25df02210f99e94759482fe413445e7c357ec56abb9b4e8123cf178cae26a602377874fcb850c4b2852ef2011172fe562db68211d98fe2b7fab950c3a4e3ac7d448a7e18e001b5e1d44ae86e29c52bca0c5e51e0ad1eac12955f4bf29057b98207b94349ff1eab39ef69b6c91af532da69e45664320021a62070abc254594c667f3c61964337a49170e0464e20fff82ccb7ef83432f93adf9a85fb5a262387a8c5585306ff38c04939ec4ef62f3c891eadaeb1692f48184f0d5abd9d3a96ad83dac5960af1fdcec6635781ae1331a3edb1b5cfbd56af0fac0225858b061431e7331fd7311a90402606ee6dd60aef8d78ad3d043ab82f49f8c014dcb509902e4afe6351533153c8f0a13c4e6b0bdb31692b971b9455efa14bf508d13176ed808a6d700649d8faa3ee2f44170d0000000000000000000000000000000000000000000000000000000000000006295286efbdf819b9b9541542f81c8a51edbb4f1ca2ad0d2a5634e830b7c3e362035cb4c91669a1e1e40ce3ed4e359dc9a5e816021caf3d5d52532fcf8cff788d231c132cde19dd136488742fa80c7f21cfea3ff4d76226ed5122967aeab3c25322d153664e802f78aad5a8eba006a2020a2a14f8c1f565208cb1fbf1422a8fd622542b19c6b7bb253eb977fafd97941f80e931e634bfe4776995bbb86e8ce46a00428267caf3d15876914c1a24bda8a1f782440e968ae6b1bd543fbf284ef8ef28867e92f3d8b088a9e635a7ea8972c746b1fda1100d8369b6799cdea1cd789c0ef08fff4cbf10068497dd6320aa1240392e0c31c1c03671fb1b0843f6364343170e2e137714b8f24ed1a0a9a9728501187e97aa6f82111707b9044c4de604de20f5f9d5b85b6cb0c8be08ffa521e9db07f460117f10c09fab50362dab76081424c605a25c2eb388a2dd518ae331ef81ccde0cc10f04fabec69b0eb891be8475027431df18edd644688262d13e974d97379961a4c9b46976a32b67a2628b1c1900000000000000000000000000000000000000000000000000000000000000062c6b58f57c1a17d7a47fb41efd7a0c5a447ac3337210e40a0fcd8c93b44710b906ba509f3604cdf42a04fe143130937255dd343f2b84854a092a7b10b38d5a7f06ba509f3604cdf42a04fe143130937255dd343f2b84854a092a7b10b38d5a7f16ccbfc9ec4ebdabc31779c7e5b8c85c0205c8cd85986b38f364f4e3211c852b16ccbfc9ec4ebdabc31779c7e5b8c85c0205c8cd85986b38f364f4e3211c852b12fc450e4d218a8ef622f54bd565319b6ecd79066acb59050af0c9937ea860e312fc450e4d218a8ef622f54bd565319b6ecd79066acb59050af0c9937ea860e3263d814e36a95edc6bc721710fba616ff220a0cf7d0b7a2b215699bf77ed5c3a263d814e36a95edc6bc721710fba616ff220a0cf7d0b7a2b215699bf77ed5c3a2348e06147363d4c76d4102bd1a05bb76c8c1120a0fd819bed4dcba0819712402348e06147363d4c76d4102bd1a05bb76c8c1120a0fd819bed4dcba0819712400d6dcb6b2403b0a0110761bfd0e55ba4e318cab8c344fc5b7d366492cd583179";
        ramp.completeOrder(orderId, proof);
    }
}
