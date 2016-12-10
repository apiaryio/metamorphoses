
typer = require('media-typer')

blueprintApi = require('./blueprint-api')
markdown = require('./adapters/markdown')
apiBlueprintAdapter = require('./adapters/api-blueprint-adapter')
refractAdapter = require('./adapters/refract-adapter')


createAdapter = (mimeType) ->
  try
    parsedMimeType = typer.parse(mimeType)
  catch e
    return # not parseable mime type?!

  if parsedMimeType.type isnt 'application'
    return

  # API Blueprint
  # http://github.com/apiaryio/api-blueprint-ast#serialization-formats
  if parsedMimeType.subtype is 'vnd.apiblueprint.ast' or
     parsedMimeType.subtype is 'vnd.apiblueprint.ast.raw'
    if not parsedMimeType.suffix or parsedMimeType.suffix is 'json'
      return apiBlueprintAdapter
    return

  # Refract
  # https://github.com/refractproject/refract-spec
  if parsedMimeType.subtype is 'vnd.refract.api-description'
    if not parsedMimeType.suffix or parsedMimeType.suffix is 'json'
      return refractAdapter
    return


mergeParams = (resourceParams = [], actionParams = []) ->
  params = []

  actionParamKeys = actionParams.map((param) -> param.key)

  for param in resourceParams
    if param.key not in actionParamKeys
      params.push(param)

  params.concat(actionParams)

module.exports = {
  # Blueprint API (aka Application AST)
  blueprintApi

  # Adapters
  createAdapter
  apiBlueprintAdapter
  refractAdapter

  # Markdown rendering
  markdown

  # Utility
  mergeParams
}
