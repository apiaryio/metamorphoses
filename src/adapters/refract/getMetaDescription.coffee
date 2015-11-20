lodash = require('./helper')
markdown = require('../markdown')

module.exports = (element) ->
  markdown.toHtmlSync(lodash.chain(element).get('meta.description', '').fixNewLines().value())
