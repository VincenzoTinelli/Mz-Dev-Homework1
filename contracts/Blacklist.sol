// This contract implements a simple blacklist functionality.
// It allows the owner to add and remove addresses from the blacklist.

// SPDX-License-Identifier:  MIT

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Blacklist is Ownable {
    // address[] private _blacklist;
    mapping(address => bool) private _blacklisted;

    constructor() Ownable(msg.sender) {}

    // Function to set addresses in the blacklist
    function setBlacklist(address[] calldata blArray) external onlyOwner {
        for (uint256 i = 0; i < blArray.length; i++) {
            _blacklisted[blArray[i]] = true;
        }
    }

    // Function to reset addresses in the blacklist
    function resetBlacklist(address[] calldata blArray) external onlyOwner {
        for (uint256 i = 0; i < blArray.length; i++) {
            _blacklisted[blArray[i]] = false;
        }
    }

    // Function to check if an address is blacklisted
    function isBlacklisted(address account) public view returns (bool) {
        return _blacklisted[account];
    }
}
