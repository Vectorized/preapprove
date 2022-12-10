// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "solady/utils/LibClone.sol";

/**
 * @title PreApproveListerFactory
 * @notice A factory that allows one to deploy listers.
 */
contract PreApproveListerFactory {
    /**
     * @dev The address of the pre-approve lister implementation.
     */
    address internal constant _PRE_APPROVE_LISTER_IMPLMENTATION =
        0x00000000Ad5E9a80B6beEAaaB4c3BdCE2c3318dB;

    /**
     * @dev Payable constructor for smaller deployment.
     */
    constructor() payable {}

    /**
     * @dev Deploys a lister, with `initialOwner` as the owner, and returns the address.
     * @param initialOwner The initial owner of the lister.
     * @return lister The address of the deployed lister.
     */
    function deploy(address initialOwner) external payable returns (address lister) {
        lister = LibClone.clone(_PRE_APPROVE_LISTER_IMPLMENTATION);
        _initializeInitialOwner(lister, initialOwner);
    }

    /**
     * @dev Deploys a lister deterministically with `salt`,
     *      with `initialOwner` as the owner, and returns the address.
     * @param initialOwner The initial owner of the lister.
     * @param salt         The CREATE2 salt used to deploy to a deterministic address.
     * @return lister The address of the deployed lister.
     */
    function deployDeterministic(address initialOwner, bytes32 salt)
        external
        payable
        returns (address lister)
    {
        // Require that the salt starts with either the zero address or the caller.
        LibClone.checkStartsWithCaller(salt);
        lister = LibClone.cloneDeterministic(_PRE_APPROVE_LISTER_IMPLMENTATION, salt);
        _initializeInitialOwner(lister, initialOwner);
    }

    /**
     * @dev Returns the initialization code hash of the lister minimal proxy clone.
     *      Used for mining vanity address with create2crunch.
     * @return hash The constant value.
     */
    function initCodeHash() external pure returns (bytes32 hash) {
        hash = LibClone.initCodeHash(_PRE_APPROVE_LISTER_IMPLMENTATION);
    }

    /**
     * @dev Returns the predicted deterministic address which the lister will be deployed to with `salt.
     * @param salt The CREATE2 salt.
     * @return lister The address of the lister.
     */
    function predictDeterministicAddress(bytes32 salt) external view returns (address lister) {
        lister = LibClone.predictDeterministicAddress(
            _PRE_APPROVE_LISTER_IMPLMENTATION, salt, address(this)
        );
    }

    /**
     * @dev Initializes the initial owner of `lister` to `initialOwner`.
     * @param lister       The lister contract.
     * @param initialOwner The initial owner of lister.
     */
    function _initializeInitialOwner(address lister, address initialOwner) internal {
        /// @solidity memory-safe-assembly
        assembly {
            // Store the function selector:
            // `bytes4(keccak256("initialize(address)"))`
            mstore(returndatasize(), 0xc4d66de8)
            mstore(0x20, initialOwner)
            if iszero(
                call(
                    gas(), // Remaining gas.
                    lister, // Address of the newly created lister.
                    returndatasize(), // Send 0 ETH.
                    0x1c, // Start of calldata.
                    0x24, // Length of calldata.
                    returndatasize(), // Start of returndata in memory.
                    returndatasize() // Length of returndata.
                )
            ) {
                // This is to prevent gas under-estimation.
                revert(0, 0)
            }
        }
    }
}
