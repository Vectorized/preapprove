mkdir .tmp > /dev/null 2>&1;

cp src/PreApproveLister.sol .tmp;
cp lib/solady/src/auth/Ownable.sol .tmp;

echo '
const fs = require("fs");
const p = ".tmp/PreApproveLister.sol";
fs.writeFileSync(
    p, 
    fs.readFileSync(p, { encoding: "utf8", flag: "r" })
    .replace(/import\s*?\"solady\/auth\/Ownable\.sol\"/, "import \"./Ownable.sol\"")
);' > .tmp/replace_imports.js;

node .tmp/replace_imports.js;

forge build --out="out" --root=".tmp" --contracts="." --via-ir --optimize --optimizer-runs=200 --use=0.8.17;

mkdir lister > /dev/null 2>&1;

echo '
const fs = require("fs");
fs.writeFileSync(
    "lister/initcode.txt", 
    JSON.parse(fs.readFileSync(".tmp/out/PreApproveLister.sol/PreApproveLister.json", { encoding: "utf8", flag: "r" }))["bytecode"]["object"].slice(2)
);' > .tmp/extract_initcode.js;

node .tmp/extract_initcode.js;

echo '
const fs = require("fs");
fs.writeFileSync(
    "lister/input.json", 
    JSON.stringify({
        "language": "Solidity",
        "sources": {
            "PreApproveLister.sol": {
                "content": fs.readFileSync(".tmp/PreApproveLister.sol", { encoding: "utf8", flag: "r" })
            },
            "Ownable.sol": {
                "content": fs.readFileSync(".tmp/Ownable.sol", { encoding: "utf8", flag: "r" })
            },
        },
        "settings": {
            "optimizer": {
                "enabled": true,
                "runs": 200
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
    "lister/initcodehash.txt", 
    ethers.utils.keccak256("0x" + fs.readFileSync("lister/initcode.txt", { encoding: "utf8", flag: "r" }))
);' > .tmp/generate_initcodehash.js;


node .tmp/generate_initcodehash.js;

rm -r .tmp/*.js > /dev/null 2>&1;
rm -r .tmp/*.sol > /dev/null 2>&1;
