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
    address internal constant _PRE_APPROVE_REGISTRY = 0x00000000000649D9ec3d61D86c69a62580E6f096;

    /**
     * @dev Whether the contract has already been initialized.
     */
    bool internal _initialized;

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
            // Store the function selector.
            mstore(returndatasize(), calldataload(returndatasize()))
            // Store the operator.
            mstore(0x04, operator)
            pop(
                call(
                    gas(), // Remaining gas.
                    _PRE_APPROVE_REGISTRY, // The pre-approve registry.
                    returndatasize(), // Send 0 ETH.
                    returndatasize(), // Start of calldata.
                    0x24, // Length of calldata.
                    returndatasize(), // Start of returndata in memory.
                    returndatasize() // Length of returndata.
                )
            )
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
            // Store the function selector.
            mstore(returndatasize(), calldataload(returndatasize()))
            // Store the operator.
            mstore(0x04, operator)
            pop(
                call(
                    gas(), // Remaining gas.
                    _PRE_APPROVE_REGISTRY, // The pre-approve registry.
                    returndatasize(), // Send 0 ETH.
                    returndatasize(), // Start of calldata.
                    0x24, // Length of calldata.
                    returndatasize(), // Start of returndata in memory.
                    returndatasize() // Length of returndata.
                )
            )
        }
    }
}
