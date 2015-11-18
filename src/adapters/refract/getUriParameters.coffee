lodash = require('./helper')
getMetaDescription = require('./getMetaDescription')

getUriParameters = (hrefVariables) ->
  hrefVariablesContent = lodash.content(hrefVariables)

  if hrefVariablesContent is undefined
    return []

  hrefVariablesContent.map((hrefVariable) ->
    lodashedHrefVariable = lodash.chain(hrefVariable)
    typeAttributes = lodashedHrefVariable.get('attributes.typeAttributes').value()
    required = typeAttributes.indexOf('required') isnt -1
    required = typeAttributes.indexOf('optional') is -1

    memberContent = lodashedHrefVariable.content()
    key = memberContent.get('key').content().value()
    value = memberContent.get('value')
    type = value.get('element').value()

    defaultValue = ''
    exampleValue = ''

    if required is true
      exampleValue = value.content().value().toString()
    else
      defaultValue = value.content().value().toString()

    return {
      key
      values: []
      example: exampleValue
      default: defaultValue
      required
      type
      description: getMetaDescription(hrefVariable)
    }
  )


module.exports = getUriParameters
