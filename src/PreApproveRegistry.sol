// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library EnumerableAddressSetMapping {
    struct SetMapping {
        // Storage of set values
        mapping(address => address[]) _values;
    }

    function add(SetMapping storage sm, address key, address value) internal returns (bool) {
        if (!contains(sm, key, value)) {
            sm._values[key].push(value);

            uint256 n = sm._values[key].length;

            /// @solidity memory-safe-assembly
            assembly {
                // The value is stored at length-1, but we add 1 to all indexes
                // and use 0 as a sentinel value
                mstore(0x20, value)
                mstore(0x0c, sm.slot)
                mstore(returndatasize(), key)
                sstore(keccak256(returndatasize(), 0x40), n)
            }
            return true;
        } else {
            return false;
        }
    }

    function remove(SetMapping storage sm, address key, address value) internal returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex;
        uint256 valueSlot;
        /// @solidity memory-safe-assembly
        assembly {
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
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

                    // Move the last value to the index where the value to delete is
                    sm._values[key][toDeleteIndex] = lastValue;

                    /// @solidity memory-safe-assembly
                    assembly {
                        // Update the index for the moved value
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
                    sstore(valueSlot, 0)
                }
            }
            return true;
        } else {
            return false;
        }
    }

    function contains(SetMapping storage sm, address key, address value)
        internal
        view
        returns (bool result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            mstore(0x20, value)
            mstore(0x0c, sm.slot)
            mstore(returndatasize(), key)
            result := sload(keccak256(returndatasize(), 0x40))
        }
    }

    function length(SetMapping storage sm, address key) internal view returns (uint256) {
        return sm._values[key].length;
    }

    function at(SetMapping storage sm, address key, uint256 index)
        internal
        view
        returns (address)
    {
        return sm._values[key][index];
    }

    function values(SetMapping storage sm, address key) internal view returns (address[] memory) {
        return sm._values[key];
    }
}

/**
 * @title PreApproveRegistry
 * @notice A on-chain registry where listers can create lists
 *         of pre-approved operators, which NFT collectors can subscribe to.
 *         When a collector is subscribed to a list by a lister,
 *         they can use pre-approved operators to manage their NFTs
 *         if the NFT contracts consult this registry on whether the operator
 *         is in the pre-approved list by lister.
 *
 *         For safety, newly added operators will need to wait some time
 *         before they take effect.
 */
contract PreApproveRegistry {
    using EnumerableAddressSetMapping for *;

    // =============================================================
    //                            EVENTS
    // =============================================================

    /**
     * @dev Emitted when `collector` subscribes to `lister`.
     * @param collector The NFT collector using the registry.
     * @param lister    The maintainer of the pre-approve list.
     */
    event Subscribed(address indexed collector, address indexed lister);

    /**
     * @dev Emitted when `collector` unsubscribes from `lister`.
     * @param collector The NFT collector using the registry.
     * @param lister    The maintainer of the pre-approve list.
     */
    event Unsubscribed(address indexed collector, address indexed lister);

    /**
     * @dev Emitted when `lister` adds `operator` to their pre-approve list.
     * @param lister    The maintainer of the pre-approve list.
     * @param operator  The account that can manage NFTs on behalf of
     *                  collectors subscribed to `lister`.
     * @param startTime The Unix timestamp when the `operator` can begin to manage
     *                  NFTs on on behalf of collectors subscribed to `lister`.
     */
    event OperatorAdded(
        address indexed lister, address indexed operator, uint256 indexed startTime
    );

    /**
     * @dev Emitted when `lister` removes `operator` from their pre-approve list.
     * The `operator` will be immediately removed from the list.
     * @param lister    The maintainer of the pre-approve list.
     * @param operator  The account that can manage NFTs on behalf of
     *                  collectors subscribed to `lister`.
     */
    event OperatorRemoved(address indexed lister, address indexed operator);

    // =============================================================
    //                           CONSTANTS
    // =============================================================

    /**
     * @dev The amount of time before a newly added `operator` becomes effective.
     */
    uint256 public constant START_DELAY = 86400 * 7;

    /**
     * @dev For extra efficiency, we use our own custom mapping for the mapping of
     * (`lister`, `operator`) => `startTime`.
     * If `startTime` is zero, it is disabled.
     * Note: It is not possible for any added `operator` to have a `startTime` of zero,
     * since we are already past the Unix epoch.
     */
    uint256 private constant _START_TIME_SLOT_SEED = 0xd4ac65089b313d464ac66fd0;

    // =============================================================
    //                            STORAGE
    // =============================================================

    /**
     * @dev Mapping of `collector => EnumerableSet.AddressSet(lister => exists)`.
     */
    EnumerableAddressSetMapping.SetMapping internal _subscriptions;

    /**
     * @dev Mapping of `lister => EnumerableSet.AddressSet(operator => exists)`.
     */
    EnumerableAddressSetMapping.SetMapping internal _operators;

    // =============================================================
    //               PUBLIC / EXTERNAL WRITE FUNCTIONS
    // =============================================================

    /**
     * @dev Subscribes the caller (collector) from `lister`.
     * @param lister The maintainer of the pre-approve list.
     */
    function subscribe(address lister) external {
        _subscriptions.add(msg.sender, lister);
        emit Subscribed(msg.sender, lister);
    }

    /**
     * @dev Unsubscribes the caller (collector) from `lister`.
     * @param lister The maintainer of the pre-approve list.
     */
    function unsubscribe(address lister) external {
        _subscriptions.remove(msg.sender, lister);
        emit Unsubscribed(msg.sender, lister);
    }

    /**
     * @dev Adds the `operator` to the pre-approve list maintained by the caller (lister).
     * @param operator The account that can manage NFTs on behalf of
     *                 collectors subscribed to the caller.
     */
    function addOperator(address operator) external {
        _operators.add(msg.sender, operator);
        uint256 begins;
        /// @solidity memory-safe-assembly
        assembly {
            begins := add(timestamp(), START_DELAY)
            // The sequence of overlays automatically cleans the upper bits of `operator`.
            mstore(0x20, operator)
            mstore(0x0c, _START_TIME_SLOT_SEED)
            mstore(returndatasize(), caller())
            sstore(keccak256(returndatasize(), 0x40), begins)
        }
        emit OperatorAdded(msg.sender, operator, begins);
    }

    /**
     * @dev Removes the `operator` from the pre-approve list maintained by the caller (lister).
     * @param operator The account that can manage NFTs on behalf of
     *                 collectors subscribed to the caller.
     */
    function removeOperator(address operator) external {
        _operators.remove(msg.sender, operator);
        /// @solidity memory-safe-assembly
        assembly {
            // The sequence of overlays automatically cleans the upper bits of `operator`.
            mstore(0x20, operator)
            mstore(0x0c, _START_TIME_SLOT_SEED)
            mstore(returndatasize(), caller())
            sstore(keccak256(returndatasize(), 0x40), returndatasize())
        }
        emit OperatorRemoved(msg.sender, operator);
    }

    // =============================================================
    //               PUBLIC / EXTERNAL VIEW FUNCTIONS
    // =============================================================

    /**
     * @dev Returns whether `collector` is subscribed to `lister`.
     * @param collector The NFT collector using the registry.
     * @param lister    The maintainer of the pre-approve list.
     * @return has Whether the `collector` is subscribed.
     */
    function hasSubscription(address collector, address lister) external view returns (bool has) {
        has = _subscriptions.contains(collector, lister);
    }

    /**
     * @dev Returns an array of all the listers which `collector` is subscribed to.
     * @param collector The NFT collector using the registry.
     * @return list The list of listers.
     */
    function subscriptions(address collector) external view returns (address[] memory list) {
        list = _subscriptions.values(collector);
    }

    /**
     * @dev Returns the total number of listers `collector` is subscribed to.
     * @param collector The NFT collector using the registry.
     * @return total The length of the list of listers subscribed by `collector`.
     */
    function totalSubscriptions(address collector) external view returns (uint256 total) {
        total = _subscriptions.length(collector);
    }

    /**
     * @dev Returns the `lister` which `collector` is subscribed to at `index`.
     * @param collector The NFT collector using the registry.
     * @param index     The index of the enumerable set.
     * @return lister The mainter of the pre-approve list.
     */
    function subscriptionAt(address collector, uint256 index)
        external
        view
        returns (address lister)
    {
        lister = _subscriptions.at(collector, index);
    }

    /**
     * @dev Returns the list of operators in the pre-approve list by `lister`.
     * @param lister The maintainer of the pre-approve list.
     * @return list  The list of operators.
     */
    function operators(address lister) external view returns (address[] memory list) {
        list = _operators.values(lister);
    }

    /**
     * @dev Returns the list of operators in the pre-approve list by `lister`.
     * @param lister The maintainer of the pre-approve list.
     * @return total The length of the list of operators.
     */
    function totalOperators(address lister) external view returns (uint256 total) {
        total = _operators.length(lister);
    }

    /**
     * @dev Returns the operator at `index` of the pre-approve list by `lister`.
     * @param lister The maintainer of the pre-approve list.
     * @param index  The index of the list.
     * @param operator The account that can manage NFTs on behalf of
     *                 collectors subscribed to `lister`.
     */
    function operatorAt(address lister, uint256 index)
        external
        view
        returns (address operator, uint256 begins)
    {
        operator = _operators.at(lister, index);
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x20, operator)
            mstore(0x0c, _START_TIME_SLOT_SEED)
            mstore(returndatasize(), lister)
            begins := sload(keccak256(returndatasize(), 0x40))
        }
    }

    /**
     * @dev Returns the Unix timestamp when `operator` is able to start managing
     *      the NFTs of collectors subscribed to `lister`.
     * @param lister   The maintainer of the pre-approve list.
     * @param operator The account that can manage NFTs on behalf of
     *                 collectors subscribed to `lister`.
     * @return begins The Unix timestamp.
     */
    function startTime(address lister, address operator) external view returns (uint256 begins) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x20, operator)
            mstore(0x0c, _START_TIME_SLOT_SEED)
            mstore(returndatasize(), lister)
            begins := sload(keccak256(returndatasize(), 0x40))
        }
    }

    /**
     * @dev Returns whether the `operator` can manage NFTs on the behalf
     *      of `collector` if `collector` is subscribed to `lister`.
     * @param operator The account that can manage NFTs on behalf of
     *                 collectors subscribed to `lister`.
     * @param collector The NFT collector using the registry.
     * @param lister The maintainer of the pre-approve list.
     * @return Whether `operator` is effectively pre-approved.
     */
    function isPreApproved(address operator, address collector, address lister)
        external
        view
        returns (bool)
    {
        /* 
        Original code:

        if (_subscriptions[collector].contains(lister)) {
            uint256 begins = startTime(lister, operator);
            return begins == 0 ? false : block.timestamp >= begins;
        }

        Assembly version saves 370 gas.

        We can skip the masking of the addresses. 
        In case of dirty upper bits, this function will return false,
        and any NFT contracts using this registry will simply revert back
        to default behavior (the normal ERC721 approval process).
        */

        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x20, lister)
            mstore(0x0c, 0)
            mstore(returndatasize(), collector)

            if iszero(sload(keccak256(returndatasize(), 0x40))) { return(0x60, 0x20) }

            mstore(0x20, operator)
            mstore(0x0c, _START_TIME_SLOT_SEED)
            mstore(returndatasize(), lister)
            let begins := sload(keccak256(returndatasize(), 0x40))
            mstore(returndatasize(), iszero(or(iszero(begins), lt(timestamp(), begins))))
            return(returndatasize(), 0x20)
        }
    }
}
