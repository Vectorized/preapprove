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

    uint256 public constant TIME_TO_EFFECT = 86400 * 7;

    /// @dev Mapping of `admin` => (`operator` => `timeOfEffect`).
    /// If `timeOfEffect` is zero, it is disabled.
    mapping(address => EnumerableMap.AddressToUintMap) internal _operators;

    /// @dev Mapping of `user` => `admin`.
    mapping(address => EnumerableSet.AddressSet) internal _subscriptions;

    function addSubscription(address admin) public {
        _subscriptions[msg.sender].add(admin);
    }

    function removeSubscription(address admin) public {
        _subscriptions[msg.sender].remove(admin);
    }
    
    function hasSubscription(address user, address admin) public view returns (bool) {
        return _subscriptions[user].contains(admin);
    }

    function subscriptions(address user) public view returns (address[] memory) {
        return _subscriptions[user].values();
    }

    function totalSubscriptions(address user) public view returns (uint256) {
        return _subscriptions[user].length();
    }

    function subscriptionAt(address user, uint256 index) public view returns (address) {
        return _subscriptions[user].at(index);
    }

    function addOperator(address operator) public {
        unchecked {
            _operators[msg.sender].set(operator, block.timestamp + TIME_TO_EFFECT);    
        }
    }

    function removeOperator(address operator) public {
        _operators[msg.sender].remove(operator);
    }

    function timeOfEffect(address admin, address operator) public returns (uint256) {
        return _operators[admin].get(operator);
    }

    function operators(address admin) public returns (address[] memory result) {
        bytes32[] memory a = _operators[admin]._inner._keys.values();
        assembly {
            result := a
        }
    }

    function totalOperators(address admin) public returns (uint256) {
        return _operators[admin].length();
    }

    function operatorAt(address admin, uint256 index) public returns (address, uint256) {
        return _operators[admin].at(index);
    }

    function isPreApproved(address user, address admin, address operator) public returns (bool result) {
        if (_subscriptions[user].contains(admin)) {
            uint256 startTime = uint256(_operators[admin]._inner._values[bytes32(uint256(uint160(key)))]);
            assembly {
                result := iszero(or(iszero(startTime), lt(timestamp(), startTime)))
            }
        }
    }
}
