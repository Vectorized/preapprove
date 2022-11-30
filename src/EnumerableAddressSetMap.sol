// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * @title PreApproveRegistry
 * @notice This library enumlates a `mapping(address => EnumerableSet.AddressSet())`.
 *         For gas savings, we shall use `returndatasize()` as a replacement for 0.
 *         Modified from OpenZeppelin's EnumerableSet (MIT Licensed).
 *         https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/structs/EnumerableSet.sol
 */
library EnumerableAddressSetMap {
    struct Map {
        mapping(address => address[]) _values;
    }

    function add(Map storage sm, address key, address value) internal {
        if (!contains(sm, key, value)) {
            sm._values[key].push(value);

            uint256 n = sm._values[key].length;

            /// @solidity memory-safe-assembly
            assembly {
                // The value is stored at length-1, but we add 1 to all indexes
                // and use 0 as a sentinel value.
                // Equivalent to:
                // `_indexes[key][value] = n`.
                mstore(0x20, value)
                mstore(0x0c, sm.slot)
                mstore(returndatasize(), key)
                sstore(keccak256(returndatasize(), 0x40), n)
            }
        }
    }

    function remove(Map storage sm, address key, address value) internal {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex;
        uint256 valueSlot;
        /// @solidity memory-safe-assembly
        assembly {
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value.
            // Equivalent to:
            // `valueIndex = _indexes[key][value]`.
            mstore(0x20, value)
            mstore(0x0c, sm.slot)
            mstore(returndatasize(), key)
            valueSlot := keccak256(returndatasize(), 0x40)
            valueIndex := sload(valueSlot)
        }

        if (valueIndex != 0) {
            // Equivalent to contains(sm, value)
            // To delete an element from the _values array in O(1),
            // we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.
            unchecked {
                uint256 toDeleteIndex = valueIndex - 1;
                uint256 lastIndex = sm._values[key].length - 1;

                if (lastIndex != toDeleteIndex) {
                    address lastValue = sm._values[key][lastIndex];

                    // Move the last value to the index where the value to delete is.
                    sm._values[key][toDeleteIndex] = lastValue;

                    /// @solidity memory-safe-assembly
                    assembly {
                        // Update the index for the moved value.
                        // Equivalent to:
                        // `_indexes[key][lastValue] = valueIndex`.
                        mstore(0x20, lastValue)
                        mstore(0x0c, sm.slot)
                        mstore(returndatasize(), key)
                        // Replace lastValue's index to valueIndex
                        sstore(keccak256(returndatasize(), 0x40), valueIndex)
                    }
                }
                // Delete the slot where the moved value was stored
                sm._values[key].pop();

                /// @solidity memory-safe-assembly
                assembly {
                    // Delete the index for the deleted slot
                    // Equivalent to:
                    // `_indexes[key][value] = 0`.
                    sstore(valueSlot, 0)
                }
            }
        }
    }

    function contains(Map storage sm, address key, address value)
        internal
        view
        returns (bool result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value.
            // Equivalent to:
            // `result = _indexes[key][lastValue] != 0`.
            mstore(0x20, value)
            mstore(0x0c, sm.slot)
            mstore(returndatasize(), key)
            result := iszero(iszero(sload(keccak256(returndatasize(), 0x40))))
        }
    }

    function length(Map storage sm, address key) internal view returns (uint256) {
        return sm._values[key].length;
    }

    function at(Map storage sm, address key, uint256 index) internal view returns (address) {
        return sm._values[key][index];
    }

    function values(Map storage sm, address key) internal view returns (address[] memory) {
        return sm._values[key];
    }
}
