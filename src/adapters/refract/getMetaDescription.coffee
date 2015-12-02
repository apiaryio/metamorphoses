lodash = require('./helper')
markdown = require('../markdown')

module.exports = (element) ->
  rawDescription = lodash
                    .chain(element)
                    .get('meta.description', '')
                    .contentOrValue()
                    .fixNewLines()
                    .value()

  markdown.toHtmlSync(rawDescription)
