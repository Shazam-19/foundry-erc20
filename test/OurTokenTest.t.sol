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
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

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

    /**
     * @dev Verifies that the total token supply equals the initial supply
     *      defined in the deploy script after deployment.
     */
    function testInitialSupplyMinted() public view {
        assertEq(token.totalSupply(), deployer.INITIAL_SUPPLY(), "Total supply should equal initial supply");
    }

    /**
     * @dev Verifies that the deployer holds the remaining supply after
     *      transferring STARTING_BALANCE to Bob in setUp().
     *
     *      Example:
     *        INITIAL_SUPPLY   = 1000 OT
     *        STARTING_BALANCE = 100 OT (sent to Bob)
     *        Deployer balance = 1000 - 100 = 900 OT
     */
    function testDeployerReceivedInitialSupply() public view {
        assertEq(
            token.balanceOf(msg.sender),
            deployer.INITIAL_SUPPLY() - STARTING_BALANCE,
            "Deployer should own remaining supply"
        );
    }

    /**
     * @dev Verifies that a standard transfer correctly moves tokens
     *      from the sender to the recipient and updates both balances.
     *
     *      Example:
     *        Bob balance before:   100 OT
     *        Transfer amount:       25 OT
     *        Bob balance after:     75 OT
     *        Alice balance after:   25 OT
     */
    function testTransferWorks() public {
        uint256 amount = 25 ether;

        vm.prank(bob);
        token.transfer(alice, amount);

        assertEq(token.balanceOf(alice), amount);
        assertEq(token.balanceOf(bob), STARTING_BALANCE - amount);
    }

    /**
     * @dev Verifies that transferring the entire balance leaves the
     *      sender with zero tokens and the recipient with the full amount.
     */
    function testTransferEntireBalance() public {
        vm.prank(bob);
        token.transfer(alice, STARTING_BALANCE);

        assertEq(token.balanceOf(bob), 0);
        assertEq(token.balanceOf(alice), STARTING_BALANCE);
    }

    /**
     * @dev Verifies that transferring zero tokens is valid and does not
     *      change any balances. ERC20 allows zero-value transfers.
     */
    function testTransferZeroTokens() public {
        vm.prank(bob);
        token.transfer(alice, 0);

        assertEq(token.balanceOf(bob), STARTING_BALANCE);
        assertEq(token.balanceOf(alice), 0);
    }

    /**
     * @dev Verifies that a transfer reverts when the sender does not
     *      have enough tokens to cover the amount.
     *
     *      Alice has 0 tokens — attempting to transfer 1 token should revert.
     */
    function testTransferFailsWhenBalanceInsufficient() public {
        vm.prank(alice);

        // Expect the next call to revert with any reason.
        vm.expectRevert();

        token.transfer(bob, 1);
    }

    /**
     * @dev Verifies that the allowance decreases by the transferred amount
     *      after a successful transferFrom().
     *
     *      Example:
     *        Bob approves Alice for 1000 OT.
     *        Alice spends 400 OT via transferFrom().
     *        Remaining allowance = 1000 - 400 = 600 OT.
     */
    function testAllowanceDecreasesAfterTransferFrom() public {
        uint256 allowance = 1000;
        uint256 amount = 400;

        // Bob grants Alice permission to spend up to 1000 tokens on his behalf.
        vm.prank(bob);
        token.approve(alice, allowance);

        // Alice spends 400 of Bob's tokens using the granted allowance.
        vm.prank(alice);
        token.transferFrom(bob, alice, amount);

        assertEq(token.allowance(bob, alice), allowance - amount);
    }

    /**
     * @dev Verifies that transferFrom() reverts when the spend amount
     *      exceeds the approved allowance.
     *
     *      Example:
     *        Bob approves Alice for 100 OT.
     *        Alice attempts to spend 101 OT → should revert.
     */
    function testTransferFromFailsWhenExceedingAllowance() public {
        vm.prank(bob);
        token.approve(alice, 100);

        vm.prank(alice);

        // Expect the next call to revert — allowance is 100, spend is 101.
        vm.expectRevert();

        token.transferFrom(bob, alice, 101);
    }

    /**
     * @dev Verifies that transferFrom() reverts when no allowance has
     *      been granted. Alice has no approval from Bob, so any spend
     *      attempt should revert.
     */
    function testTransferFromFailsWithoutApproval() public {
        vm.prank(alice);

        // Expect the next call to revert — no prior approval exists.
        vm.expectRevert();

        token.transferFrom(bob, alice, 1);
    }

    /**
     * @dev Verifies that multiple transferFrom() calls correctly consume
     *      the allowance and accumulate the recipient's balance.
     *
     *      Example:
     *        Bob approves Alice for 1000 OT.
     *        Alice calls transferFrom() twice: 300 OT + 200 OT = 500 OT total.
     *        Remaining allowance = 1000 - 500 = 500 OT.
     *        Alice balance = 500 OT.
     *
     *      vm.startPrank() / vm.stopPrank() impersonates Alice across
     *      multiple calls without needing a vm.prank() on each one.
     */
    function testMultipleTransferFromsConsumeAllowance() public {
        vm.prank(bob);
        token.approve(alice, 1000);

        // Impersonate Alice for both transferFrom calls.
        vm.startPrank(alice);

        token.transferFrom(bob, alice, 300);
        token.transferFrom(bob, alice, 200);

        vm.stopPrank();

        assertEq(token.balanceOf(alice), 500);
        assertEq(token.allowance(bob, alice), 500);
    }

    /**
     * @dev Verifies that a Transfer event is emitted with the correct
     *      parameters when tokens are transferred.
     *
     *      vm.expectEmit() parameters: (checkTopic1, checkTopic2, checkTopic3, checkData)
     *        - checkTopic1: true  → verify `from` (indexed).
     *        - checkTopic2: true  → verify `to` (indexed).
     *        - checkTopic3: false → no third indexed param.
     *        - checkData:   true  → verify `amount` (non-indexed).
     */
    function testTransferEmitsEvent() public {
        uint256 amount = 10 ether;

        // Declare the expected event before the call that triggers it.
        vm.expectEmit(true, true, false, true);
        emit Transfer(bob, alice, amount);

        // The actual call — Foundry compares the emitted event against the expectation.
        vm.prank(bob);
        token.transfer(alice, amount);
    }

    /**
     * @dev Verifies that an Approval event is emitted with the correct
     *      parameters when an allowance is set.
     */
    function testApproveEmitsEvent() public {
        uint256 allowance = 1000;

        // Declare the expected event before the call that triggers it.
        vm.expectEmit(true, true, false, true);
        emit Approval(bob, alice, allowance);

        // The actual call — Foundry compares the emitted event against the expectation.
        vm.prank(bob);
        token.approve(alice, allowance);
    }

    /**
     * @dev Verifies that calling approve() a second time completely replaces
     *      the existing allowance rather than adding to it.
     *
     *      Example:
     *        Bob sets allowance to 100 OT.
     *        Bob sets allowance to 500 OT.
     *        Final allowance = 500 OT (not 600).
     */
    function testApproveOverridesPreviousAllowance() public {
        vm.prank(bob);
        token.approve(alice, 100);

        assertEq(token.allowance(bob, alice), 100);

        // Second approval overwrites the first — not additive.
        vm.prank(bob);
        token.approve(alice, 500);

        assertEq(token.allowance(bob, alice), 500, "New approval should replace old allowance");
    }

    /**
     * @dev Fuzz test — verifies that transfer() works correctly for any
     *      valid amount between 0 and STARTING_BALANCE.
     *
     *      bound() constrains the random input to a valid range so the
     *      test never attempts to transfer more than Bob has.
     *
     *      Also verifies conservation of tokens: the sum of Alice and
     *      Bob's balances must always equal STARTING_BALANCE.
     *
     * @param amount Fuzzed transfer amount, bounded to [0, STARTING_BALANCE].
     */
    function testFuzzTransfer(uint256 amount) public {
        // Constrain the fuzzed input to a valid range.
        amount = bound(amount, 0, STARTING_BALANCE);

        vm.prank(bob);
        token.transfer(alice, amount);

        assertEq(token.balanceOf(alice), amount);
        assertEq(token.balanceOf(bob), STARTING_BALANCE - amount);

        // Verify token conservation — no tokens created or destroyed.
        assertEq(token.balanceOf(alice) + token.balanceOf(bob), STARTING_BALANCE);
    }

    /**
     * @dev Fuzz test — verifies that transferFrom() correctly consumes
     *      the allowance for any valid combination of allowance and spend amount.
     *
     *      Two bounds are applied:
     *        - allowance is capped at STARTING_BALANCE (Bob's max balance).
     *        - spendAmount is capped at allowance to ensure the call never reverts.
     *
     * @param allowance   Fuzzed allowance granted by Bob to Alice, bounded to [1, STARTING_BALANCE].
     * @param spendAmount Fuzzed spend amount by Alice, bounded to [0, allowance].
     */
    function testFuzzAllowance(uint256 allowance, uint256 spendAmount) public {
        // Ensure allowance is at least 1 and within Bob's balance.
        allowance = bound(allowance, 1, STARTING_BALANCE);

        // Ensure spend amount never exceeds the granted allowance.
        spendAmount = bound(spendAmount, 0, allowance);

        vm.prank(bob);
        token.approve(alice, allowance);

        vm.prank(alice);
        token.transferFrom(bob, alice, spendAmount);

        // Verify the remaining allowance equals the original minus what was spent.
        assertEq(token.allowance(bob, alice), allowance - spendAmount);
    }
}
