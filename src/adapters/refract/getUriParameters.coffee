lodash = require('./helper')
getMetaDescription = require('./getMetaDescription')

getUriParameters = (hrefVariables, options) ->
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
    key = memberContent.get('key').contentOrValue().value()
    memberContentValue = memberContent.get('value')
    type = memberContentValue.get('element').value()

    sampleValues = memberContentValue.get('attributes.samples', '').contentOrValue()
    defaultValue = memberContentValue.get('attributes.default', '').contentOrValue().value().toString()
    exampleValue = ''
    values = []

    if lodash.isArray(sampleValues.value())
      exampleValue = sampleValues.first().contentOrValue().value().toString()

    memberContentValueContent = memberContentValue.content()

    if not lodash.isArray(memberContentValueContent.value())
      exampleValue = memberContentValueContent.value()?.toString() or ''
    else
      values = memberContentValueContent.map((element) ->
        lodash(element).content().value()?.toString()
      ).value()

    return {
      description: getMetaDescription(hrefVariable, options)
      type
      required
      default: defaultValue
      example: exampleValue
      values
      key
    }
  )


module.exports = getUriParameters
