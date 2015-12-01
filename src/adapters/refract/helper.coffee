lodash = require('lodash')
require('lodash-api-description')(lodash)

fixNewLines = (str) ->
  return unless lodash.isString(str)
  str.replace(/\n$/, '')

lodash.mixin({
  fixNewLines
})

module.exports = lodash
