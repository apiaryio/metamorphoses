_ = require('./helper')
blueprintApi = require('../../blueprint-api')
getDescription = require('./getDescription')
getUriParameters = require('./getUriParameters')
transformTransactions = require('./transformTransactions')

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

    [resource.method, resource.requests, resource.responses] = transformTransactions(_.httpTransactions(transitionElement), options)

    resource.request = resource.requests[0]

    resource.resourceParameters = resourceParameters or []
    resource.actionParameters = actionParameters or []
    resource.parameters = actionParameters or resourceParameters or []

    resources.push(resource)
  )

  resources
