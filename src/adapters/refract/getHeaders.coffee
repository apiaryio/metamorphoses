_ = require('./helper')

module.exports = (element) ->
  headers = {}

  httpHeaders = _.get(element, 'attributes.headers')

  return headers if not httpHeaders

  _.content(httpHeaders).forEach((headerElement) ->
    content = _.content(headerElement)
    key = _.chain(content).get('key').contentOrValue().value()
    value = _.chain(content).get('value').contentOrValue().value()

    headers[key] = value if key
  )

  headers
