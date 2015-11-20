lodash = require('./helper')
getMetaDescription = require('./getMetaDescription')

getUriParameters = (hrefVariables) ->
  hrefVariablesContent = lodash.content(hrefVariables)

  if hrefVariablesContent is undefined
    return []

  hrefVariablesContent.map((hrefVariable) ->
    lodashedHrefVariable = lodash.chain(hrefVariable)
    typeAttributes = lodashedHrefVariable
                        .get('attributes.typeAttributes')
                        .value()

    required = typeAttributes?.indexOf('required') isnt -1
    required = typeAttributes?.indexOf('optional') is -1

    memberContent = lodashedHrefVariable.content()
    key = memberContent.get('key').content().value()
    memberContentValue = memberContent.get('value')
    type = memberContentValue.get('element').value()

    defaultValue = ''
    exampleValue = ''
    values = []

    if (memberContentValue.has('attributes.default').value())
      defaultValue = memberContentValue.get('attributes.default')
        .first().content().value().toString()

    memberContentValueContent = memberContentValue.content()

    if not lodash.isArray(memberContentValueContent.value())
      exampleValue = memberContentValueContent.value()?.toString()
    else
      values = memberContentValueContent.map((element) ->
        {value: lodash(element).content().value()?.toString()}
      ).value()

    return {
      key
      values
      example: exampleValue
      default: defaultValue
      required
      type
      description: getMetaDescription(hrefVariable)
    }
  )


module.exports = getUriParameters
