mkdir .tmp > /dev/null 2>&1;

cp src/PreApproveLister.sol .tmp;
cp lib/solady/src/auth/Ownable.sol .tmp;

echo 'const fs = require("fs"), rfs = s => fs.readFileSync(s, { encoding: "utf8", flag: "r" });
const p = ".tmp/PreApproveLister.sol";
fs.writeFileSync(
    p, 
    rfs(p).replace(/import\s*?\"solady\/auth/, "import \".")
)' > .tmp/replace_imports.js;
node .tmp/replace_imports.js;

forge build --out="out" --root=".tmp" --contracts="." --via-ir --optimize --optimizer-runs=200 --use=0.8.17;

mkdir lister > /dev/null 2>&1;

echo 'const fs = require("fs"), rfs = s => fs.readFileSync(s, { encoding: "utf8", flag: "r" });
fs.writeFileSync(
    "lister/initcode.txt", 
    JSON.parse(rfs(".tmp/out/PreApproveLister.sol/PreApproveLister.json"))["bytecode"]["object"].slice(2)
)' > .tmp/extract_initcode.js;
node .tmp/extract_initcode.js;

echo 'const fs = require("fs"), rfs = s => fs.readFileSync(s, { encoding: "utf8", flag: "r" });
fs.writeFileSync(
    "lister/input.json", 
    JSON.stringify({
        "language": "Solidity",
        "sources": {
            "PreApproveLister.sol": {
                "content": rfs(".tmp/PreApproveLister.sol")
            },
            "Ownable.sol": {
                "content": rfs(".tmp/Ownable.sol")
            },
        },
        "settings": {
            "optimizer": { "enabled": true, "runs": 200 },
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
    "lister/initcodehash.txt", 
    require("@ethersproject/keccak256").keccak256("0x" + rfs("lister/initcode.txt"))
)' > .tmp/generate_initcodehash.js;
node .tmp/generate_initcodehash.js;

rm .tmp/*.sol .tmp/*.js > /dev/null 2>&1;