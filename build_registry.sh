rm -r _tmp > /dev/null 2>&1;
mkdir _tmp > /dev/null 2>&1;
mkdir _tmp/src > /dev/null 2>&1;

cp src/PreApproveRegistry.sol _tmp;
cp src/EnumerableAddressSetMap.sol _tmp;

forge build --out="out" --root="_tmp" --contracts="." --via-ir --optimize --optimizer-runs=1000000 --use=0.8.17;

mkdir registry > /dev/null 2>&1;

echo '
const fs = require("fs");
fs.writeFileSync(
    "registry/initcode.txt", 
    JSON.parse(fs.readFileSync("_tmp/out/PreApproveRegistry.sol/PreApproveRegistry.json", { encoding: "utf8", flag: "r" }))["bytecode"]["object"].slice(2)
);' > _tmp/extract_initcode.js;

node _tmp/extract_initcode.js;

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
);' > _tmp/generate_input_json.js;

node _tmp/generate_input_json.js;

echo '{
    "name": "",
    "version": "0.0.1",
    "description": "",
    "devDependencies": {
        "ethers": "^5.7.2"
    }
}' > _tmp/package.json;

cd _tmp;
npm install; 
cd ..;

echo '
const fs = require("fs");
const ethers = require("ethers");
fs.writeFileSync(
    "registry/initcodehash.txt", 
    ethers.utils.keccak256("0x" + fs.readFileSync("registry/initcode.txt", { encoding: "utf8", flag: "r" }))
);' > _tmp/generate_initcodehash.js;


node _tmp/generate_initcodehash.js;

rm -r _tmp > /dev/null 2>&1;
