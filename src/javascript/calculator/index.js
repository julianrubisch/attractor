const fs = require("fs");
const glob = require("glob");
const escomplex = require("typhonjs-escomplex");

let src = "./**/*.js?(x)";

const ignorePattern = /(node_modules|webpack.config|eslint|vendor|dist|build|plato|tmp)/;

const files = glob.sync(src, {});

files.forEach(file => {
  if (ignorePattern.test(file)) {
    return;
  }
  console.log(file);
  const report = escomplex.analyzeModule(fs.readFileSync(file).toString());
  console.log(report.aggregate.cyclomatic);
  console.log(
    report.methods.map(m => ({ name: m.name, complexity: m.cyclomatic }))
  );
});
