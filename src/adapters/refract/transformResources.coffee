_ = require('./helper')
blueprintApi = require('../../blueprint-api')
transformResource = require('./transformResource')

module.exports = (element) ->
  resources = []

  _.resources(element).forEach((resourceElement) ->
    resources = resources.concat(transformResource(resourceElement))
  )

  resources
