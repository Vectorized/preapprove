rm -r _tmp_registry > /dev/null 2>&1;
mkdir _tmp_registry > /dev/null 2>&1;
mkdir _tmp_registry/src > /dev/null 2>&1;

cp src/PreApproveRegistry.sol _tmp_registry;
cp src/EnumerableAddressSetMap.sol _tmp_registry;

forge build --out="out" --root="_tmp_registry" --contracts="." --via-ir --optimize --optimizer-runs=1000000 --use=0.8.17;

mkdir registry > /dev/null 2>&1;

echo '
const fs = require("fs");
fs.writeFileSync(
    "registry/initcode.txt", 
    JSON.parse(fs.readFileSync("_tmp_registry/out/PreApproveRegistry.sol/PreApproveRegistry.json", { encoding: "utf8", flag: "r" }))["bytecode"]["object"].slice(2)
);' > _tmp_registry/extract_initcode.js;

node _tmp_registry/extract_initcode.js;

echo '
const fs = require("fs");
fs.writeFileSync(
    "registry/input.json", 
    JSON.stringify({
        "language": "Solidity",
        "sources": {
            "PreApproveRegistry.sol": {
                "content": fs.readFileSync("src/PreApproveRegistry.sol", { encoding: "utf8", flag: "r" })
            },
            "EnumerableAddressSetMap.sol": {
                "content": fs.readFileSync("src/EnumerableAddressSetMap.sol", { encoding: "utf8", flag: "r" })
            },
        },
        "settings": {
            "remappings": [
                "solady/utils/=/"
            ],
            "optimizer": {
                "enabled": true,
                "runs": 1000000
            },
            "viaIR": true,
            "outputSelection": {
                "*": {
                    "*": [
                        "evm.bytecode",
                        "evm.deployedBytecode",
                        "abi"
                    ]
                }
            }
        }
    })
);' > _tmp_registry/generate_input_json.js;

node _tmp_registry/generate_input_json.js;

echo '{
    "name": "",
    "version": "0.0.1",
    "description": "",
    "devDependencies": {
        "ethers": "^5.7.2"
    }
}' > _tmp_registry/package.json;

cd _tmp_registry;
npm install; 
cd ..;

echo '
const fs = require("fs");
const ethers = require("ethers");
fs.writeFileSync(
    "registry/initcodehash.txt", 
    ethers.utils.keccak256("0x" + fs.readFileSync("registry/initcode.txt", { encoding: "utf8", flag: "r" }))
);' > _tmp_registry/generate_initcodehash.js;


node _tmp_registry/generate_initcodehash.js;

rm -r _tmp_registry > /dev/null 2>&1;
