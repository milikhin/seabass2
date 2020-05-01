const path = require('path')
const CopyPlugin = require('copy-webpack-plugin')

const sailfishConfig = {
  entry: './editor/src/index.js',
  output: {
    path: path.resolve(__dirname, 'harbour-seabass/qml/html'),
    filename: 'bundle.js'
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: ['babel-loader']
      },
      {
        test: /\.css$/i,
        use: ['style-loader', 'css-loader']
      }
    ]
  },
  mode: 'production',
  plugins: [
    new CopyPlugin([
      {
        from: './harbour-seabass/html'
      }
    ])
  ]
}

module.exports = [sailfishConfig]
