// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.4; 
 
import "solady/utils/LibClone.sol"; 
 
/** 
 * @title PreApproveListerFactory 
 * @notice A factory that allows one to deploy listers. 
 */ 
contract PreApproveListerFactory { 
    /** 
     * @dev The address of the pre-approve lister implementation. 
     */ 
    address internal constant _PRE_APPROVE_LISTER_IMPLMENTATION = 
        0x0000000016a3AF8Fe127Ac55b7Be2d97e1A54b34; 
 
    /** 
     * @dev Payable constructor for smaller deployment. 
     */ 
    constructor() payable {} 
 
    /** 
     * @dev Deploys a lister, with `initialOwner` as the owner, and returns the address. 
     * @param initialOwner The initial owner of the lister. 
     * @return lister The address of the deployed lister. 
     */ 
    function deploy(address initialOwner) external payable returns (address lister) { 
        lister = LibClone.clone(_PRE_APPROVE_LISTER_IMPLMENTATION); 
        /// @solidity memory-safe-assembly 
        assembly { 
            // Store the function selector: 
            // `bytes4(keccak256("initialize(address)"))` 
            mstore(returndatasize(), 0xc4d66de8) 
            mstore(0x20, initialOwner) 
            if iszero( 
                call( 
                    gas(), // Remaining gas. 
                    lister, // Address of the newly created lister. 
                    returndatasize(), // Send 0 ETH. 
                    0x1c, // Start of calldata. 
                    0x24, // Length of calldata. 
                    returndatasize(), // Start of returndata in memory. 
                    returndatasize() // Length of returndata. 
                ) 
            ) { 
                // This is to prevent gas under-estimation. 
                revert(0, 0) 
            } 
        } 
    } 
} 
