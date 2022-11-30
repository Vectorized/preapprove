# PreApprove

On-chain registry for pre-approvals of ERC721 transfers.

This codebase is still under construction.

TODO:

- A simple stateless library for calling `isPreApproved` on the registry in the most efficient way possible.

- ERC721A, ERC721, ERC1155 examples with overriden `isApprovedForAll`.

- For development and testing:

	- First, compile the registry and get its initcode.

	- Use `vm.etch` to write the bytecode of `0x0000000000ffe8b47b3e2130213b802212439497` (ImmutableCreate2Factory by z0age).

	- Call the `safeCreate2(bytes32 salt, bytes calldata initializationCode)` on ImmutableCreate2Factory.

	- Test if the registry works (subclass PreApproveRegistryTest).




