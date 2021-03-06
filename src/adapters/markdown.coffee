# This is our Markdown parser implementation

{renderHtml} = require('blueprint-markdown-renderer')

parseMarkdown = (markdown, params, cb) ->
  # do not mutate passed-in argument "params", create our own options
  options = {
    sanitize: params?.sanitize
  }

  # sanitize is enabled by default
  options.sanitize ?= true

  results = renderHtml(markdown, options)

  # Return <span> if the results are empty. This way other code
  # that renders knows this code has been parsed.
  if results.trim() is ''
    results = '<span></span>'

  if cb
    return cb(null, results)
  else
    return results


toHtml = (markdown, params, cb) ->
  options = {}
  # Allow for second arg to be the callback
  if typeof params is 'function'
    cb = params
  else
    # do not mutate passed-in argument "params", create our own options
    options = {
      sanitize: params?.sanitize
    }

  unless cb
    return parseMarkdown(markdown, options)

  unless markdown
    return cb(null, '')

  parseMarkdown(markdown, options, cb)
  return


toHtmlSync = (markdown, params) ->
  if not markdown
    return ''
  return parseMarkdown(markdown, params)

module.exports = {
  toHtml
  toHtmlSync
}
