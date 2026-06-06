// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
// 0.8.x includes built-in overflow/underflow protection — no SafeMath needed.

import {Script} from "forge-std/Script.sol";
import {OurToken} from "../src/OurToken.sol";

/*
 * DeployOurToken
 *
 * Deployment script for OurToken.sol.
 * Deploys a new OurToken contract with a fixed initial supply
 * and returns the deployed instance for use in tests and other scripts.
 */
contract DeployOurToken is Script {
    // Total token supply minted to the deployer on deployment.
    // Expressed in the smallest unit (18 decimals, same as ETH wei).
    //
    // Example:
    //   1000 * 10**18 = 1000000000000000000000 units internally
    //   → displayed as 1000 OurToken in wallets and front-ends.
    uint256 public constant INITIAL_SUPPLY = 1000 ether;

    /**
     * @notice Deploys OurToken with the fixed initial supply.
     * @dev    Foundry's run() is the default entrypoint when executing
     *         this script with `forge script`. Wraps deployment in
     *         vm.startBroadcast() so Foundry submits it as a real
     *         on-chain transaction rather than a local simulation.
     *
     * @return token The deployed OurToken contract instance.
     */
    function run() external returns (OurToken) {
        vm.startBroadcast();
        OurToken token = new OurToken(INITIAL_SUPPLY);
        vm.stopBroadcast();
        return token;
    }
}
