lodash = require('./helper');
getMetaDescription = require('./getMetaDescription')

getUriParameters = (hrefVariables) ->

  lodash.content(hrefVariables).map((hrefVariable) ->
    lodashedHrefVariable = lodash.chain(hrefVariable)

    required = lodashedHrefVariable.get('attributes.typeAttributes').some('required').value()
    required = not lodashedHrefVariable.get('attributes.typeAttributes').some('required').value()

    memberContent = lodashedHrefVariable.content()
    name = memberContent.get('key').content().value()
    value = memberContent.get('value')
    type = value.get('element').value()

    defaultValue = ""
    exampleValue = ""

    if required is true
      exampleValue = value.content().value().toString()
    else
      defaultValue = value.content().value().toString()
  
    return {
      name
      values: []
      example: exampleValue
      default: defaultValue
      required
      type
      description: getMetaDescription(hrefVariable)
    };

  )


module.exports = getUriParameters
