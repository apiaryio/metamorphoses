_ = require('./helper')
blueprintApi = require('../../blueprint-api')
transformResource = require('./transformResource')

module.exports = (element, urlPrefix, options) ->
  resources = []

  element.resources.forEach((resource) ->
    resources = resources.concat(transformResource(resource, urlPrefix, options))
  )

  resources
