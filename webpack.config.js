const path = require('path')
const CopyPlugin = require('copy-webpack-plugin')
const { CleanWebpackPlugin } = require('clean-webpack-plugin')

const commonConfig = {
  entry: './editor/src/index.js',
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
    path: path.resolve(__dirname, 'harbour-seabass/qml/html'),
    // publicPath: '/usr/share/harbour-seabass/qml/html/',
    filename: 'bundle.js'
  },
  plugins: [
    ...commonConfig.plugins,
    new CopyPlugin({
      patterns: [
        {
          from: './harbour-seabass/html'
        },
        {
          from: './generic/qml',
          to: path.resolve(__dirname, 'harbour-seabass/qml/generic')
        },
        {
          from: './generic/py-backend',
          to: path.resolve(__dirname, 'harbour-seabass/qml/py-backend')
        },
        {
          from: './generic/py-libs',
          to: path.resolve(__dirname, 'harbour-seabass/qml/py-libs'),
          globOptions: {
            ignore: '**/.git'
          }
        }
      ]
    })
  ],
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
