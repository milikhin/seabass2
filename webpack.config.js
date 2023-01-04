const path = require('path')
const { CleanWebpackPlugin } = require('clean-webpack-plugin')

const commonConfig = {
  entry: './editor/src/index.ts',
  module: {
    rules: [
      {
        test: [/\.js$/, /\.ts$/],
        exclude: /node_modules/,
        use: ['babel-loader']
      },
      {
        test: /\.css$/i,
        use: ['style-loader', 'css-loader']
      }
    ]
  },
  plugins: [
    new CleanWebpackPlugin()
  ],
  resolve: {
    extensions: ['.ts', '.js']
  },
  mode: 'production'
}

const sailfishConfig = {
  ...commonConfig,
  output: {
    path: path.resolve(__dirname, 'harbour-seabass/qml/html/dist'),
    filename: 'bundle.js'
  },
  name: 'sfos'
}

const ubportsConfig = {
  ...commonConfig,
  output: {
    path: path.resolve(__dirname, 'ubports-seabass/html/dist'),
    publicPath: 'dist/',
    filename: 'bundle.js'
  },
  name: 'ubports'
}

module.exports = [sailfishConfig, ubportsConfig]
