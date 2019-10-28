const fs = require("fs");
const escomplex = require("typhonjs-escomplex");

const file = process.argv[2];
const report = escomplex.analyzeModule(fs.readFileSync(file).toString());

const details = {};

report.methods.forEach(m => {
  details[m.name] = m.cyclomatic;
});

console.log(JSON.stringify([report.aggregate.cyclomatic, details]));
