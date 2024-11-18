// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.8.25;

import {ILendingPoolAddressesProvider} from "./interfaces/ILendingPoolAddressesProvider.sol";
import {DataTypes} from "./libraries/types/DataTypes.sol";

contract LendingPoolStorage {
    ILendingPoolAddressesProvider internal _addressesProvider;

    mapping(address => DataTypes.ReserveData) internal _reserves;
    mapping(address => DataTypes.UserConfigurationMap) internal _usersConfig;
    mapping(address user => mapping(address asset => uint256 amount)) internal initiatedDepositAmount;

    // List of reserves as a map (reserveId => address)
    mapping(uint256 => address) internal _reservesList;
    uint256 internal _reservesCount;

    bool internal _paused;

    uint256 internal _maxStableRateBorrowSizePercent;

    uint256 internal _flashLoanPremiumTotal;

    uint256 internal _maxNumberOfReserves;
}
