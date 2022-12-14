// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "solady/utils/LibClone.sol";

/**
 * @title PreApproveListerFactory
 * @notice A factory that allows one to deploy listers.
 */
contract PreApproveListerFactory {
    // =============================================================
    //                           CONSTANTS
    // =============================================================

    /**
     * @dev The address of the pre-approve lister implementation.
     */
    address public constant PRE_APPROVE_LISTER_IMPLMENTATION =
        0x00000000f233003741E28F08125FBba9F6F5Db2d;

    // =============================================================
    //                          CONSTRUCTOR
    // =============================================================

    constructor() payable {}

    // =============================================================
    //               PUBLIC / EXTERNAL WRITE FUNCTIONS
    // =============================================================

    /**
     * @dev Deploys a lister, with `owner` as the owner, and returns the address.
     * @param owner  The initial owner of the lister.
     * @param locker An address that can lock the lister, besides the owner.
     * @return lister The address of the deployed lister.
     */
    function deploy(address owner, address locker) external payable returns (address lister) {
        lister = LibClone.clone(PRE_APPROVE_LISTER_IMPLMENTATION);
        _initializeDeployment(lister, owner, locker);
    }

    /**
     * @dev Deploys a lister deterministically with `salt`,
     *      with `owner` as the owner, and returns the address.
     * @param owner  The initial owner of the lister.
     * @param locker An address that can lock the lister, besides the owner.
     * @param salt   The CREATE2 salt used to deploy to a deterministic address.
     * @return lister The address of the deployed lister.
     */
    function deployDeterministic(address owner, address locker, bytes32 salt)
        external
        payable
        returns (address lister)
    {
        // Require that the salt starts with either the zero address or the caller.
        LibClone.checkStartsWithCaller(salt);
        lister = LibClone.cloneDeterministic(PRE_APPROVE_LISTER_IMPLMENTATION, salt);
        _initializeDeployment(lister, owner, locker);
    }

    // =============================================================
    //               PUBLIC / EXTERNAL VIEW FUNCTIONS
    // =============================================================

    /**
     * @dev Returns the deterministic address which the lister will be deployed at with `salt`.
     * @param salt The CREATE2 salt.
     * @return lister The predicted address of the lister.
     */
    function predictDeterministicAddress(bytes32 salt) external view returns (address lister) {
        lister = LibClone.predictDeterministicAddress(
            PRE_APPROVE_LISTER_IMPLMENTATION, salt, address(this)
        );
    }

    /**
     * @dev Returns the initialization code hash of the lister minimal proxy clone.
     *      Used for mining vanity address with create2crunch.
     * @return hash The constant value.
     */
    function initCodeHash() external pure returns (bytes32 hash) {
        hash = LibClone.initCodeHash(PRE_APPROVE_LISTER_IMPLMENTATION);
    }

    // =============================================================
    //                  INTERNAL / PRIVATE HELPERS
    // =============================================================

    /**
     * @dev Initializes the deployment.
     * @param lister The lister contract.
     * @param owner  The initial owner of lister.
     * @param locker An address that can lock the lister, besides the owner.
     */
    function _initializeDeployment(address lister, address owner, address locker) internal {
        /// @solidity memory-safe-assembly
        assembly {
            // Store the function selector:
            // `bytes4(keccak256("initialize(address,address)"))`
            mstore(returndatasize(), shl(224, 0x485cc955))
            mstore(0x04, owner)
            mstore(0x24, locker)
            if iszero(
                call(
                    gas(), // Remaining gas.
                    lister, // Address of the newly created lister.
                    returndatasize(), // Send 0 ETH.
                    returndatasize(), // Start of calldata.
                    0x44, // Length of calldata.
                    returndatasize(), // Start of returndata in memory.
                    returndatasize() // Length of returndata.
                )
            ) {
                // This is to prevent gas under-estimation.
                revert(0, 0)
            }
            // Restore the part of the free memory pointer that
            // was overwritten with 0.
            mstore(0x24, 0)
        }
    }
}
