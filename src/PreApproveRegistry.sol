// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// Imports EnumerableSet and EnumerableMap.
import "openzeppelin-contracts/utils/structs/EnumerableMap.sol";

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
    using EnumerableSet for *;
    using EnumerableMap for *;

    // =============================================================
    //                           CONSTANTS
    // =============================================================

    /**
     * @dev The amount of time before a newly added `operator` becomes effective.
     */
    uint256 public constant START_DELAY = 86400 * 7;

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
    //                            STORAGE
    // =============================================================

    /**
     * @dev Mapping of `lister` => (`operator` => `startTime`).
     * If `startTime` is zero, it is disabled.
     * Note: It is not possible for any added `operator` to have a `startTime` of zero,
     * since we are already past the Unix epoch.
     */
    mapping(address => EnumerableMap.AddressToUintMap) internal _operators;

    /**
     * @dev Mapping of `collector` => `lister`.
     */
    mapping(address => EnumerableSet.AddressSet) internal _subscriptions;

    // =============================================================
    //               PUBLIC / EXTERNAL WRITE FUNCTIONS
    // =============================================================

    /**
     * @dev Subscribes the caller (collector) from `lister`.
     * @param lister The maintainer of the pre-approve list.
     */
    function subscribe(address lister) external {
        _subscriptions[msg.sender].add(lister);
        emit Subscribed(msg.sender, lister);
    }

    /**
     * @dev Unsubscribes the caller (collector) from `lister`.
     * @param lister The maintainer of the pre-approve list.
     */
    function unsubscribe(address lister) external {
        _subscriptions[msg.sender].remove(lister);
        emit Unsubscribed(msg.sender, lister);
    }

    /**
     * @dev Adds the `operator` to the pre-approve list maintained by the caller (lister).
     * @param operator The account that can manage NFTs on behalf of
     *                 collectors subscribed to the caller.
     */
    function addOperator(address operator) external {
        unchecked {
            uint256 begins = block.timestamp + START_DELAY;
            _operators[msg.sender].set(operator, begins);
            emit OperatorAdded(msg.sender, operator, begins);
        }
    }

    /**
     * @dev Removes the `operator` from the pre-approve list maintained by the caller (lister).
     * @param operator The account that can manage NFTs on behalf of
     *                 collectors subscribed to the caller.
     */
    function removeOperator(address operator) external {
        _operators[msg.sender].remove(operator);
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
        has = _subscriptions[collector].contains(lister);
    }

    /**
     * @dev Returns an array of all the listers which `collector` is subscribed to.
     * @param collector The NFT collector using the registry.
     * @return list The list of listers.
     */
    function subscriptions(address collector) external view returns (address[] memory list) {
        list = _subscriptions[collector].values();
    }

    /**
     * @dev Returns the total number of listers `collector` is subscribed to.
     * @param collector The NFT collector using the registry.
     * @return total The length of the list of listers subscribed by `collector`.
     */
    function totalSubscriptions(address collector) external view returns (uint256 total) {
        total = _subscriptions[collector].length();
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
        lister = _subscriptions[collector].at(index);
    }

    /**
     * @dev Returns the list of operators in the pre-approve list by `lister`.
     * @param lister The maintainer of the pre-approve list.
     * @return list  The list of operators.
     */
    function operators(address lister) external view returns (address[] memory list) {
        bytes32[] memory a = _operators[lister]._inner._keys.values();
        assembly {
            list := a
        }
    }

    /**
     * @dev Returns the list of operators in the pre-approve list by `lister`.
     * @param lister The maintainer of the pre-approve list.
     * @return total The length of the list of operators.
     */
    function totalOperators(address lister) external view returns (uint256 total) {
        total = _operators[lister].length();
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
        (operator, begins) = _operators[lister].at(index);
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
        begins = uint256(_operators[lister]._inner._values[bytes32(uint256(uint160(operator)))]);
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

        Assembly version saves 255 gas.

        We can skip the masking of the addresses. 
        In case of dirty upper bits, this function will return false,
        and any NFT contracts using this registry will simply revert back
        to default behavior (the normal ERC721 approval process).
        */

        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x20, 1)
            mstore(returndatasize(), collector)
            mstore(0x20, add(keccak256(returndatasize(), 0x40), 1))
            mstore(returndatasize(), lister)

            if iszero(sload(keccak256(returndatasize(), 0x40))) { return(0x60, 0x20) }

            mstore(0x20, returndatasize())
            mstore(returndatasize(), lister)
            mstore(0x20, add(keccak256(returndatasize(), 0x40), 2))
            mstore(returndatasize(), operator)
            let begins := sload(keccak256(returndatasize(), 0x40))
            mstore(returndatasize(), iszero(or(iszero(begins), lt(timestamp(), begins))))
            return(returndatasize(), 0x20)
        }
    }
}