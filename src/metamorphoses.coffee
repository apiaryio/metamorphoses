
typer = require('media-typer')

blueprintApi = require('./blueprint-api')
apiBlueprintAdapter = require('./adapters/api-blueprint-adapter')
apiaryBlueprintAdapter = require('./adapters/apiary-blueprint-adapter')


createAdapter = (mimeType) ->
  try
    parsedMimeType = typer.parse(mimeType)
  catch e
    return # not parseable mime type?!

  if parsedMimeType.type isnt 'application'
    return

  # Legacy Apiary Blueprint
  if parsedMimeType.subtype is 'vnd.legacyblueprint.ast'
    if not parsedMimeType.suffix or parsedMimeType.suffix is 'json'
      return apiaryBlueprintAdapter
    return

  # API Blueprint
  # http://github.com/apiaryio/api-blueprint-ast#serialization-formats
  if parsedMimeType.subtype is 'vnd.apiblueprint.ast' or
     parsedMimeType.subtype is 'vnd.apiblueprint.ast.raw'
    if not parsedMimeType.suffix or parsedMimeType.suffix is 'json'
      return apiBlueprintAdapter
    return


module.exports = {
  blueprintApi
  createAdapter
  apiBlueprintAdapter
  apiaryBlueprintAdapter
}
