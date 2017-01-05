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


module.exports = (resourceElement, urlPrefix, options) ->
  resources = []

  resourceDescription = getDescription(resourceElement, options)
  transitions = _.transitions(resourceElement)


  resourceUriTemplate = _.chain(resourceElement).get('attributes.href', '').contentOrValue().value()
  resourceUrl = urlPrefix + resourceUriTemplate

  if transitions.length is 0
    return []

  transitions.forEach((transitionElement) ->
    description = getDescription(transitionElement, options)

    resourceParameters = getUriParameters(_.get(resourceElement, 'attributes.hrefVariables'), options)
    actionParameters = getUriParameters(_.get(transitionElement, 'attributes.hrefVariables'), options)

    attributes = _.dataStructures(resourceElement)
    attributes = if _.isEmpty(attributes) then undefined else attributes[0]
    actionAttributes = _.get(transitionElement, 'attributes.data')

    # Resource
    #
    # * `method` is set when iterating `httpTransaction`
    # * Dtto, `actionUriTemplate`
    #
    transitionUriTemplate = _.chain(transitionElement).get('attributes.href', '').contentOrValue().value()

    resource = new blueprintApi.Resource({
      url: urlPrefix + (transitionUriTemplate or resourceUriTemplate)
      uriTemplate: transitionUriTemplate or resourceUriTemplate
      resourceUriTemplate: resourceUriTemplate
      actionUriTemplate: transitionUriTemplate

      name: _.chain(resourceElement).get('meta.title', '').contentOrValue().value().trim()

      # We can safely leave these empty for now.
      headers: {}
      actionHeaders: {}

      description: resourceDescription.raw
      htmlDescription: resourceDescription.html
      actionName: _.chain(transitionElement).get('meta.title', '').contentOrValue().value().trim()

      # Model has been deprecated in the API Blueprint format,
      # therfore we can safely skip it.
      model: {}

      actionDescription: description.raw
      actionHtmlDescription: description.html
      attributes
      actionAttributes: actionAttributes

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

      # In refract just here we have method
      resource.method = _.chain(httpRequest).get('attributes.method', '').contentOrValue().value()

      httpRequestIsRedundant = _.every(httpTransactions, (httpTransaction) ->
        httpRequestToCompareWith = _(httpTransaction).httpRequests().first()
        _.isEqual(httpRequestToCompareWith, httpRequest)
      )

      requestName = _.chain(httpRequest).get('meta.title', '').contentOrValue().value()
      requestHeaders = getHeaders(httpRequest)
      requestBody = trimLastNewline(if _.content(httpRequestBody) then _.content(httpRequestBody) else '')
      requestSchema = trimLastNewline(if _.content(httpRequestBodySchemas) then _.content(httpRequestBodySchemas) else '')
      requestAuthSchemes = transformAuth(httpTransaction, options)

      httpRequestIsEmpty = _.isEmpty(requestName) \
        and _.isEmpty(httpRequestDescription.raw) \
        and _.isEmpty(requestHeaders) \
        and _.isEmpty(requestBody) \
        and _.isEmpty(requestSchema) \
        and _.isEmpty(requestAttributes) \
        and _.isEmpty(requestAuthSchemes)

      if (not httpRequestIsEmpty) and (httpTransactionIndex is 0 or not httpRequestIsRedundant)
        request = new blueprintApi.Request({
          name: requestName
          description: httpRequestDescription.raw
          htmlDescription: httpRequestDescription.html
          headers: requestHeaders
          # reference
          body: requestBody
          schema: requestSchema
          exampleId: httpTransactionIndex
          attributes: requestAttributes
          authSchemes: requestAuthSchemes
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
          exampleId: httpTransactionIndex
          attributes: responseAttributes
        })

        responses.push(response)
    )

    resource.requests = requests
    resource.request = requests[0]
    resource.responses = responses

    if not resource.request
      resource.request = new blueprintApi.Request({
        name: ''
        description: ''
        htmlDescription: ''
      })

      resource.requests.push(resource.request)

    resource.resourceParameters = resourceParameters or []
    resource.actionParameters = actionParameters or []
    resource.parameters = actionParameters or resourceParameters or []

    resources.push(resource)
  )

  resources
