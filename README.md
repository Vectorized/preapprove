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
├─ PreApproveRegistry.sol — "The pre-approve registry"
├─ EnumerableAddressSetMap.sol — "Library for mapping of enumerable sets"
├─ PreApproveChecker.sol — "Library for querying the pre-approve registry efficiently"
├─ PreApproveLister.sol — "Sample contract for proxied listing to the registry"
└─ example
   └─ ExampleERC721A.sol — "ERC721A example"
``` 

## Examples

| Type | Contract |
|---|---|
| ERC721A | [`src/example/ExampleERC721A.sol`](./src/example/ExampleERC721A.sol) |

## Safety

This codebase is provided on an "as is" and "as available" basis.

We **do not give any warranties** and **will not be liable for any loss** incurred through any use of this codebase.

## Acknowledgements

This repository is inspired by and directly modified from:

- [Seaport](https://github.com/ProjectOpenSea/seaport)
- [ClosedSea](https://github.com/vectorized/closedsea)
