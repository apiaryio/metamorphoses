lodash = require('lodash')
require('lodash-api-description')(lodash)

fixNewLines = (str) ->
  return unless lodash.isString(str)
  str.replace(/\n$/, '')

# Get a source map from an element or its metadata (e.g. title)
sourceMap = (element) ->
  sourceMap = lodash.get(element, 'attributes.sourceMap', [])

  if not sourceMap.length
    # Element itself has no source map, but its `title` may have one
    sourceMap = lodash.get(element, 'meta.title.attributes.sourceMap', [])

  if not sourceMap.length
    # Resources must have a URI
    sourceMap = lodash.get(element, 'attributes.href.attributes.sourceMap', [])

  if not sourceMap.length
    # Transitions must have a request method, even for API Blueprint shorthand
    # input using e.g. `### GET`
    sourceMap = lodash
      .chain(element)
      .httpTransactions()
      .first()
      .httpRequests()
      .first()
      .get('attributes.method.attributes.sourceMap', [])
      .value() or []

  # This converts a list of `sourceMap` refract elements into a list of source
  # map location arrays [[pos1, len1], [pos2, len2], ...]
  lodash.flatten(sourceMap.map((item) -> lodash.contentOrValue(item)))

lodash.mixin({
  fixNewLines
  sourceMap
})

module.exports = lodash
