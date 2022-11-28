// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "openzeppelin-contracts/utils/structs/EnumerableMap.sol";

/// @notice A on-chain registry where `admins` can create lists of pre-approved
/// `operator`s, and `user`s can subscribe to the pre-approved lists.
/// When subscribed, NFT contracts that query this registry can allow the operators 
/// in the subscribed list to do token transfers on behalf of `user`.
contract PreApproveRegistry {
    using EnumerableSet for *;
    using EnumerableMap for *;

    // =============================================================
    //                            EVENTS
    // =============================================================

    event Subscribed(address indexed user, address indexed admin);

    event Unsubscribed(address indexed user, address indexed admin);

    event OperatorAdded(address indexed admin, address indexed operator, uint256 indexed startTime);

    event OperatorRemoved(address indexed admin, address indexed operator);

    // =============================================================
    //                           CONSTANTS
    // =============================================================

    uint256 public constant START_DELAY = 86400 * 7;

    // =============================================================
    //                            STORAGE
    // =============================================================

    /**
     * @dev Mapping of `admin` => (`operator` => `startTime`).
     * If `startTime` is zero, it is disabled.
     */
    mapping(address => EnumerableMap.AddressToUintMap) internal _operators;

    /**
     * @dev Mapping of `user` => `admin`.
     */
    mapping(address => EnumerableSet.AddressSet) internal _subscriptions;

    // =============================================================
    //               PUBLIC / EXTERNAL WRITE FUNCTIONS
    // =============================================================

    /**
     * @dev Subscribes the caller (user) from `admin`.
     * @param admin The account that maintains the pre-approval list.
     */
    function subscribe(address admin) public {
        _subscriptions[msg.sender].add(admin);
        emit Subscribed(msg.sender, admin);
    }

    /**
     * @dev Unsubscribes the caller (user) from `admin`.
     * @param admin The account that maintains the pre-approval list.
     */
    function unsubscribe(address admin) public {
        _subscriptions[msg.sender].remove(admin);
        emit Unsubscribed(msg.sender, admin);
    }

    /**
     * @dev Adds the `operator` to the pre-approval list maintained by the caller (admin).
     * @param operator The account (can be a contract).
     */
    function addOperator(address operator) public {
        unchecked {
            _operators[msg.sender].set(operator, block.timestamp + START_DELAY);    
        }
    }

    /**
     * @dev Removes the `operator` from the pre-approval list maintained by the caller (admin).
     * @param operator The account (can be a contract).
     */
    function removeOperator(address operator) public {
        _operators[msg.sender].remove(operator);
    }

    // =============================================================
    //               PUBLIC / EXTERNAL VIEW FUNCTIONS
    // =============================================================

    /**
     * @dev Returns whether `user` is subscribed to `admin`.
     * @param user  The user.
     * @param admin The maintainer of the pre-approval list.
     */
    function hasSubscription(address user, address admin) public view returns (bool) {
        return _subscriptions[user].contains(admin);
    }

    /**
     * @dev Returns an array of all the admins which `user` is subscribed to.
     * @param user  The user.
     */
    function subscriptions(address user) public view returns (address[] memory) {
        return _subscriptions[user].values();
    }

    /**
     * @dev Returns the total number of admins `user` is subscribed to.
     * @param user  The user.
     */
    function totalSubscriptions(address user) public view returns (uint256) {
        return _subscriptions[user].length();
    }

    /**
     * @dev Returns the `admin` which `user` is subscribed to at `index`.
     * @param user  The user.
     * @param index The index of the enumerable set.
     */
    function subscriptionAt(address user, uint256 index) public view returns (address) {
        return _subscriptions[user].at(index);
    }

    
    function operators(address admin) public view returns (address[] memory result) {
        bytes32[] memory a = _operators[admin]._inner._keys.values();
        assembly {
            result := a
        }
    }

    function totalOperators(address admin) public view returns (uint256) {
        return _operators[admin].length();
    }

    function operatorAt(address admin, uint256 index) public view returns (address, uint256) {
        return _operators[admin].at(index);
    }

    function startTime(address admin, address operator) public view returns (uint256) {
        return _operators[admin].get(operator);
    }

    function isPreApproved(address user, address admin, address operator) public view returns (bool result) {
        if (_subscriptions[user].contains(admin)) {
            uint256 t = uint256(_operators[admin]._inner._values[bytes32(uint256(uint160(operator)))]);
            assembly {
                result := iszero(or(iszero(t), lt(timestamp(), t)))
            }
        }
    }
}
