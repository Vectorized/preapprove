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

contract PreApproveVanityTest is PreApproveRegistryTest {
    bytes public constant IMMUTABLE_CREATE2_FACTORY_BYTECODE =
        hex"60806040526004361061003f5760003560e01c806308508b8f1461004457806364e030871461009857806385cf97ab14610138578063a49a7c90146101bc575b600080fd5b34801561005057600080fd5b506100846004803603602081101561006757600080fd5b503573ffffffffffffffffffffffffffffffffffffffff166101ec565b604080519115158252519081900360200190f35b61010f600480360360408110156100ae57600080fd5b813591908101906040810160208201356401000000008111156100d057600080fd5b8201836020820111156100e257600080fd5b8035906020019184600183028401116401000000008311171561010457600080fd5b509092509050610217565b6040805173ffffffffffffffffffffffffffffffffffffffff9092168252519081900360200190f35b34801561014457600080fd5b5061010f6004803603604081101561015b57600080fd5b8135919081019060408101602082013564010000000081111561017d57600080fd5b82018360208201111561018f57600080fd5b803590602001918460018302840111640100000000831117156101b157600080fd5b509092509050610592565b3480156101c857600080fd5b5061010f600480360360408110156101df57600080fd5b508035906020013561069e565b73ffffffffffffffffffffffffffffffffffffffff1660009081526020819052604090205460ff1690565b600083606081901c33148061024c57507fffffffffffffffffffffffffffffffffffffffff0000000000000000000000008116155b6102a1576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825260458152602001806107746045913960600191505060405180910390fd5b606084848080601f0160208091040260200160405190810160405280939291908181526020018383808284376000920182905250604051855195965090943094508b93508692506020918201918291908401908083835b6020831061033557805182527fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe090920191602091820191016102f8565b51815160209384036101000a7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff018019909216911617905260408051929094018281037fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe00183528085528251928201929092207fff000000000000000000000000000000000000000000000000000000000000008383015260609890981b7fffffffffffffffffffffffffffffffffffffffff00000000000000000000000016602183015260358201969096526055808201979097528251808203909701875260750182525084519484019490942073ffffffffffffffffffffffffffffffffffffffff81166000908152938490529390922054929350505060ff16156104a7576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040180806020018281038252603f815260200180610735603f913960400191505060405180910390fd5b81602001825188818334f5955050508073ffffffffffffffffffffffffffffffffffffffff168473ffffffffffffffffffffffffffffffffffffffff161461053a576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825260468152602001806107b96046913960600191505060405180910390fd5b50505073ffffffffffffffffffffffffffffffffffffffff8116600090815260208190526040902080547fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff001660011790559392505050565b6000308484846040516020018083838082843760408051919093018181037fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe001825280845281516020928301207fff000000000000000000000000000000000000000000000000000000000000008383015260609990991b7fffffffffffffffffffffffffffffffffffffffff000000000000000000000000166021820152603581019790975260558088019890985282518088039098018852607590960182525085519585019590952073ffffffffffffffffffffffffffffffffffffffff81166000908152948590529490932054939450505060ff909116159050610697575060005b9392505050565b604080517fff000000000000000000000000000000000000000000000000000000000000006020808301919091523060601b6021830152603582018590526055808301859052835180840390910181526075909201835281519181019190912073ffffffffffffffffffffffffffffffffffffffff81166000908152918290529190205460ff161561072e575060005b9291505056fe496e76616c696420636f6e7472616374206372656174696f6e202d20636f6e74726163742068617320616c7265616479206265656e206465706c6f7965642e496e76616c69642073616c74202d206669727374203230206279746573206f66207468652073616c74206d757374206d617463682063616c6c696e6720616464726573732e4661696c656420746f206465706c6f7920636f6e7472616374207573696e672070726f76696465642073616c7420616e6420696e697469616c697a6174696f6e20636f64652ea265627a7a723058202bdc55310d97c4088f18acf04253db593f0914059f0c781a9df3624dcef0d1cf64736f6c634300050a0032";

    address public constant IMMUTABLE_CREATE2_FACTORY_ADDRESS =
        0x0000000000FFe8B47B3e2130213B802212439497;

    // PreApproveRegistry.

    bytes public constant PRE_APPROVE_REGISTRY_INITCODE =
        hex"608080604052610caf90816100128239f3fe6040608081526004908136101561001557600080fd5b600090813560e01c80631085efc714610b3257806313e7c9d814610a4b57806341a7726a146109345780634cb298cd146108db5780634e2381e1146108835780634eb22bf614610848578063555dc0d9146107aa5780635f715b8e146107365780636303710d146106d5578063653548bf146106755780637262561c146104ff5780639870d7fe146103c5578063ac8a584a146101d65763f046395a146100bb57600080fd5b346101d257602090817ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc3601126101ce5773ffffffffffffffffffffffffffffffffffffffff8061010a610bbf565b16845283835281842082519384859382845492838152019388528288209288915b8383106101b257505050505003601f017fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe01682019267ffffffffffffffff8411838510176101865750829182610182925282610c0a565b0390f35b806041867f4e487b71000000000000000000000000000000000000000000000000000000006024945252fd5b845481168652889650948101946001948501949092019161012b565b8280fd5b5080fd5b5060207ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc3601126101d257610209610bbf565b9081602052600c9060018252333d52603482209081549081610278575b8573ffffffffffffffffffffffffffffffffffffffff86868160205260028152333d5260343d91205516337f17d7f044d47e4fae1701f86266d0a674db3f792671bd1b974ace77a09af1c8278380a380f35b33865260016020528520907fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff908183540182820190818103610345575b50505081548015610319578697509073ffffffffffffffffffffffffffffffffffffffff96939291019061030e6102ec8383610c5b565b73ffffffffffffffffffffffffffffffffffffffff82549160031b1b19169055565b555583923880610226565b60248760318a7f4e487b7100000000000000000000000000000000000000000000000000000000835252fd5b61037c9173ffffffffffffffffffffffffffffffffffffffff61036b6103ae9388610c5b565b90549060031b1c1692839187610c5b565b90919082549060031b9173ffffffffffffffffffffffffffffffffffffffff9283811b93849216901b16911916179055565b60205260018552333d5260348520553880806102b5565b5060207ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc3601126101d2576103f8610bbf565b9081602052600c9060018252333d5260348220541561046b575b5060349173ffffffffffffffffffffffffffffffffffffffff9162093a8042019384918360205260028152333d52205516337f20c899c9053446f0d7a408c709f0196e2c26c6a985dcad854dc19ad567c4531f8480a480f35b338452600160205283208054680100000000000000008110156104d3576034949550906104b98461037c84600173ffffffffffffffffffffffffffffffffffffffff98979601855584610c5b565b548260205260018252333d52848220559091849350610412565b6024856041887f4e487b7100000000000000000000000000000000000000000000000000000000835252fd5b5060207ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc3601126101d257610532610bbf565b908160205282600c52333d526034600c20908154908161058d575b8473ffffffffffffffffffffffffffffffffffffffff8516337f7773c30acd0762ed6b4b92a9aa2c6b3c074e29ad93b334cbed8ba807c596f13a8380a380f35b338552846020528420907fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff908183540182820190818103610637575b5050508154801561060b578596509073ffffffffffffffffffffffffffffffffffffffff9593929101906106006102ec8383610c5b565b55558291388061054d565b6024866031897f4e487b7100000000000000000000000000000000000000000000000000000000835252fd5b61037c9173ffffffffffffffffffffffffffffffffffffffff61036b61065d9388610c5b565b60205285600c52333d526034600c20553880806105c9565b50346101d25760207ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc3601126101d2578060209273ffffffffffffffffffffffffffffffffffffffff6106c6610bbf565b16815280845220549051908152f35b50346101d25760207ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc3601126101d2578060209273ffffffffffffffffffffffffffffffffffffffff610726610bbf565b1681526001845220549051908152f35b50346101d257807ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc3601126101d25760209161079b73ffffffffffffffffffffffffffffffffffffffff918261078a610bbf565b168152808552836024359120610c5b565b92905490519260031b1c168152f35b82346108455760607ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc360112610845576107e2610bbf565b6107ea610be7565b6044359273ffffffffffffffffffffffffffffffffffffffff841684036108455750826020523d600c523d526034600c20541561083f576020526002600c523d526034600c2054804210901517153d5260203df35b60206060f35b80fd5b50346101d257817ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc3601126101d2576020905162093a808152f35b50346101d257807ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc3601126101d2576020906108bd610bbf565b6108c5610be7565b83526002600c523d526034600c20549051908152f35b50346101d257807ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc3601126101d257602091610915610bbf565b9061091e610be7565b8452600c523d526034600c205415159051908152f35b5060207ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc3601126101d257610967610bbf565b908160205282600c52333d526034600c2054156109be575b5073ffffffffffffffffffffffffffffffffffffffff16337f5af76814d21ef4a656d75bdbdb9cc3efa85af5efca9dbca0397824217d9344b78380a380f35b338352826020528220805468010000000000000000811015610a1f5773ffffffffffffffffffffffffffffffffffffffff9394508261037c826001610a069401855584610c5b565b548160205283600c52333d526034600c2055829161097f565b6024846041877f4e487b7100000000000000000000000000000000000000000000000000000000835252fd5b50346101d257602090817ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc3601126101ce5773ffffffffffffffffffffffffffffffffffffffff80610a9b610bbf565b1684526001928381528285209083519485869483855492838152019489528389209389915b838310610b185750505050505003601f017fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe01682019267ffffffffffffffff8411838510176101865750829182610182925282610c0a565b855481168752899750958101959484019491840191610ac0565b50903461084557817ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc36011261084557610b6a610bbf565b90610b9973ffffffffffffffffffffffffffffffffffffffff9182841681526001602052846024359120610c5b565b90549060031b1c1690816020526002600c523d526034600c205482519182526020820152f35b6004359073ffffffffffffffffffffffffffffffffffffffff82168203610be257565b600080fd5b6024359073ffffffffffffffffffffffffffffffffffffffff82168203610be257565b6020908160408183019282815285518094520193019160005b828110610c31575050505090565b835173ffffffffffffffffffffffffffffffffffffffff1685529381019392810192600101610c23565b8054821015610c735760005260206000200190600090565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052603260045260246000fdfea164736f6c6343000811000a";

    bytes32 public constant PRE_APPROVE_REGISTRY_INITCODEHASH =
        0xe5f4dcbc00aa1c7938f7a765b020d0542d5e84b1670f5485c836e2ecf92b1544;

    bytes32 public constant PRE_APPROVE_REGISTRY_CREATE2_SALT =
        0x0000000000000000000000000000000000000000cb040b15245d2c156c49218b;

    address public constant PRE_APPROVE_REGISTRY_CREATE2_DEPLOYED_ADDRESS =
        0x00000000000044dfA889ebC2C5103067Ec23332f;

    // PreApproveLister.

    bytes public constant PRE_APPROVE_LISTER_IMPLEMENTATION_INITCODE =
        hex"6080806040526103de90816100128239f3fe6040608081526004908136101561001557600080fd5b600091823560e01c8063256929621461034957806354d1f13d14610303578063715018a6146102cf5780638da5cb5b146102a25780639870d7fe1461022f578063a596678214610279578063ac8a584a1461022f578063c4d66de8146101dc578063d7533f02146101be578063f04e283e14610145578063f2fde38b146100e35763fee81cf4146100a557600080fd5b346100df5760203660031901126100df57356001600160a01b03811681036100df5760209263389a75e1600c525281600c20549051908152f35b8280fd5b5060203660031901126100df5780356001600160a01b03811692908390036101415761010d610394565b8215610134575050638b78c6d8198181546000805160206103b28339815191528580a35580f35b51633a247dd760e11b8152fd5b8380fd5b508260203660031901126101bb5781356001600160a01b03811681036101b75761016d610394565b63389a75e1600c5281526020600c20805442116101ab57819055600c5160601c80336000805160206103b28339815191528480a3638b78c6d8195580f35b50636f5e88189052601cfd5b5080fd5b80fd5b5050346101b757816003193601126101b757602090516202a3008152f35b838260203660031901126101b757356001600160a01b038116908190036101b757815460ff81166100df5781600192638b78c6d81955836000805160206103b28339815191528180a360ff191617815580f35b838260203660031901126101b757356001600160a01b038116036101bb57610255610394565b60243d3d373d3d60243d3d6d44dfa889ebc2c5103067ec23332f5af1156101bb5780f35b5050346101b757816003193601126101b757602090516d44dfa889ebc2c5103067ec23332f8152f35b5050346101b757816003193601126101b757638b78c6d8195490516001600160a01b039091168152602090f35b83806003193601126101bb576102e3610394565b80638b78c6d8198181546000805160206103b28339815191528280a35580f35b83806003193601126101bb5763389a75e1600c52338152806020600c2055337ffa7b8eab7da67f412cc9575ed43464468f9bfbae89d1675917346ca6d8fe3c928280a280f35b83806003193601126101bb5763389a75e1600c523381526202a30042016020600c2055337fdbf36a107da19e49527a7176a1babf963b4b0ff8cde35ee35d6cd8f1f9ac7e1d8280a280f35b638b78c6d8195433036103a357565b6382b429006000526004601cfdfe8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0a164736f6c6343000811000a";

    bytes32 public constant PRE_APPROVE_LISTER_IMPLEMENTATION_INITCODEHASH =
        0x7d6a3aba5728e9d2e73a1175bd23a5673db6a851479797302feb4ad5c522a6b2;

    bytes32 public constant PRE_APPROVE_LISTER_IMPLEMENTATION_CREATE2_SALT =
        0x0000000000000000000000000000000000000000d5aade7585fe450b942e6db6;

    address public constant PRE_APPROVE_LISTER_IMPLEMENTATION_CREATE2_DEPLOYED_ADDRESS =
        0x00000000009B67ae8c62b36B8bdeBF507457DDbe;

    // PreApproveListerFactory.

    bytes public constant PRE_APPROVE_LISTER_FACTORY_INITCODE =
        hex"6080806040526102cc90816100128239f3fe604060808152600436101561001357600080fd5b6000803560e01c80634c96a389146102175780635414dff01461018f578063a8ba0e0b14610165578063db4c545e146101015763e919e3ea1461005557600080fd5b816003193601126100fe57610068610286565b916024358060601c803314901517156100f1576c5af43d3d93803e602a57fd5bf36021526e9b67ae8c62b36b8bdebf507457ddbe60145273602c3d8160093d39f33d3d3d3d363d3d37363d7383526035600c84f5918060215282156100e457506100d4602093836102a1565b516001600160a01b039091168152f35b633011642590526004601cfd5b632f63483683526004601cfd5b80fd5b509034610161578160031936011261016157906020916c5af43d3d93803e602a57fd5bf36021526e9b67ae8c62b36b8bdebf507457ddbe60145273602c3d8160093d39f33d3d3d3d363d3d37363d7382526035600c209160215251908152f35b5080fd5b509034610161578160031936011261016157602090516e9b67ae8c62b36b8bdebf507457ddbe8152f35b50903461016157602036600319011261016157906020916c5af43d3d93803e602a57fd5bf36021526e9b67ae8c62b36b8bdebf507457ddbe60145273602c3d8160093d39f33d3d3d3d363d3d37363d7382526035600c208260215260ff835360359081523060601b60015260043560155260558320929052516001600160a01b039091168152f35b5060203660031901126100fe5761022c610286565b916c5af43d3d93803e602a57fd5bf36021526e9b67ae8c62b36b8bdebf507457ddbe60145273602c3d8160093d39f33d3d3d3d363d3d37363d7382526035600c83f0918060215282156100e457506100d4602093836102a1565b600435906001600160a01b038216820361029c57565b600080fd5b9063c4d66de83d526020523d906024601c3d923d905af11561029c5756fea164736f6c6343000811000a";

    bytes32 public constant PRE_APPROVE_LISTER_FACTORY_INITCODEHASH =
        0x7b608b760104a61f52c17fa12a75167eebd497bec5ab496acb2a8e25bd3ac743;

    bytes32 public constant PRE_APPROVE_LISTER_FACTORY_CREATE2_SALT =
        0x0000000000000000000000000000000000000000becd9b4915067908aed8a0f6;

    address public constant PRE_APPROVE_LISTER_FACTORY_CREATE2_DEPLOYED_ADDRESS =
        0x000000008eD362F72783dEEf4B485761b4909e53;

    function setUp() public virtual override {
        vm.etch(IMMUTABLE_CREATE2_FACTORY_ADDRESS, bytes(IMMUTABLE_CREATE2_FACTORY_BYTECODE));

        registry = PreApproveRegistry(
            IImmutableCreate2Factory(IMMUTABLE_CREATE2_FACTORY_ADDRESS).safeCreate2(
                PRE_APPROVE_REGISTRY_CREATE2_SALT, bytes(PRE_APPROVE_REGISTRY_INITCODE)
            )
        );

        assertEq(
            address(
                IImmutableCreate2Factory(IMMUTABLE_CREATE2_FACTORY_ADDRESS).safeCreate2(
                    PRE_APPROVE_LISTER_IMPLEMENTATION_CREATE2_SALT,
                    bytes(PRE_APPROVE_LISTER_IMPLEMENTATION_INITCODE)
                )
            ),
            PRE_APPROVE_LISTER_IMPLEMENTATION_CREATE2_DEPLOYED_ADDRESS
        );

        assertEq(
            address(
                IImmutableCreate2Factory(IMMUTABLE_CREATE2_FACTORY_ADDRESS).safeCreate2(
                    PRE_APPROVE_LISTER_FACTORY_CREATE2_SALT,
                    bytes(PRE_APPROVE_LISTER_FACTORY_INITCODE)
                )
            ),
            PRE_APPROVE_LISTER_FACTORY_CREATE2_DEPLOYED_ADDRESS
        );
    }

    function testInitcodehashes() public {
        assertEq(keccak256(bytes(PRE_APPROVE_REGISTRY_INITCODE)), PRE_APPROVE_REGISTRY_INITCODEHASH);
        assertEq(
            keccak256(bytes(PRE_APPROVE_LISTER_IMPLEMENTATION_INITCODE)),
            PRE_APPROVE_LISTER_IMPLEMENTATION_INITCODEHASH
        );
        assertEq(
            keccak256(bytes(PRE_APPROVE_LISTER_FACTORY_INITCODE)),
            PRE_APPROVE_LISTER_FACTORY_INITCODEHASH
        );
    }
}
