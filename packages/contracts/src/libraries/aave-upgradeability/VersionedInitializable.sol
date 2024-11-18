// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.8.25;

/**
 * @title VersionedInitializable
 * @dev Helper contract to implement initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * @notice Contracts must be initialized using init() or they will remain locked.
 */
abstract contract VersionedInitializable {
    address private immutable INITIALIZATION_ADMIN;
    uint256 private lastInitializedRevision = 0;
    bool private initializing;

    modifier initializer() {
        require(
            initializing || isConstructor() || getRevision() > lastInitializedRevision,
            "Contract instance has already been initialized"
        );

        bool isTopLevelCall = !initializing;
        if (isTopLevelCall) {
            initializing = true;
            lastInitializedRevision = getRevision();
        }

        _;

        if (isTopLevelCall) {
            initializing = false;
        }
    }

    constructor() {
        INITIALIZATION_ADMIN = msg.sender;
    }

    function isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address
        // Returns 0 for contracts in construction
        uint256 cs;
        assembly {
            cs := extcodesize(address())
        }
        return cs == 0;
    }

    /**
     * @dev Returns the revision number of the contract
     * Needs to be defined in the inherited class as a constant.
     */
    function getRevision() internal pure virtual returns (uint256);

    /**
     * @dev Returns true if and only if the function is running in the constructor
     */
    function isInitializing() public view returns (bool) {
        return initializing;
    }
}
