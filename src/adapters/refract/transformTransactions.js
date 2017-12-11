/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const _ = require('./helper');
const blueprintApi = require('../../blueprint-api');
const getDescription = require('./getDescription');
const transformAuth = require('./transformAuth');
const {getHeaders, getHeaders1A} = require('./getHeaders');

const trimLastNewline = function(s) {
  if (!s) {
    return;
  }

  if (s[s.length - 1] === '\n') { return s.slice(0, -1); } else { return s; }
};

module.exports = function(transactions, options) {
  const requests = [];
  const responses = [];
  let method = undefined;

  let prevRequests = [];
  let prevResponses = [];
  let exampleIndex = -1;

  transactions.forEach(function(httpTransaction, httpTransactionIndex, httpTransactions) {
    // Transactions only have 1 request and 1 response
    let requestAttributes, responseAttributes;
    const httpRequest = _(httpTransaction).httpRequests().first();
    const httpResponse  = _(httpTransaction).httpResponses().first();

    // In refract, we have method only in this place
    method = _.chain(httpRequest).get('attributes.method', '').contentOrValue().value();

    // Request retrieving
    const httpRequestBody = _(httpRequest).messageBodies().first();
    const httpRequestBodySchemas = _(httpRequest).messageBodySchemas().first();
    const httpRequestDescription = getDescription(httpRequest, options);
    const httpRequestBodyDataStructures = _.dataStructures(httpRequest);

    if (_.isEmpty(httpRequestBodyDataStructures)) {
      requestAttributes = undefined;
    } else {
      requestAttributes = httpRequestBodyDataStructures[0];
    }

    // Response retrieving
    const httpResponseBody = _(httpResponse).messageBodies().first();
    const httpResponseBodySchemas = _(httpResponse).messageBodySchemas().first();
    const httpResponseDescription = getDescription(httpResponse, options);
    const httpResponseBodyDataStructures = _.dataStructures(httpResponse);

    if (_.isEmpty(httpResponseBodyDataStructures)) {
      responseAttributes = undefined;
    } else {
      responseAttributes = httpResponseBodyDataStructures[0];
    }

    // Example Id handling
    const alreadyUsedRequest = _.some(prevRequests, prevRequest => _.isEqual(prevRequest, httpRequest));

    const alreadyUsedResponse = _.some(prevResponses, prevResponse => _.isEqual(prevResponse, httpResponse));

    if (!alreadyUsedRequest && !alreadyUsedResponse) {
      exampleIndex = exampleIndex + 1;
      prevRequests = [];
      prevResponses = [];
    }

    // Check for empty http request
    const requestName = _.chain(httpRequest).get('meta.title', '').contentOrValue().value();
    const requestBody = trimLastNewline(_.content(httpRequestBody) ? _.content(httpRequestBody) : '');
    const requestSchema = trimLastNewline(_.content(httpRequestBodySchemas) ? _.content(httpRequestBodySchemas) : '');
    const requestAuthSchemes = transformAuth(httpTransaction, options);

    const requestHeaders = getHeaders(httpRequest);
    const requestHeaders1A = getHeaders1A(httpRequest);

    if (!alreadyUsedRequest) {
      const request = new blueprintApi.Request({
        name: requestName,
        description: httpRequestDescription.raw,
        htmlDescription: httpRequestDescription.html,
        headers: requestHeaders,
        headers1A: requestHeaders1A,
        body: requestBody,
        schema: requestSchema,
        exampleId: exampleIndex,
        attributes: requestAttributes,
        authSchemes: requestAuthSchemes
      });

      requests.push(request);
      prevRequests.push(httpRequest);
    }

    if (!alreadyUsedResponse && ((httpResponse != null ? httpResponse.content.length : undefined) || (!_.isEmpty(httpResponse != null ? httpResponse.attributes : undefined)))) {
      const httpResponseHeaders = getHeaders(httpResponse);
      const httpResponseHeaders1A = getHeaders1A(httpResponse);

      const response = new blueprintApi.Response({
        status: _.chain(httpResponse).get('attributes.statusCode').contentOrValue().value(),
        description: httpResponseDescription.raw,
        htmlDescription: httpResponseDescription.html,
        headers: httpResponseHeaders,
        headers1A: httpResponseHeaders1A,
        body: trimLastNewline(_.content(httpResponseBody) ? _.content(httpResponseBody) : ''),
        schema: trimLastNewline(_.content(httpResponseBodySchemas) ? _.content(httpResponseBodySchemas) : ''),
        exampleId: exampleIndex,
        attributes: responseAttributes
      });

      responses.push(response);
      return prevResponses.push(httpResponse);
    }
  });

  // Add an empty request if no requests exit
  if (!requests.length) {
    requests.push(new blueprintApi.Request({
      name: '',
      description: '',
      htmlDescription: ''
    }));
  }

  return [method, requests, responses];
};
