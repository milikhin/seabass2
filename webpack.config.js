const path = require('path')
const CopyPlugin = require('copy-webpack-plugin')

const commonConfig = {
  entry: './editor/src/index.js',
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
  mode: 'production'
}

const sailfishConfig = {
  ...commonConfig,
  output: {
    path: path.resolve(__dirname, 'harbour-seabass/qml/html'),
    publicPath: '/usr/share/harbour-seabass/qml/html/',
    filename: 'bundle.js'
  },
  plugins: [
    new CopyPlugin([
      {
        from: './harbour-seabass/html'
      }
    ])
  ]
}

const ubportsConfig = {
  ...commonConfig,
  output: {
    path: path.resolve(__dirname, 'ubports-seabass/html/dist'),
    publicPath: 'dist/',
    filename: 'bundle.js'
  }
}

module.exports = [sailfishConfig, ubportsConfig]
