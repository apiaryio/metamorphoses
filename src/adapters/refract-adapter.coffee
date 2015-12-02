_ = require('./refract/helper')
blueprintApi = require('../blueprint-api')

getDescription = require('./refract/getDescription')
transformSections = require('./refract/transformSections')

transformAst = (element) ->

  applicationAst = new blueprintApi.Blueprint({
    name: _.chain(element).get('meta.title', '').contentOrValue().fixNewLines().value()
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

      applicationAst.location = value if name is 'HOST'
      {name, value}
    ).value()

  # description
  description = getDescription(element)

  applicationAst.description = description.raw
  applicationAst.htmlDescription = description.html

  # Sections
  applicationAst.sections = transformSections(element)

  applicationAst


module.exports = {
  transformAst
  transformError: (source, err) -> err
}
