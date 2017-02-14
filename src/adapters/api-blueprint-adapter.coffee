
blueprintApi = require('../blueprint-api')
markdown = require('./markdown')

setSourcemap = (node, sourcemap, name = 'sourcemap') ->
  value = null

  # Try to find the closest source map to the top of the node block, e.g.
  # the resource or action name, method, URI, description, etc.
  if sourcemap.name?.length then value = sourcemap.name
  else if sourcemap.method?.length then value = sourcemap.method
  else if sourcemap.uriTemplate?.length then value = sourcemap.uriTemplate
  else if sourcemap.description?.length then value = sourcemap.description

  if value
    node[name] = value


countLines = (code, index) ->
  if index > 0
    excerpt = code.substr(0, index)
    return excerpt.split(/\r\n|\r|\n/).length
  else
    return 1


trimLastNewline = (s) ->
  unless s
    return

  if s[s.length - 1] is '\n' then s.slice(0, -1) else s


# # Transform AST from Protagonist to legacy/application AST
# This is needed for two reasons
# 1) Protagonist's AST do not support .toJSON() yet
# 2) There are subtle differences in some parts of the tree
# Takes data and ensures it comes out as an object of objects. If array of
# sub-objects is given, takes out the 'key' property of the sub-object, places
# it as a key and uses the rest of the sub-object as a value. (Actual name of
# the key property can be changed by an argument.)
#
#   [
#     {name: 'a', color: 'blue'}
#     {name: 'b', color: 'red'}
#   ]
#
# is turned into
#
#   {
#     a: {color: 'blue'}
#     b: {color: 'red'}
#   }
ensureObjectOfObjects = (data, key = 'name') ->
  if not data
    {}
  else if Array.isArray(data)
    obj = {}
    for arrayItem in data
      values = {}
      for own k, v of arrayItem
        if k isnt key
          values[k] = v
      obj[arrayItem[key]] = values
    obj
  else
    data


# # Merges multiple headers with the same key into one
# This is needed in A1 -> legacy header merge / transformation,
# since A1 can contain multiple values for given
# header key, legacy cannot
#
#   [
#     { name: 'Set-Cookie', value: 'abcde' }
#     { name: 'Set-Cookie', value: 'Alan Turing' }
#   ]
#
# is turned into
#
#   [
#     { name: 'Set-Cookie', value: 'abcde, Alan Turing' }
#   ]
mergeMultipleHeaders = (headers) ->
  if not headers or not headers.length
    return headers

  mergedHeadersMap = headers.reduce((result, header) ->
    value = null

    if result[header.name] then value = "#{result[header.name]}, #{header.value}"
    else value = header.value

    result[header.name] = value

    return result
  , {}
  )

  mergedHeaders = []

  for own key, value of mergedHeadersMap
    mergedHeaders.push({
      name: key,
      value: value
    })

  return mergedHeaders


# ## `legacyHeadersFrom1AHeaders`
#
# Turns an array of headers into an object.
#
# ### Input
#
# ```
# [
#   {
#     key: 'Content-Type'
#     value: 'application/json'
#   }
# ]
# ```
#
# ### Output
#
# ```
# {
#   'Content-Type': 'application/json'
# }
# ```
legacyHeadersFrom1AHeaders = (headers) ->
  legacyHeaders = {}
  mergedHeaders = mergeMultipleHeaders(headers)
  for own key, header of ensureObjectOfObjects(mergedHeaders) or {} when header?.value?
    legacyHeaders[key] = header.value
  legacyHeaders


# ## `legacyHeadersCombinedFrom1A`
#
# Merges request/response, action, and resource
# headers and outputs an object of the headers.
legacyHeadersCombinedFrom1A = (resOrReq, action, resource) ->
  headers = {}
  cascade = [resource.headers, action.headers, resOrReq?.headers]
  for someHeaders in cascade
    if someHeaders
      for own key, header of legacyHeadersFrom1AHeaders(someHeaders)
        headers[key] = header
  headers


# Retrieves attributes elements from an element content
#
# @param elementContent [Array] Element's content
# @return [Object] Hash of `attributes` and `resolvedAttributes` elements
getAttributesElements = (elementContent) ->
  elements = {attributes: undefined, resolvedAttributes: undefined}
  return elements if not elementContent or elementContent.length is 0

  dataStructures = elementContent.filter((item) ->
    item.element is 'dataStructure'
  )

  resolvedDataStructure = elementContent.filter((item) ->
    item.element is 'resolvedDataStructure'
  )

  elements.attributes = dataStructures.shift()
  elements.resolvedAttributes = resolvedDataStructure.shift()

  elements


legacyRequestsFrom1AExamples = (action, resource, options) ->
  requests = []
  for example, exampleIndex in action.examples or []
    for req in example.requests or []
      requests.push(legacyRequestFrom1ARequest(req, action, resource, exampleId = exampleIndex, options))

  if requests.length < 1
    return [legacyRequestFrom1ARequest({}, action, resource, exampleId = 0, options)]
  requests


# ## `legacyRequestFrom1ARequest`
#
# Transform 1A Format Request into 'legacy request'
legacyRequestFrom1ARequest = (request, action, resource, exampleId = undefined, options) ->
  legacyRequest = new blueprintApi.Request(
    headers: legacyHeadersCombinedFrom1A(request, action, resource)
    exampleId: exampleId
  )

  legacyRequest.description     = trimLastNewline(request.description) or ''
  legacyRequest.htmlDescription = trimLastNewline(markdown.toHtmlSync(request.description, options)) or ''

  legacyRequest.reference = request.reference

  legacyRequest.body   = trimLastNewline(request.body)  or ''
  legacyRequest.name   = request.name or ''
  legacyRequest.schema = trimLastNewline(request.schema) or ''

  # Attributes
  attributesElements = getAttributesElements(request.content)
  legacyRequest.attributes = attributesElements.attributes
  legacyRequest.resolvedAttributes = attributesElements.resolvedAttributes


  legacyRequest


legacyResponsesFrom1AExamples = (action, resource) ->
  responses = []
  for example, exampleIndex in action.examples or []
    for resp in example.responses or []
      responses.push(legacyResponseFrom1AResponse(resp, action, resource, exampleId = exampleIndex))
  responses


# ## `legacyResponseFrom1AResponse`
#
# Transform 1A Format Response into 'legacy response'
legacyResponseFrom1AResponse = (response, action, resource, exampleId = undefined, options) ->
  legacyResponse = new blueprintApi.Response(
    headers: legacyHeadersCombinedFrom1A(response, action, resource)
    exampleId: exampleId
  )

  legacyResponse.description     = trimLastNewline(response.description) or ''
  legacyResponse.htmlDescription = trimLastNewline(markdown.toHtmlSync(response.description, options)) or ''

  legacyResponse.reference = response.reference

  legacyResponse.body   = trimLastNewline(response.body) or ''
  legacyResponse.schema = trimLastNewline(response.schema) or ''

  # `name` and `status` have the same value, ‘API Blueprint AST’ uses
  # the `name` property, see https://github.com/apiaryio/snowcrash/wiki/API-Blueprint-AST-Media-Types.
  legacyResponse.name   = response.name or ''
  legacyResponse.status = response.name or ''

  # Attributes
  attributesElements = getAttributesElements(response.content)
  legacyResponse.attributes = attributesElements.attributes
  legacyResponse.resolvedAttributes = attributesElements.resolvedAttributes

  legacyResponse


# ## `getParametersOf`
#
# Produces an array of URI parameters.
getParametersOf = (obj, options) ->
  if not obj
    return undefined

  params = []
  paramsObj = ensureObjectOfObjects(obj.parameters)

  for own key, param of paramsObj
    param.key = key
    if param.description
      param.description = markdown.toHtmlSync(param.description, options)
    param.values = ((if typeof item is 'string' then item else item.value) for item in param.values)
    param.type = 'string' if not param.type
    params.push(param)

  if not params.length
    undefined
  else
    params


# ## `legacyResourcesFrom1AResource`
#
# Transform 1A Format Resource into 'legacy resources', squashing action and resource
# NOTE: One 1A Resource might split into more legacy resources (actions[].transactions[].resource)
legacyResourcesFrom1AResource = (legacyUrlConverterFn, resource, sourcemap, options) ->
  legacyResources = []

  # resource-wide parameters
  resourceParameters = getParametersOf(resource, options)

  for action, actionIndex in resource.actions or []
    # Combine resource & action section, preferring action
    legacyResource = new blueprintApi.Resource({responses: [], requests: []})
    actionParameters = getParametersOf(action, options)

    if sourcemap
      setSourcemap(legacyResource, sourcemap)

    actionSourcemap = sourcemap?.actions?[actionIndex]
    if actionSourcemap
      setSourcemap(legacyResource, actionSourcemap, 'actionSourcemap')

    legacyResource.url         = legacyUrlConverterFn(action.attributes?.uriTemplate or resource.uriTemplate)
    legacyResource.uriTemplate = action.attributes?.uriTemplate or resource.uriTemplate
    legacyResource.resourceUriTemplate = resource.uriTemplate

    legacyResource.method = action.method
    legacyResource.name   = resource.name?.trim() or ''

    legacyResource.headers       = legacyHeadersFrom1AHeaders(resource.headers)
    legacyResource.actionHeaders = legacyHeadersFrom1AHeaders(action.headers)

    legacyResource.description = trimLastNewline(resource.description) or ''
    legacyResource.htmlDescription = trimLastNewline(markdown.toHtmlSync(resource.description, options)) or ''

    legacyResource.actionName = action.name?.trim() or ''

    unless not resource.model
      legacyResource.model = resource.model

      if resource.model.description and resource.model.description.length
        legacyResource.model.description = markdown.toHtmlSync(resource.model.description, options)

      if resource.model.headers and resource.model.headers.length
        legacyResource.model.headers = legacyHeadersFrom1AHeaders(resource.model.headers)

    else
      legacyResource.model = {}

    legacyResource.resourceParameters = resourceParameters or []
    legacyResource.actionParameters   = actionParameters or []

    legacyResource.parameters = actionParameters or resourceParameters or []

    legacyResource.actionDescription     = trimLastNewline(action.description) or ''
    legacyResource.actionHtmlDescription = trimLastNewline(markdown.toHtmlSync(action.description, options)) or ''

    # Requests - for legacy usage, please, save '.request' too
    requests = legacyRequestsFrom1AExamples(action, resource)
    legacyResource.requests = requests
    legacyResource.request = requests[0]

    # Responses
    legacyResource.responses = legacyResponsesFrom1AExamples(action, resource, options)

    # Resource Attributes
    attributesElements = getAttributesElements(resource.content)
    legacyResource.attributes = attributesElements.attributes
    legacyResource.resolvedAttributes = attributesElements.resolvedAttributes

    # Action Attributes
    attributesElements = getAttributesElements(action.content)
    legacyResource.actionAttributes = attributesElements.attributes
    legacyResource.resolvedActionAttributes = attributesElements.resolvedAttributes

    if action.attributes
      legacyResource.actionRelation = action.attributes.relation
      legacyResource.actionUriTemplate = action.attributes.uriTemplate

    legacyResources.push(legacyResource)
  legacyResources


# ## `legacyASTfrom1AAST`
#
# This method will hopefully be superseeded by transformOldAstToProtagonist
# once we'll be comfortable with new format and it'll be our default.
legacyASTfrom1AAST = (ast, sourcemap, options) ->
  return null unless ast

  # We have completely removed MSON AST everywhere
  version = blueprintApi.Version

  # Blueprint
  legacyAST = new blueprintApi.Blueprint({
    name: ast.name
    version
    metadata: []
  })

  legacyAST.description = trimLastNewline(ast.description) or ''
  legacyAST.htmlDescription = trimLastNewline(markdown.toHtmlSync(ast.description, options)) or ''

  # Metadata
  metadata = []
  for own metaKey, metaVal of ensureObjectOfObjects(ast.metadata)
    if metaKey is 'HOST'
      legacyAST.location = metaVal.value
      continue
    metadata.push(
      name: metaKey
      value: metaVal.value
    )

  if metadata.length > 0
    legacyAST.metadata = metadata

  legacyUrlConverter = (url) -> url

  if legacyAST.location
    urlWithoutProtocol = legacyAST.location.replace(/^https?:\/\//, "")
    slashIndex         = urlWithoutProtocol.indexOf("/")

    if slashIndex > 0
      urlPrefix = urlWithoutProtocol.slice(slashIndex + 1)

      if urlPrefix isnt ""
        urlPrefix = urlPrefix.replace(/\/$/, "")
        legacyUrlConverter = (url) ->
          "/" + urlPrefix + "/" + url.replace(/^\//, "")

  # Resource Group Section(s) (was: Section)
  for resourceGroup, i in ast.resourceGroups
    legacySection = new blueprintApi.Section(
      name: resourceGroup.name
      resources: []
    )

    if sourcemap?.resourceGroups?[i]?
      setSourcemap(legacySection, sourcemap.resourceGroups[i])

    legacySection.description     = trimLastNewline(resourceGroup.description) or ''
    legacySection.htmlDescription = trimLastNewline(markdown.toHtmlSync(resourceGroup.description, options)) or ''

    # Resources
    for resource, j in resourceGroup.resources
      resources = legacyResourcesFrom1AResource(legacyUrlConverter, resource,
        sourcemap?.resourceGroups?[i]?.resources?[j], options)
      legacySection.resources = legacySection.resources.concat(resources)

    legacyAST.sections.push(legacySection)

  # Data Structures
  if ast.content and ast.content.length
    legacyAST.dataStructures = []

    (ast.content).forEach((element) ->
      isCategory = element.element is 'category'
      containsDataStructures = element.content?[0]?.element is 'dataStructure'

      if isCategory and containsDataStructures
        legacyAST.dataStructures = legacyAST.dataStructures.concat(element.content)
    )

  return legacyAST


transformError = (source, parseResult) ->
  if parseResult?.error and parseResult?.error?.code isnt 0
    error = parseResult.error
    error.line = countLines(source, error.location[0]?.index)
    return error


module.exports = {
  transformAst: legacyASTfrom1AAST
  transformError

  ensureObjectOfObjects # for testing purposes
}
