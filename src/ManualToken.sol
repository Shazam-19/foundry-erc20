// SPDX-License-Identifier: MIT
// Declares that this code is open-source under the MIT license.
// This is required by Solidity tools and good practice for any public contract.

pragma solidity ^0.8.26;

// Tells the compiler which version of Solidity to use.
// The `^` means "this version or any newer compatible version".
// 0.8.x includes built-in overflow/underflow protection — no need for SafeMath.

/**
 * @title ManualToken
 * @notice A simplified ERC-20-like token contract written manually for learning purposes.
 * @dev This contract intentionally omits full ERC-20 compliance (e.g. approve/transferFrom,
 *      Transfer events) to keep the focus on core token mechanics.
 *      Do NOT use in production — see OpenZeppelin's ERC20 for a battle-tested implementation.
 */
contract ManualToken {
    // --- State Variables ---

    /**
     * @dev Maps each wallet address to its token balance.
     *      Private visibility means only this contract can read/write it directly.
     *      The `s_` prefix is a convention for storage variables (Chainlink/Foundry style).
     *
     *      Example:
     *        s_balances[0xABC...] = 50 * 10**18  means address 0xABC holds 50 tokens.
     */
    mapping(address => uint256) private s_balances;

    /**
     * @notice The human-readable name of this token.
     * @dev Declared as `public`, so Solidity auto-generates a getter: name().
     *      Note: ideally this would be `immutable` since it never changes after deployment.
     */
    string public name = "Manual Token";

    // --- Read Functions (pure / view) ---

    /**
     * @notice Returns the total fixed supply of this token.
     * @dev Uses the `ether` unit keyword as a shorthand for 10^18.
     *      So `100 ether` = 100 * 10^18 = 100_000_000_000_000_000_000 (in raw units).
     *      This matches the 18-decimal standard used by most ERC-20 tokens.
     *      `pure` means this function reads nothing from storage — it only returns a constant.
     * @return The total supply: 100 tokens expressed in their smallest unit (wei-equivalent).
     */
    function totalSupply() public pure returns (uint256) {
        return 100 ether;
    }

    /**
     * @notice Returns the number of decimal places used to represent token amounts.
     * @dev 18 decimals is the ERC-20 standard, matching ETH's own precision.
     *      This means 1 token is stored as 1_000_000_000_000_000_000 (1 * 10^18).
     *      UIs use this value to display balances correctly (e.g. divide raw amount by 10^18).
     * @return Always returns 18.
     */
    function decimals() public pure returns (uint8) {
        return 18;
    }

    /**
     * @notice Returns the token balance of a given address.
     * @dev `view` means this reads from storage but does not modify it.
     *      Calling this costs no gas when used off-chain (e.g. from a frontend).
     * @param _owner The wallet address to query.
     * @return The raw token balance of `_owner` (in smallest units, accounting for 18 decimals).
     *
     *      Example:
     *        balanceOf(0xABC...) returns 25_000_000_000_000_000_000
     *        → displayed in a wallet as "25 tokens"
     */
    function balanceOf(address _owner) public view returns (uint256) {
        return s_balances[_owner];
    }

    // --- Write Functions ---

    /**
     * @notice Transfers `_amount` tokens from the caller's balance to `_to`.
     * @dev Key behaviours:
     *        1. Reverts if the sender has insufficient balance.
     *        2. Reverts if the recipient is the zero address (which would burn tokens unintentionally).
     *        3. Uses Solidity 0.8's built-in underflow protection as a secondary safety net.
     *
     *      Known limitation: The final `require` (balance invariant check) is mathematically
     *      redundant in this implementation; it will never fail given the arithmetic above it.
     *      It is kept here intentionally as a placeholder for future enhancement
     *      (e.g. fee-on-transfer logic, or reentrancy detection).
     *
     *      ** Missing from full ERC-20 compliaemissionnce: `Transfer` event **
     *
     * @param _to     The recipient's wallet address.
     * @param _amount The number of tokens to transfer, in raw units (18 decimals).
     *
     *      Example:
     *        To send 10 tokens: transfer(0xABC..., 10 * 10**18)
     */
    function transfer(address _to, uint256 _amount) public {
        // Guard 1: Ensure the sender actually owns enough tokens to cover the transfer.
        require(s_balances[msg.sender] >= _amount, "Insufficient Balance");

        // Guard 2: Prevent sending tokens to address(0); the burn/null address.
        // Tokens sent there are permanently lost with no way to recover them.
        require(_to != address(0), "Transfer to zero address");

        // Snapshot the combined balance of both parties before any changes are made.
        // Used below to verify the total is preserved (no tokens created or destroyed).
        uint256 previousBalances = balanceOf(msg.sender) + balanceOf(_to);

        // Deduct `_amount` from the sender. Safe from underflow due to Guard 1 above,
        // and additionally protected by Solidity 0.8's built-in overflow checks.
        s_balances[msg.sender] -= _amount;

        // Credit `_amount` to the recipient.
        s_balances[_to] += _amount;

        // Invariant check: verify total tokens held by both parties is unchanged.
        // NOTE: This will always pass with the current logic (no fees, no hooks).
        // It is retained as a structural placeholder — a real version would check
        // total supply or guard against reentrancy via a dedicated modifier.
        require(balanceOf(msg.sender) + balanceOf(_to) == previousBalances, "Invalid transfer");
    }
}
