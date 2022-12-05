# PreApprove

On-chain registry for pre-approvals of ERC721 transfers.

THIS CODEBASE IS STILL UNDER CONSTRUCTION. PLEASE DO NOT USE YET.

## Deployments

| Chain | PreApproveRegistry |
|---|---|
| Goerli | [`0x00000000000649D9ec3d61D86c69a62580E6f096`](https://goerli.etherscan.io/address/0x00000000000649d9ec3d61d86c69a62580e6f096) |

## Contracts

```ml
src
├─ PreApproveChecker.sol — "Library for querying the pre-approve registry efficiently"
├─ PreApproveLister.sol — "Ownable lister contract that can add/remove operators"
├─ PreApproveListerFactory.sol — "Factory to deploy lister contracts"
├─ PreApproveRegistry.sol — "The pre-approve registry"
├─ example
│  └─ ExampleERC721A.sol — "ERC721A example"
└─ utils
   └─ EnumerableAddressSetMap.sol — "Library for mapping of enumerable sets"
``` 

## Examples

| Type | Contract |
|---|---|
| ERC721A | [`src/example/ExampleERC721A.sol`](./src/example/ExampleERC721A.sol) |

## Glossary

- Collectors

  NFT collectors.

- Operators 

  Externally Owned Accounts (EOAs) or Smart Contracts that can manage NFTs on behalf of collectors. 

- Listers

  Externally Owned Accounts (EOAs) or Smart Contracts that can add or remove operators.  
  Collectors can subscribe to listers. 

- NFT Contracts

  ERC721 or ERC1155 compliant contracts that can override `isApprovedForAll(address collector, address operator)` to consult the registry to check if the operator is pre-approved by a specified lister which the collector is subscribed to.

- Registry

  The PreApproveRegistry which can allow collectors to subscribe to listers, and listers to add/remove operators. 

## Safety

This codebase is provided on an "as is" and "as available" basis.

We **do not give any warranties** and **will not be liable for any loss** incurred through any use of this codebase.

## Acknowledgements

This repository is inspired by and directly modified from:

- [Seaport](https://github.com/ProjectOpenSea/seaport)
- [ClosedSea](https://github.com/vectorized/closedsea)
