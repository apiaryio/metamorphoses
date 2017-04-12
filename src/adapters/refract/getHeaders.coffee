_ = require('./helper')

transformHeaders = (element, type) ->
  result = if type is 'legacy' then {} else []
  httpHeaders = _.get(element, 'attributes.headers')

  return result if not httpHeaders

  _.content(httpHeaders).forEach((headerElement) ->
    content = _.content(headerElement)
    key = _.chain(content).get('key').contentOrValue().value()
    value = _.chain(content).get('value').contentOrValue().value()

    switch type
      when 'legacy'
        result[key] = value if key
      when '1A'
        result.push({
          name: key
          value
        })
  )

  result

getHeaders = (element) ->
  transformHeaders(element, 'legacy')

getHeaders1A = (element) ->
  transformHeaders(element, '1A')

module.exports = {
  getHeaders
  getHeaders1A
}
