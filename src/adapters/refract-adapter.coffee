_ = require('./refract/helper')
blueprintApi = require('../blueprint-api')

getDescription = require('./refract/getDescription')
transformSections = require('./refract/transformSections')

transformAst = (element) ->

  applicationAst = new blueprintApi.Blueprint({
    name: _.chain(element).get('meta.title', '').fixNewLines().value()
    version: '22' # how about this? we don't have in refract parse result at all
    metadata: []
  })

  # Metadata and location
  applicationAst.metadata =
    _.chain(element)
    .get('attributes.meta')
    .filter({meta: {classes: ['user']}})
    .map((entry) ->
      content = _.content(entry)

      name = _(entry).content().get('key.content')
      value = _(entry).content().get('value.content', '')

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
