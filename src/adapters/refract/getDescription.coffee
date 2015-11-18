_ = require('./helper')
markdown = require('../markdown')

module.exports = (element) ->
  copyElement = _(element).copy().first()

  raw = _.content(copyElement) or ''
  html = if raw then markdown.toHtmlSync(raw) else ''

  return {raw, html}
