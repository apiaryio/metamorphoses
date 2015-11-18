lodash = require('./helper')

module.exports = (element) ->
  lodash(element).get('meta.description', '')
