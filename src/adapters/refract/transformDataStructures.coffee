minim = require('./minim')

module.exports = (parentElement, options) ->
  dataStructures = []

  parentElement.map((element) ->
    if element.classes.contains('dataStructures')
      element.map((item) ->
        dataStructures.push(minim.serialiser06.serialise(item))
      )
  )

  dataStructures
