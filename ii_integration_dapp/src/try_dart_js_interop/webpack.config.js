const path = require('path');
const Dotenv = require('dotenv-webpack');


module.exports = {
    entry: './assets/js/main.js',
    output: {
        filename: 'bundle.js',
        path: __dirname + '/dist',
    },
    mode: 'development',
    plugins: [
        new Dotenv()
    ]

};