const path = require('path');

module.exports = {
  entry: './src/javascript/index.js',
  output: {
    filename: 'index.pack.js',
    path: path.resolve(__dirname, 'app/assets/javascripts')
  },
  module: {
    rules: [
      {
        test: /\.(js|jsx)$/,
        exclude: /node_modules/,
        use: {
          loader: "babel-loader"
        }
      }
    ]
  }
};
