_ = require('./helper')
markdown = require('../markdown')

module.exports = (element, options) ->
  raw = _.trimLastNewline(element.copy.first?.toValue() or '')
  html = _.trimLastNewline(if raw then markdown.toHtmlSync(raw, options) else '')

  return {raw, html}
