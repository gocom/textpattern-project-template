const webpack = require('webpack');
const ejs = require('ejs');
const CopyPlugin = require('copy-webpack-plugin');
const path = require('path');
const TerserPlugin = require('terser-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const CssMinimizerPlugin  = require('css-minimizer-webpack-plugin');

function transformHtml(content) {
    return ejs.render(content.toString(), {
        ...process.env,
    });
}

/**
 * @type {object}
 */
const config = {
    devtool: false,
    mode: process.env.NODE_ENV || 'production',
    context: path.join(__dirname, 'src/assets'),
    entry: {
        './main': './main.js',
    },
    output: {
        path: path.join(__dirname, 'public/assets'),
        filename: '[name].js',
    },
    resolve: {
        extensions: [
            '.js',
        ],
    },
    module: {
        rules: [
            {
                test: /\.js$/,
                loader: 'babel-loader',
            },
            {
                test: /\.css$/,
                use: [
                    MiniCssExtractPlugin.loader,
                    'css-loader',
                ],
            },
            {
                test: /\.less$/,
                use: [
                    MiniCssExtractPlugin.loader,
                    'css-loader',
                    'less-loader',
                ],
            },
            {
                test: /\.(png|jpg|jpeg|gif|svg|ico)$/,
                loader: 'file-loader',
                options: {
                    name: '[name].[ext]',
                    outputPath: 'assets/images/',
                },
            },
            {
                test: /\.(woff(2)?|ttf|eot|svg)(\?v=\d+\.\d+\.\d+)?$/,
                loader: 'file-loader',
                options: {
                    name: '[name].[ext]',
                    outputPath: 'assets/fonts/',
                },
            },
        ],
    },
    plugins: [
        new webpack.DefinePlugin({
            global: 'window',
        }),
        new webpack.SourceMapDevToolPlugin({}),
        new MiniCssExtractPlugin(),
        new CopyPlugin({
            patterns: [
                {
                    from: 'static/',
                    globOptions: {
                        ignore: [
                            '**/.*',
                        ],
                    },
                },
                {
                    from: 'static/*.html',
                    transform: transformHtml,
                }
            ],
        }),
    ],
    performance: {
        hints: false,
    },
    stats: {
        children: false,
        chunks: false,
        colors: true,
        hash: false,
        entrypoints: true,
        modules: false,
        performance: false,
    },
    devServer: {
        port: 12598,
    },
    optimization: {
        minimizer: [
            new TerserPlugin(),
            new CssMinimizerPlugin(),
        ],
        usedExports: true,
        removeAvailableModules: true,
    },
};

if (config.mode === 'production') {
    config.devtool = false;

    config.plugins = (config.plugins || []).concat([
        new webpack.DefinePlugin({
            'process.env': {
                NODE_ENV: '"production"',
            },
        }),
    ]);
}

module.exports = config;
