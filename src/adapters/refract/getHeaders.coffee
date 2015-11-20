_ = require('./helper')

module.exports = (element) ->
  headers = {}

  httpHeaders = _.get(element, 'attributes.headers')

  return headers if not httpHeaders

  _.content(httpHeaders).forEach((headerElement) ->
    content = _.content(headerElement)
    key = _.get(content, 'key.content')
    value = _.get(content, 'value.content')

    headers[key] = value if key
  )

  headers
