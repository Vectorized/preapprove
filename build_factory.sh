rm -r _tmp_factory > /dev/null 2>&1;
mkdir _tmp_factory > /dev/null 2>&1;
mkdir _tmp_factory/src > /dev/null 2>&1;

cp src/PreApproveListerFactory.sol _tmp_factory;
cp lib/solady/src/utils/LibClone.sol _tmp_factory;

forge build --out="out" --root="_tmp_factory" --contracts="." --remappings="solady/utils/=." --via-ir --optimize --optimizer-runs=200 --use=0.8.17;

mkdir factory > /dev/null 2>&1;

echo '
const fs = require("fs");
fs.writeFileSync(
    "factory/initcode.txt", 
    JSON.parse(fs.readFileSync("_tmp_factory/out/PreApproveListerFactory.sol/PreApproveListerFactory.json", { encoding: "utf8", flag: "r" }))["bytecode"]["object"].slice(2)
);' > _tmp_factory/extract_initcode.js;

node _tmp_factory/extract_initcode.js;

echo '
const fs = require("fs");
fs.writeFileSync(
    "factory/input.json", 
    JSON.stringify({
        "language": "Solidity",
        "sources": {
            "PreApproveListerFactory.sol": {
                "content": fs.readFileSync("_tmp_factory/PreApproveListerFactory.sol", { encoding: "utf8", flag: "r" })
            },
            "LibClone.sol": {
                "content": fs.readFileSync("_tmp_factory/LibClone.sol", { encoding: "utf8", flag: "r" })
            },
        },
        "settings": {
            "optimizer": {
                "enabled": true,
                "runs": 200
            },
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
);' > _tmp_factory/generate_input_json.js;

node _tmp_factory/generate_input_json.js;

echo '{
    "name": "",
    "version": "0.0.1",
    "description": "",
    "devDependencies": {
        "ethers": "^5.7.2"
    }
}' > _tmp_factory/package.json;

cd _tmp_factory;
npm install; 
cd ..;

echo '
const fs = require("fs");
const ethers = require("ethers");
fs.writeFileSync(
    "factory/initcodehash.txt", 
    ethers.utils.keccak256("0x" + fs.readFileSync("factory/initcode.txt", { encoding: "utf8", flag: "r" }))
);' > _tmp_factory/generate_initcodehash.js;


node _tmp_factory/generate_initcodehash.js;

rm -r _tmp_factory > /dev/null 2>&1;
