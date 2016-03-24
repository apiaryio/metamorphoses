_ = require('./helper')

blueprintApi = require('../../blueprint-api')
getDescription = require('./getDescription')

transformResources = require('./transformResources')
transformResource = require('./transformResource')


module.exports = (parentElement) ->
  resourceGroups = []

  # List of Application AST Resources (= already transformed
  # Refract Resources into the Application AST Resource).
  resourcesWithoutGroup = []

  _.forEach(_.get(parentElement, 'content'), (element, index) ->
    # There might be two types of elements—resource and
    # category. Categories are being mapped 1:1 to
    # sections (resource groups), resources are being
    # pushed to a temporary array and then assigned to
    # an artificial section.
    if element.element is 'resource'
      resourcesWithoutGroup = resourcesWithoutGroup.concat(
        transformResource(element)
      )

    if element.element is 'category'
      # First let's create an artificial resource group (section)
      # for resources without a group.
      if resourcesWithoutGroup.length
        resourceGroups.push(new blueprintApi.Section({
          name: ''
          resources: resourcesWithoutGroup
        }))

        # Resources have been added to a group, reset.
        resourcesWithoutGroup = []

      description = getDescription(element)

      # Then create a new section in the Application AST
      # corresponding to the Category element.
      resourceGroup = new blueprintApi.Section({
        name: _.chain(element).get('meta.title', '').contentOrValue().value()
        description: description.raw
        htmlDescription: description.html
        resources: transformResources(element)
      })

      sourceMap = _.sourceMap(element)
      if sourceMap.length
        resourceGroup.sourcemap = sourceMap

      resourceGroups.push(resourceGroup)
  )

  # Make sure tu flush the resources into an an artificial
  # resource group (section).
  if resourcesWithoutGroup.length
    resourceGroups.push(
      new blueprintApi.Section({
        name: ''
        resources: resourcesWithoutGroup
      })
    )

  resourceGroups
