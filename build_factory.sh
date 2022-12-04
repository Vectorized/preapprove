mkdir .tmp > /dev/null 2>&1;

cp src/PreApproveListerFactory.sol .tmp;
cp lib/solady/src/utils/LibClone.sol .tmp;

echo '
const fs = require("fs");
const p = ".tmp/PreApproveListerFactory.sol";
fs.writeFileSync(
    p, 
    fs.readFileSync(p, { encoding: "utf8", flag: "r" })
    .replace(/import\s*?\"solady\/utils\/LibClone\.sol\"/, "import \"./LibClone.sol\"")
);' > .tmp/replace_imports.js;

node .tmp/replace_imports.js;

forge build --out="out" --root=".tmp" --contracts="." --optimize --optimizer-runs=200 --use=0.8.17;

mkdir factory > /dev/null 2>&1;

echo '
const fs = require("fs");
fs.writeFileSync(
    "factory/initcode.txt", 
    JSON.parse(fs.readFileSync(".tmp/out/PreApproveListerFactory.sol/PreApproveListerFactory.json", { encoding: "utf8", flag: "r" }))["bytecode"]["object"].slice(2)
);' > .tmp/extract_initcode.js;

node .tmp/extract_initcode.js;

echo '
const fs = require("fs");
fs.writeFileSync(
    "factory/input.json", 
    JSON.stringify({
        "language": "Solidity",
        "sources": {
            "PreApproveListerFactory.sol": {
                "content": fs.readFileSync(".tmp/PreApproveListerFactory.sol", { encoding: "utf8", flag: "r" })
            },
            "LibClone.sol": {
                "content": fs.readFileSync(".tmp/LibClone.sol", { encoding: "utf8", flag: "r" })
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
    "factory/initcodehash.txt", 
    ethers.utils.keccak256("0x" + fs.readFileSync("factory/initcode.txt", { encoding: "utf8", flag: "r" }))
);' > .tmp/generate_initcodehash.js;


node .tmp/generate_initcodehash.js;

rm -r .tmp/*.js > /dev/null 2>&1;
rm -r .tmp/*.sol > /dev/null 2>&1;

