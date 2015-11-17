_ = require('./refract/helper')
blueprintApi = require('../blueprint-api')
markdown = require('./markdown')

transformResource = ->
  return
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


transformResources = (element) ->
  _.resources(element)


transformSections = (element) ->
  [
    new blueprintApi.Section(
      name: 'Unnamed Section'
      resources: transformResources(element)
    )
  ]


transformAst = (element) ->
  categroy = _.content(element)

  applicationAst = new blueprintApi.Blueprint({
    name: _.get(category, 'meta.title')
    version: ''
    metadata: []
  })

  applicationAst.description = ''
  applicationAst.htmlDescription = ''

  #applicationAst.sections = transformSections(element)

  applicationAst


module.exports = {
  transformAst
  transformError: (source, err) -> err
}
