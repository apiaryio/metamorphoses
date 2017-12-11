_ = require('./helper')
minim = require('./minim')

blueprintApi = require('../../blueprint-api')
getDescription = require('./getDescription')
getUriParameters = require('./getUriParameters')
transformTransactions = require('./transformTransactions')

module.exports = (element, urlPrefix, options) ->
  resources = []

  resourceDescription = getDescription(element, options)
  transitions = element.transitions

  resourceUriTemplate = element.href?.toValue() or ''
  resourceUrl = urlPrefix + resourceUriTemplate

  if transitions.length is 0
    return []

  transitions.forEach((transition) ->
    description = getDescription(transition, options)

    resourceParameters = getUriParameters(element.hrefVariables, options)
    actionParameters = getUriParameters(transition.hrefVariables, options)

    attributes = element.dataStructure
    actionAttributes = transition.data

    if attributes
      attributes = minim.serialiser06.serialise(attributes)

    if actionAttributes
      actionAttributes = minim.serialiser06.serialise(actionAttributes)

    # Resource
    #
    # * `method` is set when iterating `httpTransaction`
    # * Dtto, `actionUriTemplate`
    #
    transitionUriTemplate = transition.href?.toValue()

    resource = new blueprintApi.Resource({
      url: urlPrefix + (transitionUriTemplate or resourceUriTemplate)
      uriTemplate: transitionUriTemplate or resourceUriTemplate
      resourceUriTemplate: resourceUriTemplate
      actionUriTemplate: transitionUriTemplate or ''

      name: _.trim(element.title.toValue())

      # We can safely leave these empty for now.
      headers: {}
      actionHeaders: {}

      description: resourceDescription.raw
      htmlDescription: resourceDescription.html
      actionName: _.trim(transition.title.toValue())

      # Model has been deprecated in the API Blueprint format,
      # therfore we can safely skip it.
      model: {}

      actionDescription: description.raw
      actionHtmlDescription: description.html
      attributes
      actionAttributes: actionAttributes

      actionRelation: transition.relation?.toValue() or ''
    })

    [resource.method, resource.requests, resource.responses] = transformTransactions(transition.transactions, options)

    resource.request = resource.requests[0]

    resource.resourceParameters = resourceParameters or []
    resource.actionParameters = actionParameters or []
    resource.parameters = actionParameters or resourceParameters or []

    resources.push(resource)
  )

  resources
