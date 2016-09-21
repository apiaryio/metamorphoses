lodash = require('lodash')
require('lodash-api-description')(lodash)

trimLastNewline = (str) ->
  return unless lodash.isString(str)
  str.replace(/\n$/, '')

lodash.mixin({
  trimLastNewline
})

module.exports = lodash
