// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./PreApproveVanity.t.sol";
import {PreApproveListerFactory} from "../src/PreApproveListerFactory.sol";

contract PreApproveListerFactoryTest is PreApproveVanityTest {
    function testDeployDeterministic(uint256) public {
        uint256 r = _random();
        bytes32 salt = bytes32(r >> 160);
        PreApproveListerFactory factory = new PreApproveListerFactory();
        address predictedAddress = factory.predictDeterministicAddress(salt);

        bytes32 h =
            keccak256(abi.encodePacked(hex"ff", address(factory), salt, factory.initCodeHash()));
        assertEq(predictedAddress, address(uint160(uint256(h))));

        address actualAddress = factory.deployDeterministic(address(this), salt);
        assertEq(predictedAddress, actualAddress);
    }
}
