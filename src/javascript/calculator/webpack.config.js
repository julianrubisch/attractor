const path = require("path");
const nodeExternals = require("webpack-node-externals");

module.exports = {
  target: "node",
  entry: {
    app: ["./index.js"]
  },
  output: {
    path: path.resolve(__dirname, "../../../dist"),
    filename: "calculator.bundle.js"
  }
  // externals: [nodeExternals()]
};
