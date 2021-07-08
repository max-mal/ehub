const path = require('path');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const { VueLoaderPlugin } = require('vue-loader')
const WebpackBar = require('webpackbar');
const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = {
  mode: process.env.NODE_ENV ?? 'development',
  entry: {
    'main': './resources/src/js/app.js',
    'project': './resources/src/js/project.js',
    'commit_info': './resources/src/js/commmit_info.js',
  },
  devtool: 'inline-source-map',
  devServer: {
    contentBase: './resources/static/dist',
    hot: true,
    port: 9000,
    headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, PATCH, OPTIONS",
      "Access-Control-Allow-Headers": "X-Requested-With, content-type, Authorization"
    }
  },
  output: {
    filename: '[name].js',
    path: path.resolve(__dirname, 'resources/static/dist'),
  },
  module: {
    rules: [
      {
        test: /\.scss$/,
        use: [MiniCssExtractPlugin.loader, 'css-loader', 'sass-loader']        
      },
      {
        test: /\.vue$/,
        loader: 'vue-loader',
      }
    ]
  },
  plugins: [
    new WebpackBar(),
    new MiniCssExtractPlugin({
      filename: 'app.css',
    }),
    new VueLoaderPlugin(),
    new HtmlWebpackPlugin({
      title: 'Hot Module Replacement',
    }),
  ],
};