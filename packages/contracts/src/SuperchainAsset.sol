// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Predeploys} from "@contracts-bedrock/libraries/Predeploys.sol";
import {SuperchainERC20} from "@contracts-bedrock/L2/SuperchainERC20.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// whenever user uses this with SuperchainTokenBridge, the destination chain will mint aToken (if underlying < totalBalances) and transfer underlying remaining

contract SuperchainAsset is SuperchainERC20 {
    string private _name;
    string private _symbol;
    uint8 private immutable _decimals;
    address public underlying; // address of underlying asset
    mapping(uint256 user => uint256 balance) public balances; // user balance of underlying
    uint256 public totalBalances; // total balances of underlying

    constructor(address owner_, string memory name_, string memory symbol_, uint8 decimals_, address underlying_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        underlying = underlying_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }
    
    /// @dev minting more than totalBalances will mint aToken and transfer underlying
    /// only callable by SuperchainTokenBridge (which has already burned the aToken amount on source chain)
    function _mint(address to_, uint256 amount_) internal override {
        if(amount_ > totalBalances) {
            /// TODO gas optimize this
            // need to mint more than totalBalances
            balances[to_] += amount_ - totalBalances;
            super._mint(to_, amount_ - totalBalances);
            // reset totalBalances and transfer underlying
            totalBalances = 0;
            IERC20(underlying).safeTransfer(to_, totalBalances);
        } else {
            totalBalances -= amount_;
            IERC20(underlying).safeTransfer(to_, amount_);
        }
    }

    function mint(uint256 to_, uint256 amount_) external {
        balances[to_] += amount_;
        totalBalances += amount_;
        IERC20(underlying).safeTransferFrom(msg.sender, address(this), amount_);
        super._mint(to_, amount_);
    }

    function _burn(address from_, uint256 amount_) internal override {
        balances[from_] -= amount_;
        super._burn(from_, amount_);
    }

    function burn(uint256 to_, uint256 amount_) external {
        totalBalances -= amount_;
        _burn(msg.sender, amount_);
        IERC20(underlying).safeTransfer(to_, amount_);
    }

    // TODO: override transfer functions to also transfer underlying
}
