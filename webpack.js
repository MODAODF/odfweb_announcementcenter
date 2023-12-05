const path = require('path')
const webpackConfig = require('@nextcloud/webpack-vue-config')

webpackConfig.entry.admin = path.join(__dirname, 'src', 'admin')
webpackConfig.entry.dashboard = path.join(__dirname, 'src', 'dashboard')
webpackConfig.entry.newannounce = path.join(__dirname, 'src', 'newannounce.js')

module.exports = webpackConfig
