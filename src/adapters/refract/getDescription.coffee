_ = require('./helper')
markdown = require('../markdown')

module.exports = (element, options) ->
  copyElement = _(element).copy().first()

  raw = _.fixNewLines(_.content(copyElement) or '')
  html = _.fixNewLines(if raw then markdown.toHtmlSync(raw, options) else '')

  return {raw, html}
