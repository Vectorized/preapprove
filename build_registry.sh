mkdir .tmp > /dev/null 2>&1;

cp src/PreApproveRegistry.sol .tmp;
cp src/utils/EnumerableAddressSetMap.sol .tmp;

echo 'const fs = require("fs"), rfs = s => fs.readFileSync(s, { encoding: "utf8", flag: "r" });
const p = ".tmp/PreApproveRegistry.sol";
fs.writeFileSync(
    p, 
    rfs(p).replace(/import\s*?\"\.\/utils/, "import \".")
)' > .tmp/replace_imports.js;
node .tmp/replace_imports.js;

echo '[profile.default]
bytecode_hash="none"
' > .tmp/foundry.toml;

forge build --out="out" --root=".tmp" --contracts="." --via-ir --optimize --optimizer-runs=1000000 --use=0.8.17;

mkdir registry > /dev/null 2>&1;

echo 'const fs = require("fs"), rfs = s => fs.readFileSync(s, { encoding: "utf8", flag: "r" });
fs.writeFileSync(
    "registry/initcode.txt", 
    JSON.parse(rfs(".tmp/out/PreApproveRegistry.sol/PreApproveRegistry.json"))["bytecode"]["object"].slice(2)
)' > .tmp/extract_initcode.js;
node .tmp/extract_initcode.js;

echo 'const fs = require("fs"), rfs = s => fs.readFileSync(s, { encoding: "utf8", flag: "r" });
fs.writeFileSync(
    "registry/input.json", 
    JSON.stringify({
        "language": "Solidity",
        "sources": {
            "PreApproveRegistry.sol": {
                "content": rfs(".tmp/PreApproveRegistry.sol")
            },
            "EnumerableAddressSetMap.sol": {
                "content": rfs(".tmp/EnumerableAddressSetMap.sol")
            },
        },
        "settings": {
            "metadata": { "bytecodeHash": "none" },
            "optimizer": { "enabled": true, "runs": 1000000 },
            "viaIR": true,
            "outputSelection": { "*": { "*": [ "evm.bytecode", "evm.deployedBytecode", "abi" ] } }
        }
    })
)' > .tmp/generate_input_json.js;
node .tmp/generate_input_json.js;

echo '{ "devDependencies": { "@ethersproject/keccak256": "5.7.0" } }' > .tmp/package.json;

if [ ! -f .tmp/package-lock.json ]; then cd .tmp; npm install; cd ..; fi

echo 'const fs = require("fs"), rfs = s => fs.readFileSync(s, { encoding: "utf8", flag: "r" });
fs.writeFileSync(
    "registry/initcodehash.txt", 
    require("@ethersproject/keccak256").keccak256("0x" + rfs("registry/initcode.txt"))
)' > .tmp/generate_initcodehash.js;
node .tmp/generate_initcodehash.js;

rm .tmp/*.sol .tmp/*.js > /dev/null 2>&1;
