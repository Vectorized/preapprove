// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./PreApproveRegistry.t.sol";
import "solady/utils/LibString.sol";

interface IImmutableCreate2Factory {
    function safeCreate2(bytes32 salt, bytes calldata initializationCode)
        external
        payable
        returns (address deploymentAddress);
}

contract PreApproveRegistryVanityTest is PreApproveRegistryTest {
    bytes constant IMMUTABLE_CREATE2_FACTORY_BYTECODE =
        hex"60806040526004361061003f5760003560e01c806308508b8f1461004457806364e030871461009857806385cf97ab14610138578063a49a7c90146101bc575b600080fd5b34801561005057600080fd5b506100846004803603602081101561006757600080fd5b503573ffffffffffffffffffffffffffffffffffffffff166101ec565b604080519115158252519081900360200190f35b61010f600480360360408110156100ae57600080fd5b813591908101906040810160208201356401000000008111156100d057600080fd5b8201836020820111156100e257600080fd5b8035906020019184600183028401116401000000008311171561010457600080fd5b509092509050610217565b6040805173ffffffffffffffffffffffffffffffffffffffff9092168252519081900360200190f35b34801561014457600080fd5b5061010f6004803603604081101561015b57600080fd5b8135919081019060408101602082013564010000000081111561017d57600080fd5b82018360208201111561018f57600080fd5b803590602001918460018302840111640100000000831117156101b157600080fd5b509092509050610592565b3480156101c857600080fd5b5061010f600480360360408110156101df57600080fd5b508035906020013561069e565b73ffffffffffffffffffffffffffffffffffffffff1660009081526020819052604090205460ff1690565b600083606081901c33148061024c57507fffffffffffffffffffffffffffffffffffffffff0000000000000000000000008116155b6102a1576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825260458152602001806107746045913960600191505060405180910390fd5b606084848080601f0160208091040260200160405190810160405280939291908181526020018383808284376000920182905250604051855195965090943094508b93508692506020918201918291908401908083835b6020831061033557805182527fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe090920191602091820191016102f8565b51815160209384036101000a7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff018019909216911617905260408051929094018281037fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe00183528085528251928201929092207fff000000000000000000000000000000000000000000000000000000000000008383015260609890981b7fffffffffffffffffffffffffffffffffffffffff00000000000000000000000016602183015260358201969096526055808201979097528251808203909701875260750182525084519484019490942073ffffffffffffffffffffffffffffffffffffffff81166000908152938490529390922054929350505060ff16156104a7576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040180806020018281038252603f815260200180610735603f913960400191505060405180910390fd5b81602001825188818334f5955050508073ffffffffffffffffffffffffffffffffffffffff168473ffffffffffffffffffffffffffffffffffffffff161461053a576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825260468152602001806107b96046913960600191505060405180910390fd5b50505073ffffffffffffffffffffffffffffffffffffffff8116600090815260208190526040902080547fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff001660011790559392505050565b6000308484846040516020018083838082843760408051919093018181037fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe001825280845281516020928301207fff000000000000000000000000000000000000000000000000000000000000008383015260609990991b7fffffffffffffffffffffffffffffffffffffffff000000000000000000000000166021820152603581019790975260558088019890985282518088039098018852607590960182525085519585019590952073ffffffffffffffffffffffffffffffffffffffff81166000908152948590529490932054939450505060ff909116159050610697575060005b9392505050565b604080517fff000000000000000000000000000000000000000000000000000000000000006020808301919091523060601b6021830152603582018590526055808301859052835180840390910181526075909201835281519181019190912073ffffffffffffffffffffffffffffffffffffffff81166000908152918290529190205460ff161561072e575060005b9291505056fe496e76616c696420636f6e7472616374206372656174696f6e202d20636f6e74726163742068617320616c7265616479206265656e206465706c6f7965642e496e76616c69642073616c74202d206669727374203230206279746573206f66207468652073616c74206d757374206d617463682063616c6c696e6720616464726573732e4661696c656420746f206465706c6f7920636f6e7472616374207573696e672070726f76696465642073616c7420616e6420696e697469616c697a6174696f6e20636f64652ea265627a7a723058202bdc55310d97c4088f18acf04253db593f0914059f0c781a9df3624dcef0d1cf64736f6c634300050a0032";

    bytes constant PRE_APPROVE_REGISTRY_INITCODE =
        hex"6080604052610914806100136000396000f3fe6080604052600436106100dd5760003560e01c80635f715b8e1161007f5780637262561c116100595780637262561c146102875780639870d7fe1461029a578063ac8a584a146102ad578063f046395a146102c057600080fd5b80635f715b8e1461020f5780636303710d14610247578063653548bf1461026757600080fd5b80634cb298cd116100bb5780634cb298cd146101685780634e2381e1146101985780634eb22bf6146101d8578063555dc0d9146101ef57600080fd5b80631085efc7146100e257806313e7c9d81461012657806341a7726a14610153575b600080fd5b3480156100ee57600080fd5b506101026100fd3660046107aa565b6102e0565b604080516001600160a01b0390931683526020830191909152015b60405180910390f35b34801561013257600080fd5b506101466101413660046107d4565b61030c565b60405161011d91906107ef565b6101666101613660046107d4565b61031f565b005b34801561017457600080fd5b5061018861018336600461083c565b610364565b604051901515815260200161011d565b3480156101a457600080fd5b506101ca6101b336600461083c565b6020526002600c9081523d91909152603490205490565b60405190815260200161011d565b3480156101e457600080fd5b506101ca62093a8081565b3480156101fb57600080fd5b5061018861020a36600461086f565b610387565b34801561021b57600080fd5b5061022f61022a3660046107aa565b6103c5565b6040516001600160a01b03909116815260200161011d565b34801561025357600080fd5b506101ca6102623660046107d4565b6103d2565b34801561027357600080fd5b506101ca6102823660046107d4565b6103f0565b6101666102953660046107d4565b61040e565b6101666102a83660046107d4565b610453565b6101666102bb3660046107d4565b6104c1565b3480156102cc57600080fd5b506101466102db3660046107d4565b610523565b6000806102ef60018585610530565b9150816020526002600c52833d526034600c205490509250929050565b6060610319600183610577565b92915050565b61032b600033836105ec565b6040516001600160a01b0382169033907f5af76814d21ef4a656d75bdbdb9cc3efa85af5efca9dbca0397824217d9344b790600090a350565b6000610380818484602052600c9182523d526034902054151590565b9392505050565b6000816020523d600c52823d526034600c20546103a45760206060f35b836020526002600c52813d526034600c2054804210811517153d525060203df35b6000610380818484610530565b6001600160a01b038116600090815260016020526040812054610319565b6001600160a01b038116600090815260208190526040812054610319565b61041a60003383610671565b6040516001600160a01b0382169033907f7773c30acd0762ed6b4b92a9aa2c6b3c074e29ad93b334cbed8ba807c596f13a90600090a350565b61045f600133836105ec565b600062093a8042019050816020526002600c52333d52806034600c205580826001600160a01b0316336001600160a01b03167f20c899c9053446f0d7a408c709f0196e2c26c6a985dcad854dc19ad567c4531f60405160405180910390a45050565b6104cd60013383610671565b806020526002600c52333d523d6034600c2055806001600160a01b0316336001600160a01b03167f17d7f044d47e4fae1701f86266d0a674db3f792671bd1b974ace77a09af1c82760405160405180910390a350565b6060610319600083610577565b6001600160a01b038216600090815260208490526040812080548390811061055a5761055a6108b2565b6000918252602090912001546001600160a01b0316949350505050565b6001600160a01b038116600090815260208381526040918290208054835181840281018401909452808452606093928301828280156105df57602002820191906000526020600020905b81546001600160a01b031681526001909101906020018083116105c1575b5050505050905092915050565b610606838383602052600c9182523d526034902054151590565b61066c576001600160a01b038281166000908152602085815260408220805460018101825581845292829020909201805473ffffffffffffffffffffffffffffffffffffffff1916938516939093179092555490829052600c8481523d84905260349020555b505050565b6020819052600c8381523d839052603490208054908115610787576001600160a01b0384166000908152602086905260409020805460001990810190840180821461073f5760008383815481106106ca576106ca6108b2565b9060005260206000200160009054906101000a90046001600160a01b03169050808483815481106106fd576106fd6108b2565b9060005260206000200160006101000a8154816001600160a01b0302191690836001600160a01b031602179055508060205288600c52873d52856034600c2055505b8280548061074f5761074f6108c8565b6000828152602081208201600019908101805473ffffffffffffffffffffffffffffffffffffffff1916905590910190915584555050505b5050505050565b80356001600160a01b03811681146107a557600080fd5b919050565b600080604083850312156107bd57600080fd5b6107c68361078e565b946020939093013593505050565b6000602082840312156107e657600080fd5b6103808261078e565b6020808252825182820181905260009190848201906040850190845b818110156108305783516001600160a01b03168352928401929184019160010161080b565b50909695505050505050565b6000806040838503121561084f57600080fd5b6108588361078e565b91506108666020840161078e565b90509250929050565b60008060006060848603121561088457600080fd5b61088d8461078e565b925061089b6020850161078e565b91506108a96040850161078e565b90509250925092565b634e487b7160e01b600052603260045260246000fd5b634e487b7160e01b600052603160045260246000fdfea264697066735822122017d83b73b451e62141b3c6ca993868584563ba9d484c4d8daa38f774a0bf70de64736f6c63430008110033";

    bytes32 constant PRE_APPROVE_REGISTRY_CREATE2_SALT =
        0x00000000000000000000000000000000000000002394e68f25b67e0220000000;

    address constant PRE_APPROVE_REGISTRY_CREATE2_DEPLOYED_ADDRESS =
        address(0x0000000000220203551AC16f0e2AcC221A7857Cd);

    function testGetInitcodeHash() public view {
        console.log(
            LibString.toHexString(uint256(keccak256(type(PreApproveRegistry).creationCode)), 32)
        );
    }

    function setUp() public virtual override {
        address factory = address(0x0000000000FFe8B47B3e2130213B802212439497);
        vm.etch(factory, bytes(IMMUTABLE_CREATE2_FACTORY_BYTECODE));
        address created = IImmutableCreate2Factory(factory).safeCreate2(
            PRE_APPROVE_REGISTRY_CREATE2_SALT, bytes(PRE_APPROVE_REGISTRY_INITCODE)
        );
        registry = PreApproveRegistry(created);
    }

    function testGetCreate2DeployedAddress() public {
        assertEq(address(registry), PRE_APPROVE_REGISTRY_CREATE2_DEPLOYED_ADDRESS);
    }
}
