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

  _.forEach(parentElement.content, (element, index) ->
    # If the element is a resource, transform it
    # into the Application AST Resource and push it
    # to a temporary array, we'll create an artificial
    # resource group (section) for these resources
    # later in the process.
    if element.element is 'resource'
      applicationAstResources = applicationAstResources.concat(
        transformResource(element)
      )

    # Element is category (resource group most probably).
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

    # If this the last run, make sure tu flush the resources
    # into an an artificial resource group (section).
    isLastRun = index is (parentElement.content.length - 1)

    if isLastRun and applicationAstResources.length
      resourceGroups.push(
        new blueprintApi.Section({
          name: ''
          resources: applicationAstResources
        })
      )
  )

  resourceGroups
