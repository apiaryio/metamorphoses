_ = require('./helper')
markdown = require('../markdown')

module.exports = (element, options) ->
  rawDescription = _.trimLastNewline(element.description.toValue())

  markdown.toHtmlSync(rawDescription, options)
