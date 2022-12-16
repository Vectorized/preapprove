# PreApprove

[![NPM][npm-shield]][npm-url]
[![CI][ci-shield]][ci-url]
[![MIT License][license-shield]][license-url]

On-chain registry for pre-approvals of ERC721 transfers.

Useful for pre-approving contracts in your dApp ecosystem to manage NFTs without individual approvals.

## Deployments

| Chain | PreApproveRegistry | PreApproveListerFactory |
|---|---|---|
| Ethereum | [`0x000000000000B89C3cBDBBecb313Bd896b09144d`](https://etherscan.io/address/0x000000000000B89C3cBDBBecb313Bd896b09144d) | [`0x000000002f8c58a122F28C7CC8d644227a8FBa06`](https://etherscan.io/address/0x000000002f8c58a122F28C7CC8d644227a8FBa06) |
| Goerli | [`0x000000000000B89C3cBDBBecb313Bd896b09144d`](https://goerli.etherscan.io/address/0x000000000000B89C3cBDBBecb313Bd896b09144d) | [`0x000000002f8c58a122F28C7CC8d644227a8FBa06`](https://goerli.etherscan.io/address/0x000000002f8c58a122F28C7CC8d644227a8FBa06) |
| Polygon | [`0x000000000000B89C3cBDBBecb313Bd896b09144d`](https://polygonscan.com/address/0x000000000000B89C3cBDBBecb313Bd896b09144d) | [`0x000000002f8c58a122F28C7CC8d644227a8FBa06`](https://polygonscan.com/address/0x000000002f8c58a122F28C7CC8d644227a8FBa06) |
| Mumbai | [`0x000000000000B89C3cBDBBecb313Bd896b09144d`](https://mumbai.polygonscan.com/address/0x000000000000B89C3cBDBBecb313Bd896b09144d) | [`0x000000002f8c58a122F28C7CC8d644227a8FBa06`](https://mumbai.polygonscan.com/address/0x000000002f8c58a122F28C7CC8d644227a8FBa06) |


Please open an issue if you need help to deploy to an EVM chain of your choice.

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

  ERC721 or ERC1155 compliant contracts that can override  
  `isApprovedForAll(address collector, address operator)` to consult the registry,  
  returning true if the operator is pre-approved by the specified lister which the collector is subscribed to.

- Registry

  The PreApproveRegistry which can allow collectors to subscribe to listers, and listers to add/remove operators. 

## Security

- Collectors can subscribe and unsubscribe to the lister which is queried by NFT contracts. Subscription is opt-in.

- A lister can add operators, but takes 7 days to take effect. 

- A lister can remove operators immediately anytime, even if the operator is not yet in effect.

- The list of operators managed by a lister can only be modified by the lister.

- A lister can be an EOA or a smart contract.   

  We highly recommend using our pre-approve lister factory to create a lister contract with the following security benefits:  

    - Ability for a separate locker address to lock the lister anytime, in case the lister's owner is compromised.

    - Once locked:
      - No more operators can be added by the owner.
      - The list of operators can be emptied immediately by any account (flight back to default safety).

    - We highly recommend using a multisig for the lister's owner, and an EOA for the locker.   
      This is because a multisig's signers may be changed immediately if it is compromised.   
      The locker EOA should not be part of the owner multisig.

    - A backup locker is configurable by the owner in case the locker cannot be accessed (e.g. private key lost). 

    - The owner, the locker, and the backup locker, cannot be changed once initialized.

## Safety

The codebase has gone though intensive internal reviews by a16z crypto and soundxyz engineers.

Nevertheless, this codebase is provided on an "as is" and "as available" basis.

We **do not give any warranties** and **will not be liable for any loss** incurred through any use of this codebase.

## Acknowledgements

This repository is inspired by and directly modified from:

- [Seaport](https://github.com/ProjectOpenSea/seaport)
- [ClosedSea](https://github.com/vectorized/closedsea)


[npm-shield]: https://img.shields.io/npm/v/preapprove.svg
[npm-url]: https://www.npmjs.com/package/preapprove

[ci-shield]: https://img.shields.io/github/actions/workflow/status/vectorized/preapprove/ci.yml?label=build&branch=main
[ci-url]: https://github.com/vectorized/preapprove/actions/workflows/ci.yml

[license-shield]: https://img.shields.io/badge/License-MIT-green.svg
[license-url]: https://github.com/vectorized/preapprove/blob/main/LICENSE.txt
