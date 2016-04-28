_ = require('./helper')

getDescription = require('./getDescription')

module.exports = (parentElement) ->
  # Auth information can be present in two places:
  # 1. An `authSchemes` category that contains definitions
  # 2. An `authSchems` attribute that defines which definition to use
  authSchemes = []

  if parentElement.element is 'category'
    for child in _.get(parentElement, 'content', [])
      if child and child.element is 'category' and _.get(child, 'meta.classes', []).indexOf('authSchemes') isnt -1
        authSchemes = authSchemes.concat(child.content)

  if _.get(parentElement, 'attributes.authSchemes')
    authSchemes = authSchemes.concat(parentElement.attributes.authSchemes)

  authSchemes
