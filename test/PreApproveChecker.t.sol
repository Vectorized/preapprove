// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.4; 
 
import "./PreApproveVanity.t.sol"; 
import {PreApproveChecker} from "../src/PreApproveChecker.sol"; 
 
contract PreApproveCheckerTest is PreApproveVanityTest { 
    function testCheckIsPreApproved(uint256) public { 
        TestVars memory v = _testVars(1); 
        assertEq(PreApproveChecker.isPreApproved(v.operator, v.collector, v.lister), false); 
 
        vm.prank(v.collector); 
        registry.subscribe(v.lister); 
 
        for (uint256 t; t != 2; ++t) { 
            vm.prank(v.lister); 
            registry.addOperator(v.operator); 
            assertEq(PreApproveChecker.isPreApproved(v.operator, v.collector, v.lister), false); 
 
            uint256 begins = registry.startTime(v.lister, v.operator); 
            vm.warp(begins - 1); 
            assertEq(PreApproveChecker.isPreApproved(v.operator, v.collector, v.lister), false); 
 
            vm.warp(begins); 
            assertEq(PreApproveChecker.isPreApproved(v.operator, v.collector, v.lister), true); 
 
            vm.warp(begins + _random() % 256); 
            assertEq(PreApproveChecker.isPreApproved(v.operator, v.collector, v.lister), true); 
 
            uint256 gasBefore = gasleft(); 
            PreApproveChecker.isPreApproved(v.operator, v.collector, v.lister); 
            console.log(gasBefore - gasleft()); 
 
            vm.warp(block.timestamp + _random() % 8); 
 
            if (_random() % 2 == 0) { 
                vm.prank(v.lister); 
                registry.removeOperator(v.operator); 
                assertEq(registry.startTime(v.lister, v.operator), 0); 
            } 
        } 
    } 
 
    function testCheckIsPreApprovedWithoutRegistry(uint256) public { 
        PreApproveRegistryTest.setUp(); 
        vm.etch(PreApproveChecker.PRE_APPROVE_REGISTRY, bytes("")); 
 
        TestVars memory v = _testVars(1); 
        assertEq(PreApproveChecker.isPreApproved(v.operator, v.collector, v.lister), false); 
 
        vm.prank(v.collector); 
        registry.subscribe(v.lister); 
 
        for (uint256 t; t != 2; ++t) { 
            vm.prank(v.lister); 
            registry.addOperator(v.operator); 
            assertEq(PreApproveChecker.isPreApproved(v.operator, v.collector, v.lister), false); 
 
            uint256 begins = registry.startTime(v.lister, v.operator); 
            vm.warp(begins - 1); 
            assertEq(PreApproveChecker.isPreApproved(v.operator, v.collector, v.lister), false); 
 
            vm.warp(begins); 
            assertEq(PreApproveChecker.isPreApproved(v.operator, v.collector, v.lister), false); 
 
            vm.warp(begins + _random() % 256); 
            assertEq(PreApproveChecker.isPreApproved(v.operator, v.collector, v.lister), false); 
 
            uint256 gasBefore = gasleft(); 
            PreApproveChecker.isPreApproved(v.operator, v.collector, v.lister); 
            console.log(gasBefore - gasleft()); 
 
            vm.warp(block.timestamp + _random() % 8); 
 
            if (_random() % 2 == 0) { 
                vm.prank(v.lister); 
                registry.removeOperator(v.operator); 
                assertEq(registry.startTime(v.lister, v.operator), 0); 
            } 
        } 
    } 
} 
