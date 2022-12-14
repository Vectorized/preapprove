// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./PreApproveVanity.t.sol";
import {PreApproveLister} from "../src/PreApproveLister.sol";
import {PreApproveListerFactory} from "../src/PreApproveListerFactory.sol";
import "solady/utils/LibClone.sol";

contract PreApproveListerTest is PreApproveVanityTest {
    bool internal _testCreate2 = true;

    function _deployLister() internal returns (PreApproveLister lister) {
        lister = _deployLister(address(this));
    }

    function _deployLister(address locker) internal returns (PreApproveLister lister) {
        if (_testCreate2 && _random() % 2 == 0) {
            PreApproveListerFactory factory =
                PreApproveListerFactory(PRE_APPROVE_LISTER_FACTORY_CREATE2_DEPLOYED_ADDRESS);
            lister = PreApproveLister(factory.deploy(address(this), locker));
            assertEq(lister.owner(), address(this));
        } else {
            lister = new PreApproveLister();
            lister.initialize(address(this), locker);
        }
        // Check repeat initialization reverts.
        if (_random() % 8 == 0) {
            vm.expectRevert();
            lister.initialize(address(this), locker);
        }
    }

    function testCheckIsPreApprovedViaLister(uint256) public {
        PreApproveLister lister = _deployLister();

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

    function testListerLock(uint256) public {
        TestVars memory v = _testVars(_bound(_random(), 2, 10));

        address[] memory randomAccounts = _randomAccounts(10);
        vm.assume(randomAccounts.length > 2);
        address locker = randomAccounts[0];
        address backupLocker = randomAccounts[1];
        address notLocker = randomAccounts[2];

        PreApproveLister lister = _deployLister(locker);

        // Check set backup locker.
        vm.expectRevert("Backup cannot be zero.");
        lister.setBackupLocker(address(0));
        lister.setBackupLocker(backupLocker);
        vm.expectRevert("Already set.");
        lister.setBackupLocker(backupLocker);

        unchecked {
            for (uint256 i; i != v.operators.length; ++i) {
                lister.addOperator(v.operators[i]);
                // Check add operator twice does not revert.
                if (_random() % 2 == 0) {
                    lister.addOperator(v.operators[i]);
                }
            }
            // Check all operators added.
            assertEq(registry.totalOperators(address(lister)), v.operators.length);

            // Check if can remove operator before locked.
            if (_random() % 2 == 0) {
                lister.removeOperator(v.operators[_random() % v.operators.length]);
            }

            // Check cannot purge operators before locked.
            vm.expectRevert("Not locked.");
            lister.purgeOperators(v.operators.length);

            // Check permissions to lock.
            vm.prank(notLocker);
            vm.expectRevert("Unauthorized.");
            lister.lock();

            // Check either locker or the backup locker or the owner can lock.
            if (_random() % 2 == 0) {
                vm.prank(_random() % 2 == 0 ? locker : backupLocker);
            }
            lister.lock();

            // Check cannot add operator after locked.
            vm.expectRevert("Locked.");
            lister.addOperator(v.operators[0]);

            // Check cannot lock twice.
            vm.expectRevert("Locked.");
            lister.lock();

            // Check if can remove operator after locked.
            if (_random() % 2 == 0) {
                lister.removeOperator(v.operators[_random() % v.operators.length]);
            }

            uint256 n = registry.totalOperators(address(lister));
            uint256 p0 = _bound(_random(), 0, n);
            uint256 p1 = n - p0;
            // Check purge more than number of operators revert.
            if (_random() % 8 == 0) {
                vm.prank(address(uint160(_random())));
                vm.expectRevert();
                lister.purgeOperators(n + 1);
            }
            // Check purge operators.
            vm.prank(address(uint160(_random())));
            lister.purgeOperators(p0);
            vm.prank(address(uint160(_random())));
            lister.purgeOperators(p1);
            assertEq(registry.totalOperators(address(lister)), 0);
        }
    }
}
