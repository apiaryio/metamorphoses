_ = require('./refract/helper')
blueprintApi = require('../blueprint-api')

getDescription = require('./refract/getDescription')
transformSections = require('./refract/transformSections')

transformAst = (element) ->
  category = _.chain(element).get('content').filter({element: 'category'})
                .first()
                .value()

  applicationAst = new blueprintApi.Blueprint({
    name: _.get(category, 'meta.title')
    metadata: []
  })

  # Metadata and location
  applicationAst.metadata =
    _.chain(category)
    .get('attributes.meta')
    .filter({meta: {classes: ['user']}})
    .map((entry) ->
      content = _.content(entry)

      name = _.get(content, 'key.content')
      value = _.get(content, 'value.content')
      applicationAst.location = value if name is 'HOST'
      {name, value}
    ).value()

  # description
  description = getDescription(category)

  applicationAst.description = description.raw
  applicationAst.htmlDescription = description.html

  # Sections
  applicationAst.sections = transformSections(category)

  applicationAst


module.exports = {
  transformAst
  transformError: (source, err) -> err
}
