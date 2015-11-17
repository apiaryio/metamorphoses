_ = require('./refract/helper')
blueprintApi = require('../blueprint-api')
markdown = require('./markdown')

getDescription = require('./refract/getDescription')

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
  category = _.chain(element).get('content').filter({element: 'category'}).first().value()

  applicationAst = new blueprintApi.Blueprint({
    name: _.get(category, 'meta.title')
    metadata: []
  })

  # Metadata and location
  metadata = []
  _.chain(category)
    .get('attributes.meta')
    .filter({meta: {classes: ['user']}})
    .value()
    .forEach((entry) ->
      content = _.content(entry)

      name = _.get(content, 'key.content')
      value = _.get(content, 'value.content')

      metadata.push({name, value})
      applicationAst.location = value if name is 'HOST'
    )
  applicationAst.metadata = metadata

  # description
  categoryContent = _.content(category)
  description = _.chain(category).copy().first().content().value()

  applicationAst.description = description
  applicationAst.htmlDescription = if description then markdown.toHtmlSync(description) else null

  #applicationAst.sections = transformSections(element)

  applicationAst


module.exports = {
  transformAst
  transformError: (source, err) -> err
}
