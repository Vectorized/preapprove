mkdir .tmp > /dev/null 2>&1;

cp src/PreApproveRegistry.sol .tmp;
cp src/EnumerableAddressSetMap.sol .tmp;

forge build --out="out" --root=".tmp" --contracts="." --via-ir --optimize --optimizer-runs=1000000 --use=0.8.17;

mkdir registry > /dev/null 2>&1;

echo '
const fs = require("fs");
fs.writeFileSync(
    "registry/initcode.txt", 
    JSON.parse(fs.readFileSync(".tmp/out/PreApproveRegistry.sol/PreApproveRegistry.json", { encoding: "utf8", flag: "r" }))["bytecode"]["object"].slice(2)
);' > .tmp/extract_initcode.js;

node .tmp/extract_initcode.js;

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
);' > .tmp/generate_input_json.js;

node .tmp/generate_input_json.js;

echo '{
    "name": "",
    "version": "0.0.1",
    "description": "",
    "devDependencies": {
        "ethers": "^5.7.2"
    }
}' > .tmp/package.json;

if [ ! -f .tmp/package-lock.json ]; then
    cd .tmp;
    npm install; 
    cd ..;
fi

echo '
const fs = require("fs");
const ethers = require("ethers");
fs.writeFileSync(
    "registry/initcodehash.txt", 
    ethers.utils.keccak256("0x" + fs.readFileSync("registry/initcode.txt", { encoding: "utf8", flag: "r" }))
);' > .tmp/generate_initcodehash.js;


node .tmp/generate_initcodehash.js;

rm -r .tmp/*.js > /dev/null 2>&1;
rm -r .tmp/*.sol > /dev/null 2>&1;
