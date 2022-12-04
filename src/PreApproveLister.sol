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
     * @dev Whether the contract has already been initialized.
     */
    bool initialized;

    /**
     * @dev The address of the pre-approve registry.
     */
    address internal constant PRE_APPROVE_REGISTRY = 0x00000000000649D9ec3d61D86c69a62580E6f096;

    /**
     * @dev Initializer.
     */
    function initialize() external payable {
        require(!initialized);
        _initializeOwner(msg.sender);
        initialized = true;
    }

    /**
     * @dev Adds the `operator` to the pre-approve list maintained by the caller (lister).
     * @param operator The account that can manage NFTs on behalf of
     *                 collectors subscribed to the caller.
     */
    function addOperator(address operator) external payable onlyOwner {
        _addOrRemoveOperator(operator);
    }

    /**
     * @dev Removes the `operator` from the pre-approve list maintained by the caller (lister).
     * @param operator The account that can manage NFTs on behalf of
     *                 collectors subscribed to the caller.
     */
    function removeOperator(address operator) external payable onlyOwner {
        _addOrRemoveOperator(operator);
    }

    /**
     * @dev Allows the owner to add or remove the `operator`,
     *      depending on the calldata function selector.
     * @param operator The account that can manage NFTs on behalf of
     *                 collectors subscribed to the caller.
     */
    function _addOrRemoveOperator(address operator) internal {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, calldataload(0x00)) // Store the function selector.
            mstore(0x04, operator) // Store the operator.
            pop(
                call(
                    gas(), // Remaining gas.
                    PRE_APPROVE_REGISTRY, // The pre-approve registry.
                    0, // Send 0 ETH.
                    0x00, // Start of calldata.
                    0x24, // Length of calldata.
                    0x00, // Start of returndata in memory.
                    0x00 // Length of returndata.
                )
            )
        }
    }
}
