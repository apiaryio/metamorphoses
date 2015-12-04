_ = require('./helper')

blueprintApi = require('../../blueprint-api')
getDescription = require('./getDescription')

transformResources = require('./transformResources')
transformResource = require('./transformResource')


module.exports = (parentElement) ->
  resourceGroups = []

  # List of Application AST Resources (= already transformed
  # Refract Resources into the Application AST Resource).
  applicationAstResources = []

  _.forEach(_.get(parentElement, 'content'), (element, index) ->
    # There might be two types of elements—resource and
    # category. Categories are being mapped 1:1 to
    # sections (resource groups), resources are being
    # pushed to a temporary array and then assigned to
    # an artificial section.
    if element.element is 'resource'
      applicationAstResources = applicationAstResources.concat(
        transformResource(element)
      )

    if element.element is 'category'
      # First let's create an artificial resource group (section)
      # for previous resources.
      if applicationAstResources.length
        resourceGroups.push(new blueprintApi.Section({
          name: ''
          resources: applicationAstResources
        }))

        applicationAstResources = []

      description = getDescription(element)

      # Then create a new section in the Application AST
      # corresponding to the Category element.
      resourceGroup = new blueprintApi.Section({
        name: _.chain(element).get('meta.title', '').contentOrValue().value()
        description: description.raw
        htmlDescription: description.html
        resources: transformResources(element)
      })

      resourceGroups.push(resourceGroup)
  )

  # Make sure tu flush the resources into an an artificial
  # resource group (section).
  if applicationAstResources.length
    resourceGroups.push(
      new blueprintApi.Section({
        name: ''
        resources: applicationAstResources
      })
    )

  resourceGroups
