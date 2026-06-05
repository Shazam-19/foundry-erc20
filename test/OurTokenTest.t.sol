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

    /**
     * @notice Verifies that ERC20 allowances enable delegated token transfers.
     * @dev
     * Workflow:
     * 1. Bob approves Alice to spend tokens on his behalf.
     * 2. Alice transfers a portion of Bob's tokens using `transferFrom`.
     * 3. The test confirms that balances are updated correctly.
     *
     * This demonstrates the standard ERC20 approval and allowance mechanism,
     * where one account can authorize another account to spend tokens.
     */
    function testAllowancesWorks() public {
        uint256 inititalAllowance = 1000;

        // Bob grants Alice permission to spend up to 1,000 of his tokens.
        vm.prank(bob);
        token.approve(alice, inititalAllowance);

        uint256 transferAmount = 500;

        // Alice spends part of Bob's approved allowance.
        vm.prank(alice);
        token.transferFrom(bob, alice, transferAmount);

        /*
        * We are testing the ERC20 allowance mechanism.
        *
        * In this test, Bob has previously called `approve(alice, amount)`,
        * which gives Alice permission to spend some of Bob's tokens.
        *
        * It may seem like calling:
        *
        *     token.transfer(alice, transferAmount);
        *
        * would move tokens from Bob to Alice, but that is not how
        * ERC20 `transfer()` works.
        *
        * The `transfer()` function always sends tokens from the account
        * making the call (`msg.sender`) to the recipient.
        *
        * Without a prank, `msg.sender` would be the test contract itself
        * (`address(this)`), so the transfer would attempt to move tokens
        * owned by the test contract, not tokens owned by Bob.
        *
        * Even if we used:
        *
        *     vm.prank(alice);
        *     token.transfer(alice, transferAmount);
        *
        * the transfer would still send tokens from Alice's own balance,
        * because Alice would now be `msg.sender`.
        *
        * In both cases, Bob's approved allowance is never checked or used,
        * meaning we would not actually be testing the approval mechanism.
        *
        * To test allowances correctly, Alice must act as the caller and
        * explicitly specify Bob as the source of the tokens:
        *
        *     vm.prank(alice);
        *     token.transferFrom(bob, alice, transferAmount);
        *
        * `transferFrom()` is the ERC20 function designed for delegated
        * transfers. It checks that:
        *
        * 1. Bob has enough tokens.
        * 2. Bob approved Alice to spend them.
        * 3. The allowance is reduced after the transfer.
        *
        * This is why `transferFrom()` is required here instead of
        * `transfer()`.
        */
        // token.transfer(alice, transferAmount);

        // Verify that Alice received the transferred tokens.
        assertEq(token.balanceOf(alice), transferAmount, "Alice should have received the transferred tokens");

        // Verify that Bob's balance decreased by the transferred amount.
        assertEq(
            token.balanceOf(bob),
            STARTING_BALANCE - transferAmount,
            "Bob's balance should be reduced by the transferred amount"
        );
    }

    /**
     * @notice Verifies that the entire initial supply is minted to the deployer.
     * @dev The constructor mints all tokens to msg.sender.
     */
    function testConstructorMintsSupplyToDeployer() public {
        OurToken freshToken = new OurToken(STARTING_BALANCE);

        assertEq(freshToken.balanceOf(address(this)), STARTING_BALANCE);
    }
}
