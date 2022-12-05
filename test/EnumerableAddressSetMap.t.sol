// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./utils/TestPlus.sol";
import "solady/utils/LibSort.sol";
import {EnumerableAddressSetMap} from "../src/utils/EnumerableAddressSetMap.sol";
import {EnumerableSet} from "openzeppelin-contracts/utils/structs/EnumerableSet.sol";

contract EnumerableAddressSetMapTest is TestPlus {
    using EnumerableAddressSetMap for *;
    using EnumerableSet for *;

    mapping(address => EnumerableSet.AddressSet) mapOriginal;
    EnumerableAddressSetMap.Map map;

    function testEnumerableAddressSetMapDifferential(uint256) public {
        address[] memory keys = _randomAccounts(5);
        address[] memory values = _randomAccounts(5);
        unchecked {
            for (uint256 i; i != keys.length; ++i) {
                assertEq(mapOriginal[keys[i]].length(), map.length(keys[i]));
            }

            for (uint256 t; t != 16; ++t) {
                address key = keys[_random() % keys.length];
                address value = values[_random() % values.length];
                uint256 index;
                uint256 n;

                if ((n = mapOriginal[key].length()) != 0) {
                    index = _random() % n;
                    assertEq(mapOriginal[key].at(index), map.at(key, index));
                }

                assertEq(mapOriginal[key].contains(value), map.contains(key, value));
                assertEq(mapOriginal[key].length(), map.length(key));
                assertEq(mapOriginal[key].values(), map.values(key));

                map.add(key, value);
                mapOriginal[key].add(value);

                assertEq(mapOriginal[key].contains(value), map.contains(key, value));
                assertEq(mapOriginal[key].length(), map.length(key));
                assertEq(mapOriginal[key].values(), map.values(key));

                if ((n = mapOriginal[key].length()) != 0) {
                    index = _random() % n;
                    assertEq(mapOriginal[key].at(index), map.at(key, index));
                }

                key = keys[_random() % keys.length];
                value = values[_random() % values.length];
                map.remove(key, value);
                mapOriginal[key].remove(value);

                assertEq(mapOriginal[key].contains(value), map.contains(key, value));
                assertEq(mapOriginal[key].length(), map.length(key));
                assertEq(mapOriginal[key].values(), map.values(key));

                if ((n = mapOriginal[key].length()) != 0) {
                    index = _random() % n;
                    assertEq(mapOriginal[key].at(index), map.at(key, index));
                }
            }
        }
    }

    function _randomAccounts(uint256 n) internal view returns (address[] memory a) {
        a = new address[](n);
        unchecked {
            for (uint256 i; i != n; ++i) {
                if (_random() % 8 == 0) {
                    a[i] = address(uint160(((_random() & 1) << 128)));
                } else {
                    a[i] = address(uint160(_random() | (1 << 128)));
                }
            }
        }
        LibSort.insertionSort(a);
        LibSort.uniquifySorted(a);
    }
}
