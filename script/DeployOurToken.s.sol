// SPDX-License-Identifier: MIT
// Declares that this code is open-source under the MIT license.
// This is required by Solidity tools and good practice for any public contract.

pragma solidity ^0.8.26;

// Tells the compiler which version of Solidity to use.
// The `^` means "this version or any newer compatible version".
// 0.8.x includes built-in overflow/underflow protection — no need for SafeMath.

import {Script} from "forge-std/Script.sol";
import {OurToken} from "../src/OurToken.sol";

contract DeployOurToken is Script {
    uint256 public constant INITIAL_SUPPLY = 1000 * 10 ** 18; // 1000 tokens with 18 decimals

    function run() external {
        vm.startBroadcast();
        OurToken token = new OurToken(INITIAL_SUPPLY);
        vm.stopBroadcast();
    }
}
