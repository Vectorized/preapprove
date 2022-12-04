// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "erc721a/ERC721A.sol";
import "../PreApproveChecker.sol";

/**
 * @title  ExampleERC721A
 * @notice This example contract is a demonstration of how to override the
 *         `isApprovedForAll` function to query the pre-approve registry.
 */
contract ExampleERC721A is ERC721A {
    address public constant PRE_APPROVE_LISTER = 0x0123456789012345678901234567890123456789;

    constructor() ERC721A("Example", "EXAMPLE") {}

    function isApprovedForAll(address owner, address operator)
        public
        view
        virtual
        override
        returns (bool)
    {
        return ERC721A.isApprovedForAll(owner, operator)
            || PreApproveChecker.isPreApproved(operator, owner, PRE_APPROVE_LISTER);
    }
}
