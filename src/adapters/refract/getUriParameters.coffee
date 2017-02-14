lodash = require('./helper')
getMetaDescription = require('./getMetaDescription')

getUriParameters = (hrefVariables, options) ->
  hrefVariablesContent = lodash.content(hrefVariables)

  if hrefVariablesContent is undefined
    return undefined

  hrefVariablesContent.map((hrefVariable) ->
    lodashedHrefVariable = lodash.chain(hrefVariable)
    typeAttributes = lodashedHrefVariable
                        .get('attributes.typeAttributes')
                        .value()

    if typeAttributes
      required = typeAttributes.indexOf('required') isnt -1
    else
      required = false

    memberContent = lodashedHrefVariable.content()
    title = lodashedHrefVariable.get('meta.title', '').contentOrValue().value()
    key = memberContent.get('key').contentOrValue().value()
    memberContentValue = memberContent.get('value')

    type = title or memberContentValue.get('element').value()

    sampleValues = memberContentValue.get('attributes.samples', '').contentOrValue()
    defaultValue = memberContentValue.get('attributes.default', '').contentOrValue()
    exampleValue = ''
    values = []

    if lodash.isArray(defaultValue.value())
      defaultValue = defaultValue.first().contentOrValue().value()?.toString()
    else
      defaultValue = defaultValue.value().toString()

    if sampleValues.value()
      example = sampleValues.first().contentOrValue()

      if lodash.isArray(example.value())
        exampleValue = example.first().contentOrValue().value()?.toString()
      else
        exampleValue = example.value().toString()

    memberContentValueContent = memberContentValue.content()

    if not lodash.isArray(memberContentValueContent.value())
      exampleValue = memberContentValueContent.value()?.toString() or ''
    else
      values = memberContentValueContent.map((element) ->
        elementContent = lodash(element).content()

        if lodash.isArray(elementContent.value())
          elementContent.map('content').value()
        else
          elementContent.value()?.toString()
      ).flatten().value()

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
