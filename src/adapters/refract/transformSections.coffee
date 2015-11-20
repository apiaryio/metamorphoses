_ = require('./helper')

blueprintApi = require('../../blueprint-api')
getDescription = require('./getDescription')
transformResources = require('./transformResources')

module.exports = (element) ->
  resourceGroups = _(element)
                    .content()
                    .filter({element: 'category', meta: {classes: ['resourceGroup']}})
                    .value()


  if resourceGroups.length is 0
    resourceGroups = [
      new blueprintApi.Section({
        name: ''
        resources: transformResources(element.content[0])
      })
    ]
  else
    resourceGroups.map((resourceGroupElement) ->
      section = new blueprintApi.Section({
        name: _.get(resourceGroupElement, 'meta.title', '')
      })

      description = getDescription(resourceGroupElement)

      section.description = description.raw
      section.htmlDescription = description.html

      section.resources = transformResources(resourceGroupElement)

      section
    )
