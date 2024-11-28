// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.8.25;

import {ILendingPoolAddressesProvider} from "./ILendingPoolAddressesProvider.sol";
import {DataTypes} from "../libraries/types/DataTypes.sol";

/**
 * @dev Emitted on deposit()
 * @param user The address initiating the deposit
 * @param reserve The address of the underlying asset of the reserve
 * @param amount The amount deposited
 * @param onBehalfOf The beneficiary of the deposit, receiving the aTokens
 * @param referral The referral code used
 * @param mintMode The mint mode: 0 for aTokens, 1 for minting, 2 for burning
 * @param amountScaled The amount scaled to the pool's unit
 *
 */
event Deposit(
    address user,
    address indexed reserve,
    uint256 amount,
    address indexed onBehalfOf,
    uint16 indexed referral,
    uint256 mintMode,
    uint256 amountScaled
);

/**
 * @dev Emitted on withdraw()
 * @param user The address initiating the withdrawal, owner of aTokens
 * @param reserve The address of the underlyng asset being withdrawn
 * @param to Address that will receive the underlying
 * @param amount The amount to be withdrawn
 * @param mode The mode: 0 for aTokens, 1 for minting, 2 for burning
 * @param amountScaled The amount scaled to the pool's unit
 *
 */
event Withdraw(
    address indexed user,
    address indexed reserve,
    address indexed to,
    uint256 amount,
    uint256 mode,
    uint256 amountScaled
);

/**
 * @dev Emitted on borrow() and flashLoan() when debt needs to be opened
 * @param reserve The address of the underlying asset being borrowed
 * @param amount The amount borrowed out
 * @param user The address of the user initiating the borrow(), receiving the funds on borrow() or just
 * initiator of the transaction on flashLoan()
 * @param onBehalfOf The address that will be getting the debt
 * @param sendToChainId The chain id to send the funds to
 * @param borrowRateMode The rate mode: 1 for Stable, 2 for Variable
 * @param borrowRate The numeric rate at which the user has borrowed
 * @param mintMode 0 if minting aTokens, 1 if minting stable debt, 2 if minting variable debt
 * @param amountScaled The amount scaled to the pool's unit
 * @param referral The referral code used
 *
 */
event Borrow(
    address indexed reserve,
    uint256 amount,
    address user,
    address indexed onBehalfOf,
    uint256 borrowRateMode,
    uint256 sendToChainId,
    uint256 borrowRate,
    uint256 mintMode,
    uint256 amountScaled,
    uint16 indexed referral
);

/**
 * @dev Emitted on repay()
 * @param reserve The address of the underlying asset of the reserve
 * @param amount The amount repaid
 * @param user The beneficiary of the repayment, getting his debt reduced
 * @param repayer The address of the user initiating the repay(), providing the funds
 *
 */
event Repay(address indexed reserve, uint256 amount, address indexed user, address indexed repayer);

/**
 * @dev Emitted on swapBorrowRateMode()
 * @param reserve The address of the underlying asset of the reserve
 * @param user The address of the user swapping his rate mode
 * @param rateMode The rate mode that the user wants to swap to
 *
 */
event Swap(address indexed reserve, address indexed user, uint256 rateMode);

/**
 * @dev Emitted on setUserUseReserveAsCollateral()
 * @param reserve The address of the underlying asset of the reserve
 * @param user The address of the user enabling the usage as collateral
 *
 */
event ReserveUsedAsCollateralEnabled(address indexed reserve, address indexed user);

/**
 * @dev Emitted on setUserUseReserveAsCollateral()
 * @param reserve The address of the underlying asset of the reserve
 * @param user The address of the user enabling the usage as collateral
 *
 */
event ReserveUsedAsCollateralDisabled(address indexed reserve, address indexed user);

/**
 * @dev Emitted on rebalanceStableBorrowRate()
 * @param reserve The address of the underlying asset of the reserve
 * @param user The address of the user for which the rebalance has been executed
 *
 */
event RebalanceStableBorrowRate(address indexed reserve, address indexed user);

/**
 * @dev Emitted on flashLoan()
 * @param chainId The chain id
 * @param borrowExecuted Whether the borrow was executed
 * @param initiator The address initiating the flash loan
 * @param asset The address of the asset being flash borrowed
 * @param amount The amount flash borrowed
 * @param premium The fee flash borrowed
 * @param target The address of the flash loan receiver contract
 * @param referralCode The referral code used
 *
 */
event FlashLoan(
    uint256 chainId,
    bool borrowExecuted,
    address indexed initiator,
    address indexed asset,
    uint256 amount,
    uint256 premium,
    address indexed target,
    uint16 referralCode
);

/**
 * @dev Emitted when a borrower is liquidated. This event is emitted by the LendingPool via
 * LendingPoolCollateral manager using a DELEGATECALL
 * This allows to have the events in the generated ABI for LendingPool.
 * @param collateralAsset The address of the underlying asset used as collateral, to receive as result of the liquidation
 * @param debtAsset The address of the underlying borrowed asset to be repaid with the liquidation
 * @param user The address of the borrower getting liquidated
 * @param debtToCover The debt amount of borrowed `asset` the liquidator wants to cover
 * @param liquidatedCollateralAmount The amount of collateral received by the liiquidator
 * @param liquidator The address of the liquidator
 * @param receiveAToken `true` if the liquidators wants to receive the collateral aTokens, `false` if he wants
 * to receive the underlying collateral asset directly
 *
 */
event LiquidationCall(
    address indexed collateralAsset,
    address indexed debtAsset,
    address indexed user,
    uint256 debtToCover,
    uint256 liquidatedCollateralAmount,
    address liquidator,
    bool receiveAToken
);

interface ILendingPool {
    /**
     * @dev Functions to deposit/withdraw into the reserve
     */
    function deposit(
        address asset,
        uint256[] calldata amounts,
        address onBehalfOf,
        uint16 referralCode,
        uint256[] calldata chainIds
    ) external;

    function withdraw(
        address asset,
        uint256[] calldata amounts,
        address to,
        uint256 toChainId,
        uint256[] calldata chainIds
    ) external;

    /**
     * @dev Functions to borrow from the reserve
     */
    function borrow(
        address asset,
        uint256[] calldata amounts,
        uint256[] calldata interestRateMode,
        uint16 referralCode,
        address onBehalfOf,
        uint256 sendToChainId,
        uint256[] calldata chainIds
    ) external;

    function repay(
        address asset,
        uint256[] calldata amounts,
        uint256 totalAmount,
        uint256[] calldata rateMode,
        address onBehalfOf,
        uint256[] calldata chainIds
    ) external;

    function swapBorrowRateMode(address asset, uint256 rateMode) external;

    function rebalanceStableBorrowRate(address asset, address user, uint256[] calldata chainIds) external;

    function setUserUseReserveAsCollateral(address asset, bool[] calldata useAsCollateral, uint256[] calldata chainIds)
        external;

    function liquidationCall(
        address collateralAsset,
        address debtAsset,
        address user,
        uint256[] calldata debtToCover,
        uint256 totalDebtToCover,
        uint256[] calldata chainIds,
        bool receiveAToken,
        uint256 sendToChainId
    ) external;

    function getUserAccountData(address user)
        external
        view
        returns (
            uint256 totalCollateralETH,
            uint256 totalDebtETH,
            uint256 availableBorrowsETH,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor
        );

    function initReserve(
        address reserve,
        address aTokenAddress,
        address superchainAsset,
        address stableDebtAddress,
        address variableDebtAddress,
        address interestRateStrategyAddress
    ) external;

    function setReserveInterestRateStrategyAddress(address reserve, address rateStrategyAddress) external;

    function setConfiguration(address reserve, uint256 configuration) external;

    function getConfiguration(address asset) external view returns (DataTypes.ReserveConfigurationMap memory);

    function getUserConfiguration(address user) external view returns (DataTypes.UserConfigurationMap memory);

    function getReserveNormalizedIncome(address asset) external view returns (uint256);

    function getReserveNormalizedVariableDebt(address asset) external view returns (uint256);

    function getReserveData(address asset) external view returns (DataTypes.ReserveData memory);

    function finalizeTransfer(
        address asset,
        address from,
        address to,
        uint256 amount,
        uint256 balanceFromAfter,
        uint256 balanceToBefore
    ) external;

    function getReservesList() external view returns (address[] memory);

    function getAddressesProvider() external view returns (ILendingPoolAddressesProvider);

    function setPause(bool val) external;

    function paused() external view returns (bool);
}
