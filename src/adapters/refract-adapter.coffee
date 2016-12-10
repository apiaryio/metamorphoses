_ = require('./refract/helper')
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


transformAst = (element, sourcemap, options) ->

  applicationAst = new blueprintApi.Blueprint({
    name: _.chain(element).get('meta.title', '').contentOrValue().trimLastNewline().value()
    version: blueprintApi.Version
    metadata: []
  })

  # Metadata and location
  applicationAst.metadata =
    _.chain(element)
    .get('attributes.meta')
    .contentOrValue()
    .filter({meta: {classes: ['user']}})
    .map((entry) ->
      content = _.content(entry)

      name = _.chain(entry).content().get('key').contentOrValue().value()
      value = _.chain(entry).content().get('value', '').contentOrValue().value()

      if name is 'HOST'
        applicationAst.location = value if name is 'HOST'
        return null
      else
        {name, value}
    ).compact()
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


transformError = (source, parseResult) ->
  errors = _.chain(parseResult)
    .filterContent({element: 'annotation'})
    .filter({meta: {classes: ['error']}})
    .value()

  if errors.length > 0
    sourceMaps = errors[0]?.attributes?.sourceMap?[0]?.content
    locations = sourceMaps.map((sourceMap) -> {index: sourceMap[0], length: sourceMap[1]})

    error = {
      message: errors?[0]?.content
      code: errors?[0]?.attributes?.code or 1
      line: countLines(source, locations[0].index)
      location: locations
    }

    return error


module.exports = {
  transformAst
  transformError
}
