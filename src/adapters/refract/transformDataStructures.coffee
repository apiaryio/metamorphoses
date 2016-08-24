_ = require('./helper')

module.exports = (parentElement, options) ->
  dataStructures = []

  _.forEach(_.get(parentElement, 'content'), (element, index) ->
    if element.element is 'category'
      classes = _.get(element, 'meta.classes', [])

      if classes.indexOf('dataStructures') isnt -1
        dataStructures = dataStructures.concat(
          _.get(element, 'content')
        )
  )

  dataStructures
