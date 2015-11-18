lodash = require('./helper');
getMetaDescription = require('./getMetaDescription')

getUriParameters = (hrefVariables) ->

  lodash.content(hrefVariables).map((hrefVariable) ->
    lodashedHrefVariable = lodash(hrefVariable)

    required = lodashedHrefVariable.get('attributes.typeAttributes.required', false),
    if lodashedHrefVariable.has('attributes.typeAttributes.optional') and required isnt true
      required = lodashedHrefVariable.get('attributes.typeAttributes.optional')

    memberContent = lodashedHrefVariable.content()
    key = memberContent.get('key').content()
    value = memberContent.get('value')
    type = value.get('element')

    values = [value.content()]
    default = undefined
    example = undefined

    if required is true
      example = value.content()
    else
      default = value.content()
  
    return {
      key
      values
      example
      default
      required
      type
      description: getMetaDescription(hrefVariable)
    };

  )


module.exports = getUriParameters
