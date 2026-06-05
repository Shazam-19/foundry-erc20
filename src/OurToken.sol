// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
// ^ means "this version or any newer compatible version".
// 0.8.x includes built-in overflow/underflow protection — no SafeMath needed.

// Imports the OpenZeppelin ERC20 implementation.
// This gives OurToken all standard token behaviour (transfer, approve,
// allowance, balanceOf, etc.) without writing it from scratch.
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title   OurToken
 * @notice  A basic ERC20 token that mints the entire supply to the deployer on creation.
 * @dev     Inherits OpenZeppelin's ERC20 implementation.
 *          Token name:   "Our Token"
 *          Token symbol: "OT"
 *          Decimals:     18 (default from OpenZeppelin's ERC20)
 *
 *          All token amounts are expressed in the smallest unit (wei equivalent).
 *          Example: 1 OT = 1 * 10**18 = 1000000000000000000 units internally.
 */
contract OurToken is ERC20 {
    /**
     * @notice Deploys the token and mints the full supply to the deployer.
     * @dev    Calls the ERC20 parent constructor with the token name and symbol,
     *         then mints `initialSupply` tokens to msg.sender (the deployer).
     *
     *         Example:
     *           initialSupply = 1000 * 10**18
     *           → 1000 OT tokens minted to the deployer's address.
     *
     * @param initialSupply The total token supply in wei units (18 decimals).
     */
    constructor(uint256 initialSupply) ERC20("Our Token", "OT") {
        _mint(msg.sender, initialSupply);
    }
}
