lodash = require('lodash')
require('lodash-api-description')(lodash)

# this should be moved somewhere else but for now
filterContent = (element, conditions) ->
  lodash.chain(element)
    .get('content')
    .filter(conditions)
    .value()

lodash.mixin({
  filterContent
})


module.exports = lodash
