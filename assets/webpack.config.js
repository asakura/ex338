const path = require("path")
const glob = require("glob")
const MiniCssExtractPlugin = require("mini-css-extract-plugin")
const TerserPlugin = require("terser-webpack-plugin")
const OptimizeCSSAssetsPlugin = require("optimize-css-assets-webpack-plugin")
const CopyPlugin = require("copy-webpack-plugin")

module.exports = (env, options) => {
  const devMode = options.mode !== "production"

  return {
    optimization: {
      minimizer: [
        new TerserPlugin({ cache: true, parallel: true, sourceMap: devMode }),
        new OptimizeCSSAssetsPlugin({}),
      ],
    },
    entry: {
      app: glob.sync("./vendor/**/*.js").concat(["./js/app.js"]),
    },
    output: {
      filename: "[name].js",
      path: path.resolve(__dirname, "../priv/static/js"),
      publicPath: "/js/",
    },
    devtool: devMode ? "source-map" : undefined,
    module: {
      rules: [
        {
          test: /\.js$/,
          exclude: /node_modules/,
          use: {
            loader: "babel-loader",
          },
        },
        {
          test: /\.css$/,
          use: [
            MiniCssExtractPlugin.loader,
            "css-loader?url=false",
            "postcss-loader",
          ],
        },
      ],
    },
    plugins: [
      new MiniCssExtractPlugin({ filename: "../css/app.css" }),
      new CopyPlugin({ patterns: [{ from: "static/", to: "../" }] }),
    ],
  }
}
