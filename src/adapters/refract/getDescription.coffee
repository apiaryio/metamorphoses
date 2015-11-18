_ = require('./helper')
markdown = require('../markdown')

module.exports = (element) ->
  raw = _.chain(element).copy().first().content().value() or ''
  html = if raw then markdown.toHtmlSync(raw) else ''

  return {raw, html}
