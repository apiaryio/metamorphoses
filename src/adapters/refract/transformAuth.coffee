minim = require('./minim')

module.exports = (parentElement, options) ->
  # Auth information can be present in two places:
  # 1. An `authSchemes` category that contains definitions
  # 2. An `authSchemes` attribute that defines which definition to use
  authSchemes = []

  if parentElement.element is 'category'
    (parentElement.authSchemeGroups or []).forEach((authSchemeGroup) ->
      (authSchemeGroup.authSchemes or []).forEach((authScheme) ->
        authSchemes.push(minim.serialiser06.serialise(authScheme))
      )
    )

  if parentElement.element is 'httpTransaction'
    (parentElement.authSchemes or []).forEach((authScheme) ->
      authSchemes.push(minim.serialiser06.serialise(authScheme))
    )

  authSchemes
