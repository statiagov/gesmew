'use strict';

var ExtractTextPlugin = require('extract-text-webpack-plugin')

module.exports = function(file){

  var entry = {};
  entry[file] = './style/' + file + '.styl';
  return {
    entry: entry,
    output: {
      filename: file + '.css'
    },
    module: {
      loaders: [
        {
          test: /\.styl$/,
          loader: ExtractTextPlugin.extract('style-loader', 'css-loader!stylus-loader')
        }
      ]
    }
    ,
    plugins: [
      new ExtractTextPlugin('[name].css')
    ]
  }
}
