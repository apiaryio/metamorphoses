_ = require('./refract/helper')
minim = require('./refract/minim')
blueprintApi = require('../blueprint-api')

getDescription = require('./refract/getDescription')
transformAuth = require('./refract/transformAuth')
transformSections = require('./refract/transformSections')
transformDataStructures = require('./refract/transformDataStructures')

countLines = (code, index) ->
  if index > 0
    excerpt = code.substr(0, index)
    return excerpt.split(/\r\n|\r|\n/).length
  else
    return 1


transformAst = (json, sourcemap, options) ->
  return null unless json

  element = minim.serialiser06.deserialise(json) # TODO: Change to minim.fromRefract

  applicationAst = new blueprintApi.Blueprint({
    name: _.trimLastNewline(element.title.toValue())
    version: blueprintApi.Version
    metadata: []
  })

  # Metadata and location
  applicationAst.metadata =
    (element.attributes.get('meta') or [])
    .filter((item) ->
      item.classes.contains('user')
    )
    .map((entry) ->
      name = entry.key.toValue()
      value = entry.value.toValue()

      if name is 'HOST'
        applicationAst.location = value
        return null
      else
        {name, value}
    )

  applicationAst.metadata =
    _.chain(applicationAst.metadata)
    .compact()
    .uniqBy('name')
    .value()

  # description
  description = getDescription(element, options)

  applicationAst.description = description.raw
  applicationAst.htmlDescription = description.html

  # Authentication definitions
  applicationAst.authDefinitions = transformAuth(element, options)

  # Sections
  applicationAst.sections = transformSections(element, applicationAst.location, options)
  applicationAst.dataStructures = transformDataStructures(element, options)

  applicationAst


transformError = (source, json) ->
  element = minim.serialiser06.deserialise(json) # TODO: Change to minim.fromRefract

  errors = element.errors

  if errors.length > 0
    annotation = errors.get(0)
    sourceMaps = annotation.sourceMapValue
    locations = sourceMaps?.map((sourceMap) -> {index: sourceMap[0], length: sourceMap[1]})

    unless locations
      # When there is no existing source maps, treat whole document as source
      locations = [{index: 0, length: source.length}]

    error = {
      message: annotation.toValue()
      code: annotation.code.toValue() or 1
      line: countLines(source, locations?[0]?.index)
      location: locations
    }

    return error


module.exports = {
  transformAst
  transformError
}
