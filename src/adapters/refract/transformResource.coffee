_ = require('./helper')
blueprintApi = require('../../blueprint-api')
getDescription = require('./getDescription')
getHeaders = require('./getHeaders')
getUriParameters = require('./getUriParameters')

module.exports = (resourceElement) ->
  resources = []

  resourceDescription = getDescription(resourceElement)

  transitions = _.transitions(resourceElement)

  # If a resources doesn't have any transitions, create a very minimal
  # resource (URI, URI Template, Name, Description and Attributes).
  if transitions.length is 0
    attributes = _.dataStructures(resourceElement)
    attributes = undefined if _.isEmpty(attributes)

    return [
      new blueprintApi.Resource({
        url: _.chain(resourceElement).get('attributes.href', '').contentOrValue().value()
        uriTemplate: _.chain(resourceElement).get('attributes.href', '').contentOrValue().value()
        name: _.chain(resourceElement).get('meta.title', '').contentOrValue().value()

        description: resourceDescription.raw
        htmlDescription: resourceDescription.html

        attributes
        resolvedAttributes: attributes
      })
    ]

  transitions.forEach((transitionElement) ->
    description = getDescription(transitionElement)

    resourceParameters = getUriParameters(_.get(resourceElement, 'attributes.hrefVariables'))
    actionParameters = getUriParameters(_.get(transitionElement, 'attributes.hrefVariables'))

    attributes = _.dataStructures(resourceElement)
    attributes = undefined if _.isEmpty(attributes)

    # Resource
    #
    # * `method` is set when iterating `httpTransaction`
    # * Dtto, `actionUriTemplate`
    resource = new blueprintApi.Resource({
      # TODO: `url` should contain a possible HOST suffix.
      url: _.chain(resourceElement).get('attributes.href', '').contentOrValue().value()
      uriTemplate: _.chain(resourceElement).get('attributes.href', '').contentOrValue().value()

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
      resolvedAttributes: attributes

      actionRelation: _.chain(transitionElement).get('attributes.relation', '').contentOrValue().value()
    })

    requests = []
    responses = []

    _.httpTransactions(transitionElement).forEach((httpTransaction, httpTransactionIndex, httpTransactions) ->
      httpRequest = _(httpTransaction).httpRequests().first()
      httpRequestBody = _(httpRequest).messageBodies().first()
      httpRequestBodySchemas = _(httpRequest).messageBodySchemas().first()
      httpRequestDescription = getDescription(httpRequest)
      httpRequestBodyDataStructures = _.dataStructures(httpRequest)

      if _.isEmpty(httpRequestBodyDataStructures)
        requestAttributes = undefined
      else
        requestAttributes = httpRequestBodyDataStructures

      httpResponse  = _(httpTransaction).httpResponses().first()
      httpResponseBody = _(httpResponse).messageBodies().first()
      httpResponseBodySchemas = _(httpResponse).messageBodySchemas().first()
      httpResponseDescription = getDescription(httpResponse)
      httpResponseBodyDataStructures = _.dataStructures(httpResponse)

      if _.isEmpty(httpResponseBodyDataStructures)
        responseAttributes = undefined
      else
        responseAttributes = httpResponseBodyDataStructures

      # In refract just here we have method and href
      resource.method = _.chain(httpRequest).get('attributes.method', '').contentOrValue().value()
      resource.actionUriTemplate = _.chain(httpRequest).get('attributes.href', '').contentOrValue().value()

      requestParameters = getUriParameters(_.get(httpRequest, 'attributes.hrefVariables'))
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
          body: if _.content(httpRequestBody) then _.content(httpRequestBody) else ''
          schema: if _.content(httpRequestBodySchemas) then _.content(httpRequestBodySchemas) else ''
          # exampleId
          attributes: requestAttributes
          resolvedAttributes: requestAttributes
        })

        requests.push(request)

      response = new blueprintApi.Response({
        status: _.chain(httpResponse).get('attributes.statusCode').contentOrValue().value()
        description: httpResponseDescription.raw
        htmlDescription: httpResponseDescription.html
        headers: getHeaders(httpResponse)
        # reference
        body: if _.content(httpResponseBody) then _.content(httpResponseBody) else ''
        schema: if _.content(httpResponseBodySchemas) then _.content(httpResponseBodySchemas) else ''
        # exampleId
        attributes: responseAttributes
        resolvedAttributes: responseAttributes
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
