lodash = require('./helper')
minim = require('./minim')
getMetaDescription = require('./getMetaDescription')

getUriParameters = (hrefVariables, options) ->
  if hrefVariables is undefined
    return undefined

  hrefVariables.content.map((hrefVariable) ->
    typeAttributes = hrefVariable.attributes.get('typeAttributes')?.toValue()
    required = typeAttributes?.contains('required') || false
    
    title = hrefVariable.title.toValue()
    key = hrefVariable.key.toValue()
    value = hrefVariable.value
    memberContentValue = lodash.chain(minim.serialiser06.serialise(value))

    type = title or value.element

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
