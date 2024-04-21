

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IBlacklist.sol";

contract Token is ERC20, Ownable {
    address public blAddress;

    constructor(
        string memory name_,
        string memory symbol_,
        address blAddress_
    ) ERC20(name_, symbol_) Ownable(_msgSender()) {
        blAddress = blAddress_;
    }

    /**
     * @dev Mint new tokens and assign them to the specified account.
     * Only the contract owner can call this function.
     * 
     * @param account The account to which the tokens will be minted.
     * @param amount The amount of tokens to mint.
     */
    function mint(address account, uint256 amount) public onlyOwner {
        _beforeTokenTransfer(_msgSender(), account , amount);
        _mint(account, amount);
    }

    /**
     * @dev Burn tokens from the caller's account.
     * 
     * @param amount The amount of tokens to burn.
     */
    function burn(uint256 amount) public {
        _beforeTokenTransfer(_msgSender(), address(0), amount);
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Transfer tokens from the caller's account to the specified account.
     * 
     * @param to The account to which the tokens will be transferred.
     * @param value The amount of tokens to transfer.
     * @return A boolean value indicating whether the transfer was successful or not.
     */
    function transfer(address to, uint256 value) public override returns (bool) {
        _beforeTokenTransfer(_msgSender(), to, value);
        super._transfer(_msgSender(), to , value);
        return true;
    }

    /**
     * @dev Transfer tokens from a specified account to another specified account.
     * 
     * @param from The account from which the tokens will be transferred.
     * @param to The account to which the tokens will be transferred.
     * @param value The amount of tokens to transfer.
     * @return A boolean value indicating whether the transfer was successful or not.
     */
    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        _beforeTokenTransfer(from, to, value);
        super._transfer(from, to , value);
        return true;
    }

    /**
     * @dev Internal function to be called before any token transfer.
     * It checks if either the sender or the recipient is blacklisted.
     * If either is blacklisted, it reverts the transaction.
     * 
     * @param from The account from which the tokens will be transferred.
     * @param to The account to which the tokens will be transferred.
     * @param amount The amount of tokens to transfer.
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal view {
        amount;
        if(IBlacklist(blAddress).isBlacklisted(from) || IBlacklist(blAddress).isBlacklisted(to)) {
            revert("Address is blacklisted");
        }
    }
}
