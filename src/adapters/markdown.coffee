# This is our Markdown parser implementation

{renderHtml, renderRobotskirtHtml} = require('blueprint-markdown-renderer')

parseMarkdown = (markdown, options = {}, cb) ->
  options.sanitize ?= true

  if options.commonMark
    results = renderHtml(markdown, options)
  else
    results = renderRobotskirtHtml(markdown, options)

  # Return <span> if the results are empty. This way other code
  # that renders knows this code has been parsed.
  if results.trim() is ''
    results = '<span></span>'

  if cb
    return cb(null, results)
  else
    return results


toHtml = (markdown, options = {}, cb) ->
  # Allow for second arg to be the callback
  if typeof options is 'function'
    cb = options
    options = {}

  unless cb
    return parseMarkdown(markdown, options)

  unless markdown
    return cb(null, '')

  parseMarkdown(markdown, options, cb)
  return


toHtmlSync = (markdown, options = {}) ->
  if not markdown
    return ''
  return parseMarkdown(markdown, options)

module.exports = {
  toHtml
  toHtmlSync
}
