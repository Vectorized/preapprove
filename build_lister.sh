rm -r _tmp_lister > /dev/null 2>&1;
mkdir _tmp_lister > /dev/null 2>&1;
mkdir _tmp_lister/src > /dev/null 2>&1;

cp src/PreApproveLister.sol _tmp_lister;
cp lib/solady/src/auth/Ownable.sol _tmp_lister;

forge build --out="out" --root="_tmp_lister" --contracts="." --remappings="solady/auth/=." --via-ir --optimize --optimizer-runs=200 --use=0.8.17;

mkdir lister > /dev/null 2>&1;

echo '
const fs = require("fs");
fs.writeFileSync(
    "lister/initcode.txt", 
    JSON.parse(fs.readFileSync("_tmp_lister/out/PreApproveLister.sol/PreApproveLister.json", { encoding: "utf8", flag: "r" }))["bytecode"]["object"].slice(2)
);' > _tmp_lister/extract_initcode.js;

node _tmp_lister/extract_initcode.js;

echo '
const fs = require("fs");
fs.writeFileSync(
    "lister/input.json", 
    JSON.stringify({
        "language": "Solidity",
        "sources": {
            "PreApproveLister.sol": {
                "content": fs.readFileSync("_tmp_lister/PreApproveLister.sol", { encoding: "utf8", flag: "r" })
            },
            "Ownable.sol": {
                "content": fs.readFileSync("_tmp_lister/Ownable.sol", { encoding: "utf8", flag: "r" })
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
);' > _tmp_lister/generate_input_json.js;

node _tmp_lister/generate_input_json.js;

echo '{
    "name": "",
    "version": "0.0.1",
    "description": "",
    "devDependencies": {
        "ethers": "^5.7.2"
    }
}' > _tmp_lister/package.json;

cd _tmp_lister;
npm install; 
cd ..;

echo '
const fs = require("fs");
const ethers = require("ethers");
fs.writeFileSync(
    "lister/initcodehash.txt", 
    ethers.utils.keccak256("0x" + fs.readFileSync("lister/initcode.txt", { encoding: "utf8", flag: "r" }))
);' > _tmp_lister/generate_initcodehash.js;


node _tmp_lister/generate_initcodehash.js;

rm -r _tmp_lister > /dev/null 2>&1;
