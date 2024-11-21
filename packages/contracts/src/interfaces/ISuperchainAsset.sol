// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/// @title ISuperchainAsset Interface
/// @notice Interface for interacting with the SuperchainAsset contract
interface ISuperchainAsset {
    
    /// @notice Get the name of the asset
    /// @return The name of the asset as a string
    function name() external view returns (string memory);

    /// @notice Get the symbol of the asset
    /// @return The symbol of the asset as a string
    function symbol() external view returns (string memory);

    /// @notice Get the number of decimals used by the asset
    /// @return The number of decimals as a uint8
    function decimals() external view returns (uint8);

    /// @notice Mint a specified amount of tokens to a given address
    /// @param to_ The address to mint tokens to
    /// @param amount_ The amount of tokens to mint
    function mint(address to_, uint256 amount_) external;

    /// @notice Burn a specified amount of tokens from a given address
    /// @param to_ The address to burn tokens from
    /// @param amount_ The amount of tokens to burn
    function burn(address to_, uint256 amount_) external;

    /// @notice Transfer tokens to a specified address
    /// @param recipient The address to transfer tokens to
    /// @param amount The amount of tokens to transfer
    /// @return A boolean indicating whether the operation was successful
    function transfer(address recipient, uint256 amount) external returns (bool);

    /// @notice Transfer tokens from one address to another
    /// @param sender The address to transfer tokens from
    /// @param recipient The address to transfer tokens to
    /// @param amount The amount of tokens to transfer
    /// @return A boolean indicating whether the operation was successful
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
} 
