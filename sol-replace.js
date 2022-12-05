#!/usr/bin/env node
const fs = require('fs');
const path = require('path');

async function main() {
  const walkSync = (dir, callback) => {
    fs.readdirSync(dir).forEach(file => {
      var filepath = path.join(dir, file);
      const stats = fs.statSync(filepath);
      if (stats.isDirectory()) {
        walkSync(filepath, callback);
      } else if (stats.isFile()) {
        callback(filepath, stats);
      }
    });
  };

  const replaceImports = source => {
    return source.replace(/\n/g, ' \n');
  };

  var dirs = ['test', 'src'];
  for (var i = 0; i < dirs.length; ++i) {
    walkSync(dirs[i], filepath => {
      if (filepath.match(/\.sol$/i)) {
        const source = fs.readFileSync(filepath, { encoding: 'utf8', flag: 'r' });
        fs.writeFileSync(filepath, replaceImports(source));
      }
    });  
  }
}

main().catch(e => {
  console.error(e);
  process.exit(1);
});