// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.4; 
 
import "./utils/TestPlus.sol"; 
import "solady/utils/LibSort.sol"; 
import {PreApproveRegistry} from "../src/PreApproveRegistry.sol"; 
 
contract PreApproveRegistryTest is TestPlus { 
    event Subscribed(address indexed collector, address indexed lister); 
 
    event Unsubscribed(address indexed collector, address indexed lister); 
 
    event OperatorAdded( 
        address indexed lister, address indexed operator, uint256 indexed startTime 
    ); 
 
    event OperatorRemoved(address indexed lister, address indexed operator); 
 
    PreApproveRegistry registry; 
 
    struct TestVars { 
        address lister; 
        address operator; 
        address collector; 
        address[] listers; 
        address[] operators; 
        address[] collectors; 
        uint256 startDelay; 
    } 
 
    function setUp() public virtual { 
        registry = new PreApproveRegistry(); 
    } 
 
    function testIsPreApproved(uint256) public { 
        TestVars memory v = _testVars(1); 
        assertEq(registry.isPreApproved(v.operator, v.collector, v.lister), false); 
 
        vm.prank(v.collector); 
        registry.subscribe(v.lister); 
 
        for (uint256 t; t != 2; ++t) { 
            vm.prank(v.lister); 
            registry.addOperator(v.operator); 
            assertEq(registry.isPreApproved(v.operator, v.collector, v.lister), false); 
 
            uint256 begins = registry.startTime(v.lister, v.operator); 
            vm.warp(begins - 1); 
            assertEq(registry.isPreApproved(v.operator, v.collector, v.lister), false); 
 
            vm.warp(begins); 
            assertEq(registry.isPreApproved(v.operator, v.collector, v.lister), true); 
 
            vm.warp(begins + _random() % 256); 
            assertEq(registry.isPreApproved(v.operator, v.collector, v.lister), true); 
 
            uint256 gasBefore = gasleft(); 
            registry.isPreApproved(v.operator, v.collector, v.lister); 
            console.log(gasBefore - gasleft()); 
 
            vm.warp(block.timestamp + _random() % 8); 
 
            if (_random() % 2 == 0) { 
                vm.prank(v.lister); 
                registry.removeOperator(v.operator); 
                assertEq(registry.startTime(v.lister, v.operator), 0); 
            } 
        } 
    } 
 
    function testIsPreApproved2() public { 
        testIsPreApproved(1); 
    } 
 
    function testOperatorListingGettersAndSetters(uint256) public { 
        TestVars memory v = _testVars(4); 
 
        for (uint256 t; t != 3; ++t) { 
            v.lister = v.listers[_random() % v.listers.length]; 
            v.operator = v.operators[_random() % v.operators.length]; 
 
            vm.expectEmit(true, true, true, true); 
            emit OperatorAdded(v.lister, v.operator, block.timestamp + v.startDelay); 
            vm.prank(v.lister); 
            registry.addOperator(v.operator); 
 
            v.operator = v.operators[_random() % v.operators.length]; 
            vm.expectEmit(true, true, true, true); 
            emit OperatorRemoved(v.lister, v.operator); 
            vm.prank(v.lister); 
            registry.removeOperator(v.operator); 
 
            vm.warp(block.timestamp + _random() % 256); 
        } 
 
        for (uint256 i; i != v.operators.length; ++i) { 
            vm.prank(v.lister); 
            registry.removeOperator(v.operators[i]); 
        } 
        assertEq(registry.operators(v.lister), new address[](0)); 
 
        for (uint256 i; i != v.operators.length; ++i) { 
            vm.prank(v.lister); 
            registry.addOperator(v.operators[i]); 
            address[] memory expectedOperators = new address[](i + 1); 
            for (uint256 j; j != expectedOperators.length; ++j) { 
                expectedOperators[j] = v.operators[j]; 
            } 
            address[] memory operators = registry.operators(v.lister); 
            assertEq(registry.totalOperators(v.lister), operators.length); 
            for (uint256 j; j != expectedOperators.length; ++j) { 
                (address operator, uint256 begins) = registry.operatorAt(v.lister, j); 
                assertEq(operator, operators[j]); 
                assertEq(begins, block.timestamp + v.startDelay); 
                assertEq( 
                    registry.startTime(v.lister, v.operators[i]), block.timestamp + v.startDelay 
                ); 
            } 
            LibSort.sort(operators); 
            assertEq(operators, expectedOperators); 
        } 
 
        for (uint256 i; i != v.operators.length; ++i) { 
            vm.prank(v.lister); 
            registry.removeOperator(v.operators[i]); 
        } 
        assertEq(registry.operators(v.lister), new address[](0)); 
    } 
 
    function testSuscriptionGettersAndSetters(uint256) public { 
        TestVars memory v = _testVars(4); 
 
        for (uint256 t; t != 3; ++t) { 
            v.lister = v.listers[_random() % v.listers.length]; 
            v.collector = v.collectors[_random() % v.collectors.length]; 
 
            vm.expectEmit(true, true, true, true); 
            emit Subscribed(v.collector, v.lister); 
            vm.prank(v.collector); 
            registry.subscribe(v.lister); 
 
            assertEq(registry.hasSubscription(v.collector, v.lister), true); 
 
            v.lister = v.listers[_random() % v.listers.length]; 
            vm.expectEmit(true, true, true, true); 
            emit Unsubscribed(v.collector, v.lister); 
            vm.prank(v.collector); 
            registry.unsubscribe(v.lister); 
            assertEq(registry.hasSubscription(v.collector, v.lister), false); 
        } 
 
        for (uint256 i; i != v.listers.length; ++i) { 
            vm.prank(v.collector); 
            registry.unsubscribe(v.listers[i]); 
        } 
        assertEq(registry.subscriptions(v.collector), new address[](0)); 
 
        for (uint256 i; i != v.listers.length; ++i) { 
            vm.prank(v.collector); 
            registry.subscribe(v.listers[i]); 
            address[] memory expectedSubscriptions = new address[](i + 1); 
            for (uint256 j; j != expectedSubscriptions.length; ++j) { 
                expectedSubscriptions[j] = v.listers[j]; 
            } 
            address[] memory subscriptions = registry.subscriptions(v.collector); 
            assertEq(registry.totalSubscriptions(v.collector), subscriptions.length); 
            for (uint256 j; j != expectedSubscriptions.length; ++j) { 
                assertEq(registry.subscriptionAt(v.collector, j), subscriptions[j]); 
            } 
            LibSort.sort(subscriptions); 
            assertEq(subscriptions, expectedSubscriptions); 
        } 
 
        for (uint256 i; i != v.listers.length; ++i) { 
            vm.prank(v.collector); 
            registry.unsubscribe(v.listers[i]); 
        } 
        assertEq(registry.subscriptions(v.collector), new address[](0)); 
    } 
 
    function _testVars(uint256 n) internal view returns (TestVars memory v) { 
        v.listers = _randomAccounts(n); 
        v.operators = _randomAccounts(n); 
        v.collectors = _randomAccounts(n); 
        v.lister = v.listers[_random() % v.listers.length]; 
        v.operator = v.operators[_random() % v.operators.length]; 
        v.collector = v.collectors[_random() % v.collectors.length]; 
        v.startDelay = registry.START_DELAY(); 
    } 
 
    function _randomAccounts(uint256 n) internal view returns (address[] memory a) { 
        a = new address[](n); 
        unchecked { 
            for (uint256 i; i != n; ++i) { 
                if (_random() % 8 == 0) { 
                    a[i] = address(uint160(((_random() % 4) << 128))); 
                } else { 
                    a[i] = address(uint160(_random() | (1 << 128))); 
                } 
            } 
        } 
        LibSort.insertionSort(a); 
        LibSort.uniquifySorted(a); 
    } 
} 
