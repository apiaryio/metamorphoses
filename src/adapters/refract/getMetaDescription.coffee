lodash = require('./helper')
markdown = require('../markdown')

module.exports = (element, options) ->
  rawDescription = lodash
                    .chain(element)
                    .get('meta.description', '')
                    .contentOrValue()
                    .fixNewLines()
                    .value()

  markdown.toHtmlSync(rawDescription, options)
