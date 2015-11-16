blueprintApi = require('../blueprint-api')
markdown = require('./markdown')
_ = require('lodash-api-description')


transformResource = () ->
  # url
  # uriTemplate
  # method
  # name
  # headers
  # actionHeaders
  # description
  # htmlDescription
  # actionName
  # model
  # resourceParameters
  # actionParameters
  # actionDescription
  # actionHtmlDescription
  # requests
  # responses
  # attributes
  # resolvedAttributes
  # actionRelation
  # actionUriTemplate


transformResources = (refractObject) ->
  console.log(_.resources(refractObject))
  _.resources(refractObject)


transformSections = (refractObject) ->
  [
    new blueprintApi.Section(
      name: 'Unnamed Section'
      resources: transformResources(refractObject)
    )
  ]


transformAst = (refractObject) ->
  applicationAst = new blueprintApi.Blueprint({
    name: ''
    version: ''
    metadata: []
  })

  applicationAst.description = ''
  applicationAst.htmlDescription = ''

  applicationAst.sections = transformSections(refractObject)

  applicationAst


module.exports = {
  transformAst
  transformError: (source, err) -> err
}
