// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
// 0.8.x includes built-in overflow/underflow protection — no SafeMath needed.

import {Test} from "forge-std/Test.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";

/*
 * ─────────────────────────────────────────────────────────────
 *  OurTokenTest — Unit Tests for OurToken.sol
 * ─────────────────────────────────────────────────────────────
 *
 *  Uses Foundry's Test framework (forge-std).
 *  Each test follows the Arrange → Act → Assert pattern.
 *  setUp() runs automatically before every test function.
 * ─────────────────────────────────────────────────────────────
 */
contract OurTokenTest is Test {
    /* ─────────────────────────────────────────────
     * Contract Instances
     * ─────────────────────────────────────────────
     */
    OurToken public token;
    DeployOurToken public deployer;

    /* ─────────────────────────────────────────────
     * Test Actors
     * ─────────────────────────────────────────────
     * makeAddr() creates deterministic, labelled fake addresses.
     * These are used as stand-in wallets for test scenarios.
     */
    address bob = makeAddr("Bob");
    address alice = makeAddr("Alice");

    // The token balance transferred to Bob during setUp().
    // Uses `ether` units since OurToken also has 18 decimals.
    // 100 ether = 100 * 10**18 = 100 OT tokens.
    uint256 public constant STARTING_BALANCE = 100 ether;

    /* ─────────────────────────────────────────────
     * setUp()
     * ─────────────────────────────────────────────
     * Runs automatically before every test function.
     * Deploys a fresh OurToken and transfers STARTING_BALANCE
     * to Bob so tests have a funded actor to work with.
     */
    function setUp() public {
        // Deploy the token using the production deploy script
        // so tests reflect the same setup as a real deployment.
        deployer = new DeployOurToken();
        token = deployer.run();

        // Transfer tokens to Bob from the deployer (msg.sender).
        // vm.prank() makes the next call appear to come from msg.sender,
        // who holds the full initial supply after deployment.
        vm.prank(msg.sender);
        token.transfer(bob, STARTING_BALANCE);
    }

    /**
     * @dev Verifies that Bob's balance equals STARTING_BALANCE after setUp().
     *      Confirms the transfer in setUp() was executed correctly.
     */
    function testBobHasTokens() public view {
        assertEq(STARTING_BALANCE, token.balanceOf(bob), "Bob should have the initial balance");
    }
}
