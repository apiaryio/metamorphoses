_ = require('./refract/helper')
blueprintApi = require('../blueprint-api')
markdown = require('./markdown')


getDescription = (element) ->
  raw = _.chain(element).copy().first().content().value() or ''
  html = if raw then markdown.toHtmlSync(raw) else ''

  return {raw, html}


getHeaders = (element) ->
  headers = {}

  httpHeaders = _.get(element, 'attributes.headers')

  return headers if not httpHeaders

  _.content(httpHeaders).forEach((headerElement) ->
    content = _.content(headerElement)
    key = _.get(content, 'key.content')
    value = _.get(content, 'value.content')

    headers[key] = value if key
  )

  headers

transformResources = (element) ->
  resources = []

  _.resources(element).forEach((resourceElement) ->
    resourceDescription = getDescription(resourceElement)

    _.transitions(resourceElement).forEach((transitionElement) ->
      description = getDescription(transitionElement)

      resource = new blueprintApi.Resource({
        url: _.get(resourceElement, 'attributes.href')
        # uriTemplate
        # method is set when iterating httpTransaction
        name: _.get(resourceElement, 'meta.title')
        # headers
        # actionHeaders
        description: resourceDescription.raw
        htmlDescription: resourceDescription.html
        actionName: _.get(transitionElement, 'meta.tite')
        # model
        # resourceParameters
        # actionParameters
        actionDescription: description.raw
        actionHtmlDescription: description.html
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

        httpRequestBody = _.chain(httpRequest).messageBodies().first().value()
        httpResponseBody = _.chain(httpResponse).messageBodies().first().value()

        httpRequestBodySchemas = _.chain(httpRequest).messageBodySchemas().first()
        httpResponseBodySchemas = _.chain(httpResponse).messageBodySchemas().first()

        httpRequestDescription = getDescription(httpRequest)
        httpResponseDescription = getDescription(httpResponse)

        # In refract just here we have ,ethod
        resource.method = _.get(httpRequest, 'attributes.method')

        request = new blueprintApi.Request({
          name: _.get(httpRequest, 'meta.title')
          description: httpRequestDescription.raw
          htmlDescription: httpRequestDescription.html
          headers: getHeaders(httpRequest)
          # reference
          body: _.content(httpRequestBody)
          schema: _.content(httpRequestBodySchemas)
          # exampleId
          attributes: _.get(httpRequestBody, 'attributes')
          # resolvedAttributes
        })

        response = new blueprintApi.Response({
          status: _.get(httpResponse, 'attributes.statusCode')
          description: httpResponseDescription.raw
          htmlDescription: httpResponseDescription.html
          headers: getHeaders(httpResponse)
          # reference
          body: _.content(httpResponseBody)
          schema: _.content(httpResponseBodySchemas)
          # exampleId
          attributes: _.get(httpResponseBody, 'attributes')
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
