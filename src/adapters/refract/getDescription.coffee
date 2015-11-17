_ = require('./helper')
markdown = require('../markdown')

getDescription = (element) ->
  description = _.get(element, 'meta.description') or null
  {
    description
    htmlDescription: if description then markdown.toHtmlSync(description) else null
  }

module.exports = getDescription
