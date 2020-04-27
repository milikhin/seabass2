const path = require('path')

const sailfishConfig = {
  entry: './editor/index.js',
  output: {
    path: path.resolve(__dirname, 'harbour-seabass/qml/html/dist'),
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
  mode: 'development'
}

module.exports = [sailfishConfig]
