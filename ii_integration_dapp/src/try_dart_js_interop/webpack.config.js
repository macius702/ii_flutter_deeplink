const path = require('path');
const Dotenv = require('dotenv-webpack');


module.exports = {
    entry: './assets/js/main.js',
    output: {
        filename: 'bundle.js',
        path: path.resolve(__dirname, 'build/web/dist'),
    },
    mode: 'development',
    plugins: [
        new Dotenv()
    ]

};