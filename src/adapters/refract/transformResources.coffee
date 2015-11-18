_ = require('./helper')
blueprintApi = require('../../blueprint-api')
getDescription = require('./getDescription')
getHeaders = require('./getHeaders')

module.exports = (element) ->
  resources = []

  _.resources(element).forEach((resourceElement) ->
    resourceDescription = getDescription(resourceElement)

    _.transitions(resourceElement).forEach((transitionElement) ->
      description = getDescription(transitionElement)

      # Resource
      #
      # * `method` is set when iterating `httpTransaction`
      resource = new blueprintApi.Resource({
        # TODO: `url` should contain a possible HOST suffix.
        url: _.get(resourceElement, 'attributes.href')
        uriTemplate: _.get(resourceElement, 'attributes.href')

        name: _.get(resourceElement, 'meta.title')

        # We can safely leave these empty for now.
        headers: []
        actionHeaders: []

        description: resourceDescription.raw
        htmlDescription: resourceDescription.html
        actionName: _.get(transitionElement, 'meta.tite')

        # Model has been deprecated in the API Blueprint format,
        # therfore we can safely skip it.
        model: null

        # TODO: Waiting for Vincenzo.
        # resourceParameters
        # actionParameters

        actionDescription: description.raw
        actionHtmlDescription: description.html
        attributes: _.dataStructures(resourceElement)
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
          attributes: _.dataStructures(httpRequestBody)
          resolvedAttributes: _.dataStructures(httpRequestBody)
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
          attributes: _.dataStructures(httpResponseBody)
          resolvedAttributes: _.dataStructures(httpResponseBody)
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
