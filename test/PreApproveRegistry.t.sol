// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./utils/TestPlus.sol";
import "solady/utils/LibSort.sol";
import {PreApproveRegistry} from "../src/PreApproveRegistry.sol";

contract PreApproveRegistryTest is TestPlus {
    event Subscribed(address indexed collector, address indexed lister);
    
    event Unsubscribed(address indexed collector, address indexed lister);
    
    event OperatorAdded(address indexed lister, address indexed operator, uint256 indexed startTime);

    event OperatorRemoved(address indexed lister, address indexed operator);

    PreApproveRegistry registry;
    
    function setUp() public {
        registry = new PreApproveRegistry();
    }

    function testSettersAndGetters(uint256) public {
        assertEq(registry.operators(address(this)), new address[](0));

        address[] memory listers = new address[](8);
        for (uint256 i; i < listers.length; ++i) {
            listers[i] = _randomAccount();
        }
        LibSort.sort(listers);

        address[] memory collectors = new address[](3);
        for (uint256 i; i < collectors.length; ++i) {
            collectors[i] = _randomAccount();
        }
        LibSort.sort(collectors);

        address lister;
        address collector;

        for (uint256 t; t < 256; ++t) {
            lister = listers[_random() % listers.length];
            collector = collectors[_random() % collectors.length];

            vm.expectEmit(true, true, true, true);
            emit Subscribed(collector, lister);
            vm.prank(collector);
            registry.subscribe(lister);

            assertEq(registry.hasSubscription(collector, lister), true);

            lister = listers[_random() % listers.length];
            vm.expectEmit(true, true, true, true);
            emit Unsubscribed(collector, lister);
            vm.prank(collector);
            registry.unsubscribe(lister);
            assertEq(registry.hasSubscription(collector, lister), false);
        }

        collector = collectors[_random() % collectors.length];
        for (uint256 i; i < listers.length; ++i) {
            vm.prank(collector);
            registry.subscribe(collectors[i]);
        }
        address[] memory subscriptions = registry.subscriptions(collector);
        LibSort.sort(subscriptions);
        assertEq(subscriptions, listers);



        
        
    }

    function _randomAccount() internal returns (address a) {
        a = vm.addr(_random());
        vm.deal(a, 1 << 128);
    }
}
