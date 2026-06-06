// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
// 0.8.x includes built-in overflow/underflow protection — no SafeMath needed.

import {Test, console} from "forge-std/Test.sol";
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
    // 1000 ether = 1000 * 10**18 = 1000 OurToken tokens.
    uint256 public constant STARTING_BALANCE = 100 ether;

    /*
    * ─────────────────────────────────────────────
    * setUp()
    * ─────────────────────────────────────────────
    * Runs automatically before every test function.
    * Deploys a fresh OurToken instance and prepares test actors
    * by funding Bob with tokens for testing transfers and approvals.
    */
    function setUp() public {
        // Deploy the token using the production deploy script
        // so tests reflect the same deployment flow as production.
        deployer = new DeployOurToken();
        token = deployer.run();

        // The full initial token supply is minted to the deployer, which in this
        // test setup is the test contract itself. To give Bob tokens for testing,
        // we transfer a portion of the supply from the deployer account using
        // vm.prank to impersonate the token holder.
        vm.prank(msg.sender);
        token.transfer(bob, STARTING_BALANCE);
    }

    /**
     * @dev Verifies that Bob's balance equals STARTING_BALANCE after setUp().
     *      Confirms the transfer in setUp() was executed correctly.
     */
    function testBobHasTokens() public view {
        // Bob should have 100 tokens (100 * 10^18 units) after setUp() transfers them from the deployer.
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

    function testInitialSupplyMinted() public view {
        assertEq(token.totalSupply(), deployer.INITIAL_SUPPLY(), "Total supply should equal initial supply");
    }

    function testDeployerReceivedInitialSupply() public view {
        assertEq(
            token.balanceOf(msg.sender),
            deployer.INITIAL_SUPPLY() - STARTING_BALANCE,
            "Deployer should own remaining supply"
        );
    }

    function testTransferWorks() public {
        uint256 amount = 25 ether;

        vm.prank(bob);
        token.transfer(alice, amount);

        assertEq(token.balanceOf(alice), amount);
        assertEq(token.balanceOf(bob), STARTING_BALANCE - amount);
    }

    function testTransferEntireBalance() public {
        vm.prank(bob);
        token.transfer(alice, STARTING_BALANCE);

        assertEq(token.balanceOf(bob), 0);
        assertEq(token.balanceOf(alice), STARTING_BALANCE);
    }

    function testTransferZeroTokens() public {
        vm.prank(bob);
        token.transfer(alice, 0);

        assertEq(token.balanceOf(bob), STARTING_BALANCE);
        assertEq(token.balanceOf(alice), 0);
    }

    function testTransferFailsWhenBalanceInsufficient() public {
        vm.prank(alice);

        vm.expectRevert();

        token.transfer(bob, 1);
    }

    function testAllowanceDecreasesAfterTransferFrom() public {
        uint256 allowance = 1000;
        uint256 amount = 400;

        vm.prank(bob);
        token.approve(alice, allowance);

        vm.prank(alice);
        token.transferFrom(bob, alice, amount);

        assertEq(token.allowance(bob, alice), allowance - amount);
    }

    function testTransferFromFailsWhenExceedingAllowance() public {
        vm.prank(bob);
        token.approve(alice, 100);

        vm.prank(alice);

        vm.expectRevert();

        token.transferFrom(bob, alice, 101);
    }

    function testTransferFromFailsWithoutApproval() public {
        vm.prank(alice);

        vm.expectRevert();

        token.transferFrom(bob, alice, 1);
    }

    function testMultipleTransferFromsConsumeAllowance() public {
        vm.prank(bob);
        token.approve(alice, 1000);

        vm.startPrank(alice);

        token.transferFrom(bob, alice, 300);
        token.transferFrom(bob, alice, 200);

        vm.stopPrank();

        assertEq(token.balanceOf(alice), 500);
        assertEq(token.allowance(bob, alice), 500);
    }
}
