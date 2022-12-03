// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * @title PreApproveChecker
 * @notice A library for checking whether an operator is pre-approved
 *         by a lister subcribed to by a collector.
 */
library PreApproveChecker {
    /**
     * @dev The address of the pre-approve registry.
     */
    address internal constant PRE_APPROVE_REGISTRY = 0x0000000000220203551AC16f0e2AcC221A7857Cd;

    /**
     * @dev Returns whether the `operator` is approved by `lister`,
     *      and `lister` is subscribed to by `collector`.
     * @param operator  The account that can manage NFTs on behalf of
     *                  collectors subscribed to `lister`.
     * @param collector The NFT collector using the registry.
     * @param lister    The maintainer of the pre-approve list.
     * @return result Whether `operator` is effectively pre-approved.
     */
    function isPreApproved(address operator, address collector, address lister)
        internal
        view
        returns (bool result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.

            // Store the function selector:
            // `bytes4(keccak256("isPreApproved(address,address,address)"))`
            mstore(0x00, 0x555dc0d9)
            mstore(0x20, operator)
            mstore(0x40, collector)
            mstore(0x60, lister)

            result :=
                and(
                    eq(mload(0x00), 1),
                    staticcall(
                        gas(), // Remaining gas.
                        PRE_APPROVE_REGISTRY, // The pre-approve registry.
                        0x1c, // Start of calldata.
                        0x64, // Length of calldata.
                        0x00, // Start of returndata in memory.
                        0x20 // Length of returndata.
                    )
                )

            mstore(0x40, m) // Restore the free memory pointer.
            mstore(0x60, 0) // Restore the zero slot.
        }
    }
}
