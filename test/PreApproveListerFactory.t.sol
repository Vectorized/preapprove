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

        bytes32 hash = factory.initCodeHash();
        hash = keccak256(abi.encodePacked(hex"ff", address(factory), salt, hash));
        assertEq(predictedAddress, address(uint160(uint256(hash))));

        address actualAddress = factory.deployDeterministic(address(this), address(this), salt);
        assertEq(predictedAddress, actualAddress);
    }
}
