_ = require('./helper')
blueprintApi = require('../../blueprint-api')
getDescription = require('./getDescription')
getHeaders = require('./getHeaders')
transformAuth = require('./transformAuth')

trimLastNewline = (s) ->
  unless s
    return

  if s[s.length - 1] is '\n' then s.slice(0, -1) else s

module.exports = (transactions, options) ->
  requests = []
  responses = []
  method = undefined

  prevRequests = []
  prevResponses = []
  exampleIndex = -1

  transactions.forEach((httpTransaction, httpTransactionIndex, httpTransactions) ->
    # Transactions only have 1 request and 1 response
    httpRequest = _(httpTransaction).httpRequests().first()
    httpResponse  = _(httpTransaction).httpResponses().first()

    # In refract, we have method only in this place
    method = _.chain(httpRequest).get('attributes.method', '').contentOrValue().value()

    # Request retrieving
    httpRequestBody = _(httpRequest).messageBodies().first()
    httpRequestBodySchemas = _(httpRequest).messageBodySchemas().first()
    httpRequestDescription = getDescription(httpRequest, options)
    httpRequestBodyDataStructures = _.dataStructures(httpRequest)

    if _.isEmpty(httpRequestBodyDataStructures)
      requestAttributes = undefined
    else
      requestAttributes = httpRequestBodyDataStructures[0]

    # Response retrieving
    httpResponseBody = _(httpResponse).messageBodies().first()
    httpResponseBodySchemas = _(httpResponse).messageBodySchemas().first()
    httpResponseDescription = getDescription(httpResponse, options)
    httpResponseBodyDataStructures = _.dataStructures(httpResponse)

    if _.isEmpty(httpResponseBodyDataStructures)
      responseAttributes = undefined
    else
      responseAttributes = httpResponseBodyDataStructures[0]

    # Example Id handling
    alreadyUsedRequest = _.some(prevRequests, (prevRequest) ->
      _.isEqual(prevRequest, httpRequest)
    )

    alreadyUsedResponse = _.some(prevResponses, (prevResponse) ->
      _.isEqual(prevResponse, httpResponse)
    )

    if not alreadyUsedRequest and not alreadyUsedResponse
      exampleIndex = exampleIndex + 1
      prevRequests = []
      prevResponses = []

    # Check for empty http request
    requestName = _.chain(httpRequest).get('meta.title', '').contentOrValue().value()
    requestBody = trimLastNewline(if _.content(httpRequestBody) then _.content(httpRequestBody) else '')
    requestSchema = trimLastNewline(if _.content(httpRequestBodySchemas) then _.content(httpRequestBodySchemas) else '')
    requestAuthSchemes = transformAuth(httpTransaction, options)

    [requestHeaders, requestHeaders1A] = getHeaders(httpRequest)

    httpRequestIsEmpty = _.isEmpty(requestName) \
      and _.isEmpty(httpRequestDescription.raw) \
      and _.isEmpty(requestHeaders) \
      and _.isEmpty(requestBody) \
      and _.isEmpty(requestSchema) \
      and _.isEmpty(requestAttributes) \
      and _.isEmpty(requestAuthSchemes)

    if httpRequestIsEmpty
      prevRequests.push(httpRequest)

    if not httpRequestIsEmpty and not alreadyUsedRequest
      request = new blueprintApi.Request({
        name: requestName
        description: httpRequestDescription.raw
        htmlDescription: httpRequestDescription.html
        headers: requestHeaders
        headers1A: requestHeaders1A
        body: requestBody
        schema: requestSchema
        exampleId: exampleIndex
        attributes: requestAttributes
        authSchemes: requestAuthSchemes
      })

      requests.push(request)
      prevRequests.push(httpRequest)

    if not alreadyUsedResponse and (httpResponse?.content.length or (not _.isEmpty(httpResponse?.attributes)))
      [httpResponseHeaders, httpResponseHeaders1A] = getHeaders(httpResponse)

      response = new blueprintApi.Response({
        status: _.chain(httpResponse).get('attributes.statusCode').contentOrValue().value()
        description: httpResponseDescription.raw
        htmlDescription: httpResponseDescription.html
        headers: httpResponseHeaders
        headers1A: httpResponseHeaders1A
        body: trimLastNewline(if _.content(httpResponseBody) then _.content(httpResponseBody) else '')
        schema: trimLastNewline(if _.content(httpResponseBodySchemas) then _.content(httpResponseBodySchemas) else '')
        exampleId: exampleIndex
        attributes: responseAttributes
      })

      responses.push(response)
      prevResponses.push(httpResponse)
  )

  # Add an empty request if no requests exit
  if not requests.length
    requests.push(new blueprintApi.Request({
      name: ''
      description: ''
      htmlDescription: ''
    }))

  [method, requests, responses]
