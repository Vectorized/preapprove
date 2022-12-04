// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./PreApproveVanity.t.sol";
import {PreApproveLister} from "../src/PreApproveLister.sol";
import {PreApproveListerFactory} from "../src/PreApproveListerFactory.sol";
import "solady/utils/LibClone.sol";

contract PreApproveListerTest is PreApproveVanityTest {
    PreApproveLister public lister;

    function setUp() public override {
        super.setUp();
        lister = PreApproveLister(
            (PreApproveListerFactory(PRE_APPROVE_LISTER_FACTORY_CREATE2_DEPLOYED_ADDRESS)).deploy(
                address(this)
            )
        );
        assertEq(lister.owner(), address(this));
    }

    function testCheckIsPreApprovedViaLister(uint256) public {
        TestVars memory v = _testVars(1);
        v.lister = address(lister);
        assertEq(registry.isPreApproved(v.operator, v.collector, v.lister), false);

        vm.prank(v.collector);
        registry.subscribe(v.lister);

        for (uint256 t; t != 2; ++t) {
            lister.addOperator(v.operator);
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
                lister.removeOperator(v.operator);
                assertEq(registry.startTime(v.lister, v.operator), 0);
            }
        }
    }
}
