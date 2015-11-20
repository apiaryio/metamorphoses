_ = require('./helper')
blueprintApi = require('../../blueprint-api')
getDescription = require('./getDescription')
getHeaders = require('./getHeaders')
getUriParameters = require('./getUriParameters')

module.exports = (element) ->
  resources = []

  _.resources(element).forEach((resourceElement) ->
    resourceDescription = getDescription(resourceElement)

    _.transitions(resourceElement).forEach((transitionElement) ->
      description = getDescription(transitionElement)

      resourceParameters = getUriParameters(_.get(resourceElement, 'attributes.hrefVariables'))
      actionParameters = getUriParameters(_.get(transitionElement, 'attributes.hrefVariables'))
      parameters = resourceParameters.concat(actionParameters)

      resourceParameters = undefined if _.isEmpty(resourceParameters)
      actionParameters = undefined if _.isEmpty(actionParameters)
      parameters = undefined if _.isEmpty(parameters)

      attributes = _.dataStructures(resourceElement)
      attributes = undefined if _.isEmpty(attributes)

      # Resource
      #
      # * `method` is set when iterating `httpTransaction`
      # * Dtto, `actionUriTemplate`
      resource = new blueprintApi.Resource({
        # TODO: `url` should contain a possible HOST suffix.
        url: _.get(resourceElement, 'attributes.href', '')
        uriTemplate: _.get(resourceElement, 'attributes.href', '')

        name: _.get(resourceElement, 'meta.title', '')

        # We can safely leave these empty for now.
        headers: {}
        actionHeaders: {}

        description: resourceDescription.raw
        htmlDescription: resourceDescription.html
        actionName: _.get(transitionElement, 'meta.title', '')

        # Model has been deprecated in the API Blueprint format,
        # therfore we can safely skip it.
        model: {}

        parameters
        resourceParameters
        actionParameters

        actionDescription: description.raw
        actionHtmlDescription: description.html
        attributes
        resolvedAttributes: attributes

        actionRelation: _.get(transitionElement, 'attributes.relation', '')
      })

      requests = []
      responses = []

      _.httpTransactions(transitionElement).forEach((httpTransaction) ->
        httpRequest = _(httpTransaction).httpRequests().first()
        httpResponse  = _(httpTransaction).httpResponses().first()

        httpRequestBody = _(httpRequest).messageBodies().first()
        httpResponseBody = _(httpResponse).messageBodies().first()

        httpRequestBodySchemas = _(httpRequest).messageBodySchemas().first()
        httpResponseBodySchemas = _(httpResponse).messageBodySchemas().first()

        httpRequestDescription = getDescription(httpRequest)
        httpResponseDescription = getDescription(httpResponse)

        requestAttributes = _.dataStructures(httpRequestBody)
        requestAttributes = undefined if _.isEmpty(requestAttributes)

        responseAttributes = _.dataStructures(httpResponseBody)
        responseAttributes = undefined if _.isEmpty(responseAttributes)

        # In refract just here we have method and href
        resource.method = _.get(httpRequest, 'attributes.method', '')
        resource.actionUriTemplate = _.get(httpRequest, 'attributes.href', '')

        request = new blueprintApi.Request({
          name: _.get(httpRequest, 'meta.title', '')
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

        response = new blueprintApi.Response({
          status: _.get(httpResponse, 'attributes.statusCode')
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
