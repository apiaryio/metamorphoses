_ = require('./helper')

transformHeaders = (element, type) ->
  result = if type is 'legacy' then {} else []
  httpHeaders = element.headers

  return result if not httpHeaders

  httpHeaders.forEach((header) ->
    key = header.key.toValue()
    value = header.value.toValue()

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
