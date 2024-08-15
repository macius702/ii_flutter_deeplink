const path = require('path');
const Dotenv = require('dotenv-webpack');


module.exports = {
    entry: './assets/js/main.js',
    //developer mode map
    devtool: 'source-map',
    
    output: {
        filename: 'bundle.js',
        path: path.resolve(__dirname, 'assets/js'),
    },
    mode: 'development',
    plugins: [
        new Dotenv()
    ]

};