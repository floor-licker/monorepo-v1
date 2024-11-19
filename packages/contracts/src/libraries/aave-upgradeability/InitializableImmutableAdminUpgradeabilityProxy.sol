// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.8.25;

// TODO: check how upgradeability works
import "./BaseImmutableAdminUpgradeabilityProxy.sol";

/**
 * @title InitializableAdminUpgradeabilityProxy
 * @dev Extends BaseAdminUpgradeabilityProxy with an initializer function
 */
contract InitializableImmutableAdminUpgradeabilityProxy is BaseImmutableAdminUpgradeabilityProxy {
    constructor(address admin) public BaseImmutableAdminUpgradeabilityProxy(admin) {}

    function initialize(address implementation, bytes memory initParams) public {
        // _upgradeTo(implementation);
        // (bool success, ) = implementation.delegatecall(initParams);
        // require(success);
    }

    /**
     * @dev Only fall back when the sender is not the admin.
     */
    function _willFallback() internal override {
        BaseImmutableAdminUpgradeabilityProxy._willFallback();
    }
}
