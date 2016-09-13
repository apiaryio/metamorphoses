url = require('url')
_ = require('./helper')
blueprintApi = require('../../blueprint-api')
getDescription = require('./getDescription')
getHeaders = require('./getHeaders')
getUriParameters = require('./getUriParameters')
transformAuth = require('./transformAuth')


trimLastNewline = (s) ->
  unless s
    return

  if s[s.length - 1] is '\n' then s.slice(0, -1) else s


module.exports = (resourceElement, location, options) ->
  resources = []

  resourceDescription = getDescription(resourceElement, options)

  transitions = _.transitions(resourceElement)

  urlPrefix = ''
  if location
    host = url.parse(location)

    if host.path and host.path isnt '/'
      urlPrefix = host.path.replace(/\/$/, '')

  resourceUriTemplate = _.chain(resourceElement).get('attributes.href', '').contentOrValue().value()
  resourceUrl = urlPrefix + resourceUriTemplate

  # If a resources doesn't have any transitions, create a very minimal
  # resource (URI, URI Template, Name, Description and Attributes).
  if transitions.length is 0
    attributes = _.dataStructures(resourceElement)
    attributes = if _.isEmpty(attributes) then undefined else attributes[0]

    return [
      new blueprintApi.Resource({
        url: resourceUrl
        uriTemplate: resourceUriTemplate
        name: _.chain(resourceElement).get('meta.title', '').contentOrValue().value()

        description: resourceDescription.raw
        htmlDescription: resourceDescription.html

        attributes
      })
    ]

  transitions.forEach((transitionElement) ->
    description = getDescription(transitionElement, options)

    resourceParameters = getUriParameters(_.get(resourceElement, 'attributes.hrefVariables'), options)
    actionParameters = getUriParameters(_.get(transitionElement, 'attributes.hrefVariables'), options)

    attributes = _.dataStructures(transitionElement)
    attributes = if _.isEmpty(attributes) then _.dataStructures(resourceElement) else attributes[0]
    attributes = if _.isEmpty(attributes) then undefined else attributes[0]

    # Resource
    #
    # * `method` is set when iterating `httpTransaction`
    # * Dtto, `actionUriTemplate`
    #
    transitionUriTemplate = _.chain(transitionElement).get('attributes.href', resourceUriTemplate).contentOrValue().value()
    transitionUrl = urlPrefix + transitionUriTemplate

    resource = new blueprintApi.Resource({
      url: transitionUrl
      uriTemplate: transitionUriTemplate

      name: _.chain(resourceElement).get('meta.title', '').contentOrValue().value()

      # We can safely leave these empty for now.
      headers: {}
      actionHeaders: {}

      description: resourceDescription.raw
      htmlDescription: resourceDescription.html
      actionName: _.chain(transitionElement).get('meta.title', '').contentOrValue().value()

      # Model has been deprecated in the API Blueprint format,
      # therfore we can safely skip it.
      model: {}

      actionDescription: description.raw
      actionHtmlDescription: description.html
      attributes

      actionRelation: _.chain(transitionElement).get('attributes.relation', '').contentOrValue().value()
    })

    requests = []
    responses = []

    _.httpTransactions(transitionElement).forEach((httpTransaction, httpTransactionIndex, httpTransactions) ->
      httpRequest = _(httpTransaction).httpRequests().first()
      httpRequestBody = _(httpRequest).messageBodies().first()
      httpRequestBodySchemas = _(httpRequest).messageBodySchemas().first()
      httpRequestDescription = getDescription(httpRequest, options)
      httpRequestBodyDataStructures = _.dataStructures(httpRequest)

      if _.isEmpty(httpRequestBodyDataStructures)
        requestAttributes = undefined
      else
        requestAttributes = httpRequestBodyDataStructures[0]

      httpResponse  = _(httpTransaction).httpResponses().first()
      httpResponseBody = _(httpResponse).messageBodies().first()
      httpResponseBodySchemas = _(httpResponse).messageBodySchemas().first()
      httpResponseDescription = getDescription(httpResponse, options)
      httpResponseBodyDataStructures = _.dataStructures(httpResponse)

      if _.isEmpty(httpResponseBodyDataStructures)
        responseAttributes = undefined
      else
        responseAttributes = httpResponseBodyDataStructures[0]

      # In refract just here we have method and href
      resource.method = _.chain(httpRequest).get('attributes.method', '').contentOrValue().value()
      resource.actionUriTemplate = _.chain(httpRequest).get('attributes.href', '').contentOrValue().value()

      requestParameters = getUriParameters(_.get(httpRequest, 'attributes.hrefVariables'), options)
      actionParameters = actionParameters.concat(requestParameters)

      httpRequestIsRedundant = _.every(httpTransactions, (httpTransaction) ->
        httpRequestToCompareWith = _(httpTransaction).httpRequests().first()
        _.isEqual(httpRequestToCompareWith, httpRequest)
      )

      if (httpTransactionIndex is 0) or (not httpRequestIsRedundant)
        request = new blueprintApi.Request({
          name: _.chain(httpRequest).get('meta.title', '').contentOrValue().value()
          description: httpRequestDescription.raw
          htmlDescription: httpRequestDescription.html
          headers: getHeaders(httpRequest)
          # reference
          body: trimLastNewline(if _.content(httpRequestBody) then _.content(httpRequestBody) else '')
          schema: trimLastNewline(if _.content(httpRequestBodySchemas) then _.content(httpRequestBodySchemas) else '')
          # exampleId
          attributes: requestAttributes
          authSchemes: transformAuth(httpTransaction, options)
        })

        requests.push(request)

      if httpResponse?.content.length or (not _.isEmpty(httpResponse?.attributes))
        response = new blueprintApi.Response({
          status: _.chain(httpResponse).get('attributes.statusCode').contentOrValue().value()
          description: httpResponseDescription.raw
          htmlDescription: httpResponseDescription.html
          headers: getHeaders(httpResponse)
          # reference
          body: trimLastNewline(if _.content(httpResponseBody) then _.content(httpResponseBody) else '')
          schema: trimLastNewline(if _.content(httpResponseBodySchemas) then _.content(httpResponseBodySchemas) else '')
          # exampleId
          attributes: responseAttributes
        })

        responses.push(response)
    )

    resource.requests = requests
    resource.request = requests[0]
    resource.responses = responses

    resource.resourceParameters = resourceParameters
    resource.actionParameters = actionParameters
    resource.parameters = resourceParameters.concat(actionParameters)

    resources.push(resource)
  )

  resources
