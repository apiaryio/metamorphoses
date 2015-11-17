_ = require('./refract/helper')
blueprintApi = require('../blueprint-api')
markdown = require('./markdown')


getDescription = (element) ->
  raw = _.chain(element).copy().first().content().value() or ''
  html = if raw then markdown.toHtmlSync(raw) else ''

  return {raw, html}


transformResources = (element) ->
  resources = []

  _.resources(element).forEach((resourceElement) ->
    _.transitions(resourceElement).forEach((transitionElement) ->
      resource = new blueprintApi.Resource({
        # url
        # uriTemplate
        # method
        # name
        name: _.get(transitionElement, 'meta.title')
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
      })

      requests = []
      responses = []

      _.httpTransactions(transitionElement).forEach((httpTransaction) ->
        httpRequest = _.chain(httpTransaction).httpRequests().first().value()
        httpResponse  = _.chain(httpTransaction).httpResponses().first().value()

        request = new blueprintApi.Request({
          # name
          # description
          # htmlDescription
          # headers
          # reference
          # body
          # schema
          # exampleId
          # attributes
          # resolvedAttributes
        })

        response = new blueprintApi.Response({
          # status
          # description
          # htmlDescription
          # headers
          # reference
          # body
          # schema
          # exampleId
          # attributes
          # resolvedAttributes
        })

        requests.push(request)
        responses.push(response)
      )

      resource.requests = requests
      resource.request = requests[0]
      resource.responses = responses

      resources.push(resource)
    )
  )

  resources

transformSections = (element) ->
  resourceGroups = _.chain(element)
                    .content()
                    .filter({element: 'category', meta: {classes: ['resourceGroup']}})
                    .value()

  resourceGroups.map((resourceGroupElement) ->
    section = new blueprintApi.Section({
      name: _.get(resourceGroupElement, 'meta.title')
    })

    description = getDescription(resourceGroupElement)

    section.description = description.raw
    section.htmlDescription = description.html

    section.resources = transformResources(resourceGroupElement)

    section
  )


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
  description = getDescription(category)

  applicationAst.description = description.raw
  applicationAst.htmlDescription = description.html

  # Sections
  applicationAst.sections = transformSections(category)

  applicationAst


module.exports = {
  transformAst
  transformError: (source, err) -> err
}
