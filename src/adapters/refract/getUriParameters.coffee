lodash = require('lodash');
getDescription = require('./getDescription')

getUriParameters = (hrefVariables) ->

  lodash.content(hrefVariables).map((hrefVariable) ->
    return {
      key: lodash.content(hrefVariable).get('key.value'),
      values: lodash.content(hrefVariable).get('value.content'),
      example: lodash.content(hrefVariable).get('value.content'),
      default: lodash.content(hrefVariable).get('value.element.attributes.default'),
      required: lodash(hrefVariable).get('attributes.typeAttributes.required', false),
      type: lodash.content(hrefVariable).get('value.element'),
      description: getDescription(hrefVariable).raw
    };

  )


module.exports = getUriParameters
