_ = require('./helper')
minim = require('./minim')

blueprintApi = require('../../blueprint-api')
getDescription = require('./getDescription')
transformAuth = require('./transformAuth')
{getHeaders, getHeaders1A} = require('./getHeaders')

module.exports = (transactions, options) ->
  requests = []
  responses = []
  method = undefined

  prevRequests = []
  prevResponses = []
  exampleIndex = -1

  transactions.forEach((httpTransaction, httpTransactionIndex, httpTransactions) ->
    httpRequest = httpTransaction.request
    httpResponse = httpTransaction.response

    # Transactions only have 1 request and 1 response
    httpRequestElement = minim.serialiser06.serialise(httpRequest)
    httpResponseElement = minim.serialiser06.serialise(httpResponse)

    # In refract, we have method only in this place
    method = httpRequest.method?.toValue() or ''

    # Request retrieving
    httpRequestBody = httpRequest.messageBody
    httpRequestBodySchema = httpRequest.messageBodySchema
    httpRequestDescription = getDescription(httpRequest, options)
    requestAttributes = httpRequest.dataStructure

    if requestAttributes
      requestAttributes = minim.serialiser06.serialise(requestAttributes)

    # Response retrieving
    httpResponseBody = httpResponse.messageBody
    httpResponseBodySchema = httpResponse.messageBodySchema
    httpResponseDescription = getDescription(httpResponse, options)
    responseAttributes = httpResponse.dataStructure

    if responseAttributes
      responseAttributes = minim.serialiser06.serialise(responseAttributes)

    # Example Id handling
    alreadyUsedRequest = _.some(prevRequests, (prevRequest) ->
      _.isEqual(prevRequest, httpRequestElement)
    )

    alreadyUsedResponse = _.some(prevResponses, (prevResponse) ->
      _.isEqual(prevResponse, httpResponseElement)
    )

    if not alreadyUsedRequest and not alreadyUsedResponse
      exampleIndex = exampleIndex + 1
      prevRequests = []
      prevResponses = []

    if not alreadyUsedRequest
      request = new blueprintApi.Request({
        name: httpRequest.title?.toValue()
        description: httpRequestDescription.raw
        htmlDescription: httpRequestDescription.html
        headers: getHeaders(httpRequest)
        headers1A: getHeaders1A(httpRequest)
        body: _.trimLastNewline(httpRequestBody?.toValue() or '')
        schema: _.trimLastNewline(httpRequestBodySchema?.toValue() or '')
        exampleId: exampleIndex
        attributes: requestAttributes
        authSchemes: transformAuth(httpTransaction, options)
      })

      requests.push(request)
      prevRequests.push(httpRequestElement)

    if not alreadyUsedResponse and (httpResponse.content?.length or (not _.isEmpty(httpResponse.attributes.toValue())))
      response = new blueprintApi.Response({
        status: httpResponse.statusCode?.toValue() or ''
        description: httpResponseDescription.raw
        htmlDescription: httpResponseDescription.html
        headers: getHeaders(httpResponse)
        headers1A: getHeaders1A(httpResponse)
        body: _.trimLastNewline(httpResponseBody?.toValue() or '')
        schema: _.trimLastNewline(httpResponseBodySchema?.toValue() or '')
        exampleId: exampleIndex
        attributes: responseAttributes
      })

      responses.push(response)
      prevResponses.push(httpResponseElement)
  )

  # Add an empty request if no requests exit
  if not requests.length
    requests.push(new blueprintApi.Request({
      name: ''
      description: ''
      htmlDescription: ''
    }))

  [method, requests, responses]
