// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../PreApproveVanity.t.sol";
import {PreApproveLister} from "../../src/PreApproveLister.sol";
import {ExampleERC721A} from "../../src/example/ExampleERC721A.sol";
import "solady/utils/LibClone.sol";

contract TestableExampleERC721A is ExampleERC721A {
    function mint(address to, uint256 quantity) external {
        _mint(to, quantity);
    }
}

contract PreApproveListerTest is PreApproveVanityTest {
    error TransferCallerNotOwnerNorApproved();

    TestableExampleERC721A example;
    PreApproveLister lister;

    function setUp() public override {
        super.setUp();
        example = new TestableExampleERC721A();

        PreApproveLister implementation = new PreApproveLister();
        address clone = LibClone.clone(address(implementation));
        vm.etch(example.PRE_APPROVE_LISTER(), clone.code);
        lister = PreApproveLister(example.PRE_APPROVE_LISTER());
        lister.initialize(address(this), address(this));
    }

    function testTransfer(uint256) public {
        TestVars memory v = _testVars(1);
        vm.assume(v.operator != address(0));
        vm.assume(v.collector != address(0));
        vm.assume(v.operator != v.collector);

        v.lister = address(lister);

        example.mint(v.collector, 1);

        assertEq(example.isApprovedForAll(v.collector, v.operator), false);
        vm.prank(v.operator);
        vm.expectRevert(TransferCallerNotOwnerNorApproved.selector);
        example.transferFrom(v.collector, address(this), 0);

        lister.addOperator(v.operator);

        assertEq(example.isApprovedForAll(v.collector, v.operator), false);
        vm.prank(v.operator);
        vm.expectRevert(TransferCallerNotOwnerNorApproved.selector);
        example.transferFrom(v.collector, address(this), 0);

        vm.prank(v.collector);
        registry.subscribe(v.lister);

        assertEq(example.isApprovedForAll(v.collector, v.operator), false);
        vm.prank(v.operator);
        vm.expectRevert(TransferCallerNotOwnerNorApproved.selector);
        example.transferFrom(v.collector, address(this), 0);

        vm.warp(registry.startTime(v.lister, v.operator));

        assertEq(example.isApprovedForAll(v.collector, v.operator), true);
        vm.prank(v.operator);
        example.transferFrom(v.collector, address(this), 0);
    }
}
