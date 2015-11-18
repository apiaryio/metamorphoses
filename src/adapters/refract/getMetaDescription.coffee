lodash = require('./helper')
markdown = require('../markdown')

module.exports = (element) ->
  markdown.toHtmlSync(lodash(element).get('meta.description', ''))
