_ = require('./helper')
markdown = require('../markdown')

module.exports = (element, options) ->
  copyElement = _(element).copy().first()

  raw = _.trimLastNewline(_.content(copyElement) or '')
  html = _.trimLastNewline(if raw then markdown.toHtmlSync(raw, options) else '')

  return {raw, html}
