
blueprintApi = require('../blueprint-api')
markdown = require('./markdown')


applymarkdownHtml = (obj, targetHtmlProperty, options) ->
  obj[targetHtmlProperty] = markdown.toHtmlSync(obj.description or '', options).trim()
  obj


# ## `apiaryAstToApplicationAst`
#
# _**Note:**_ `apiaryAst` is AST of the Old Blueprint Format.
#
# Go through the AST object and render
# markdown descriptions.
apiaryAstToApplicationAst = (ast, sourcemap, options) ->
  return null unless ast
  plainJsObject = applymarkdownHtml(ast, 'htmlDescription', options)

  for section, sectionKey in plainJsObject.sections or [] when section.resources?.length
    for resource, resourceKey in section.resources
      section.resources[resourceKey].uriTemplate = resolveUriTemplate(section.resources[resourceKey], plainJsObject.location)
      section.resources[resourceKey] = applymarkdownHtml(resource, 'htmlDescription', options)
      section.resources[resourceKey].requests = [section.resources[resourceKey].request]

    plainJsObject.sections[sectionKey] = applymarkdownHtml(section, 'htmlDescription', options)

  plainJsObject.version = blueprintApi.Version
  return blueprintApi.Blueprint.fromJSON(plainJsObject)


resolveUriTemplate = (resource, location) ->
  return resource.uriTemplate if resource.uriTemplate

  urlPrefixPosition = getUrlPrefixPosition(location)
  if urlPrefixPosition
    return resource.url.slice(urlPrefixPosition)
  else
    return ''


getUrlPrefixPosition = (location) ->
  urlPrefixPosition = 0
  if location
    urlWithoutProtocol = location.replace(/^https?:\/\//, '')
    slashIndex = urlWithoutProtocol.indexOf('/')
    if slashIndex > 0
      urlPrefixPosition = urlWithoutProtocol.slice(slashIndex + 1).length
  return urlPrefixPosition


module.exports = {
  transformAst: apiaryAstToApplicationAst
  transformError: (source, err) -> err
}
