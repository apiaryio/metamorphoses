_ = require('./helper')

blueprintApi = require('../../blueprint-api')
getDescription = require('./getDescription')

transformResources = require('./transformResources')
transformResource = require('./transformResource')


module.exports = (parentElement, location, options) ->
  resourceGroups = []

  # List of Application AST Resources (= already transformed
  # Refract Resources into the Application AST Resource).
  resourcesWithoutGroup = []

  urlPrefix = ''

  if location
    urlWithoutProtocol = location.replace(/^https?:\/\//, '')
    pathIndex = urlWithoutProtocol.indexOf("/")

    if pathIndex > 0
      urlPrefix = urlWithoutProtocol.slice(pathIndex)

      if urlPrefix isnt ''
        urlPrefix = urlPrefix.replace(/\/$/, '')

  parentElement.map((element, index) ->
    # There might be two types of elements—resource and
    # category. Categories are being mapped 1:1 to
    # sections (resource groups), resources are being
    # pushed to a temporary array and then assigned to
    # an artificial section.
    if element.element is 'resource'
      resourcesWithoutGroup = resourcesWithoutGroup.concat(
        transformResource(element, urlPrefix, options)
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

      description = getDescription(element, options)

      if element.classes.contains('resourceGroup')
        # Then create a new section in the Application AST
        # corresponding to the Category element.
        resourceGroup = new blueprintApi.Section({
          name: element.title.toValue()
          description: description.raw
          htmlDescription: description.html
          resources: transformResources(element, urlPrefix, options)
        })

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
