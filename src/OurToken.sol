// SPDX-License-Identifier: MIT
// Declares that this code is open-source under the MIT license.
// This is required by Solidity tools and good practice for any public contract.

pragma solidity ^0.8.26;

// Tells the compiler which version of Solidity to use.
// The `^` means "this version or any newer compatible version".
// 0.8.x includes built-in overflow/underflow protection — no need for SafeMath.

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract OurToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("Our Token", "OT") {
        _mint(msg.sender, initialSupply);
    }
}
