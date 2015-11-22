_ = require('./helper')

blueprintApi = require('../../blueprint-api')
getDescription = require('./getDescription')
transformResources = require('./transformResources')

module.exports = (element) ->
  resourceGroups = []
  resourceGroupsElements = _.chain(element)
                    .content()
                    .filter({element: 'category', meta: {classes: ['resourceGroup']}})
                    .value()

  # If we can't find any resource group we can assume that there are Resources directly
  if resourceGroupsElements.length is 0
    resourceGroups.push(
      new blueprintApi.Section({
        name: ''
        resources: transformResources(element)
      })
    )
  else
    resourceGroupsElements.forEach((resourceGroupElement) ->
      section = new blueprintApi.Section({
        name: _.get(resourceGroupElement, 'meta.title', '')
      })

      description = getDescription(resourceGroupElement)

      section.description = description.raw
      section.htmlDescription = description.html

      section.resources = transformResources(resourceGroupElement)

      resourceGroups.push(section)
    )

  resourceGroups
