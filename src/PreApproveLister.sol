// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "solady/auth/Ownable.sol";

/**
 * @title PreApproveLister
 * @notice A contract that allows the owner to add and remove operators
 *         to the registry.
 */
contract PreApproveLister is Ownable {
    /**
     * @dev The address of the pre-approve registry.
     */
    address public constant PRE_APPROVE_REGISTRY = 0x00000000000044dfA889ebC2C5103067Ec23332f;

    /**
     * @dev Whether the contract has already been initialized.
     */
    bool internal _initialized;

    /**
     * @dev Payable constructor for smaller deployment.
     */
    constructor() payable {}

    /**
     * @dev Initializer.
     */
    function initialize(address initialOwner) external payable {
        require(!_initialized);
        _initializeOwner(initialOwner);
        _initialized = true;
    }

    /**
     * @dev Adds the `operator` to the pre-approve list maintained by the caller (lister).
     * @param operator The account that can manage NFTs on behalf of
     *                 collectors subscribed to the caller.
     */
    function addOperator(address operator) external payable onlyOwner {
        /// @solidity memory-safe-assembly
        assembly {
            // Silence compiler warning on unused variable.
            let t := operator
            // Copy over the function selector and the operator to memory.
            calldatacopy(returndatasize(), returndatasize(), 0x24)
            if iszero(
                call(
                    gas(), // Remaining gas.
                    PRE_APPROVE_REGISTRY, // The pre-approve registry.
                    returndatasize(), // Send 0 ETH.
                    returndatasize(), // Start of calldata.
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

    /**
     * @dev Removes the `operator` from the pre-approve list maintained by the caller (lister).
     * @param operator The account that can manage NFTs on behalf of
     *                 collectors subscribed to the caller.
     */
    function removeOperator(address operator) external payable onlyOwner {
        /// @solidity memory-safe-assembly
        assembly {
            // Silence compiler warning on unused variable.
            let t := operator
            // Copy over the function selector and the operator to memory.
            calldatacopy(returndatasize(), returndatasize(), 0x24)
            if iszero(
                call(
                    gas(), // Remaining gas.
                    PRE_APPROVE_REGISTRY, // The pre-approve registry.
                    returndatasize(), // Send 0 ETH.
                    returndatasize(), // Start of calldata.
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
