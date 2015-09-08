
blueprintApi = require('../blueprint-api')
markdown = require('./markdown')


applymarkdownHtml = (obj, targetHtmlProperty) ->
  obj[targetHtmlProperty] = markdown.toHtmlSync(obj.description or '').trim()
  obj


# ## `apiaryAstToApplicationAst`
#
# _**Note:**_ `apiaryAst` is AST of the Old Blueprint Format.
#
# Go through the AST object and render
# markdown descriptions.
apiaryAstToApplicationAst = (ast) ->
  return null unless ast

  plainJsObject = applymarkdownHtml(ast.toJSON(), 'htmlDescription')

  for section, sectionKey in plainJsObject.sections or [] when section.resources?.length
    for resource, resourceKey in section.resources
      section.resources[resourceKey] = applymarkdownHtml(resource, 'htmlDescription')
      section.resources[resourceKey].requests = [section.resources[resourceKey].request]

    plainJsObject.sections[sectionKey] = applymarkdownHtml(section, 'htmlDescription')

  plainJsObject.version = blueprintApi.Version
  return blueprintApi.Blueprint.fromJSON(plainJsObject)


module.exports = {
  transformAst: apiaryAstToApplicationAst
  transformError: (source, err) -> err
}
