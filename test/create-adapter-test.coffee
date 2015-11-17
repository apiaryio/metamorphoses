{assert} = require('chai')

{createAdapter} = require('../src/metamorphoses')
apiBlueprintAdapter = require('../src/adapters/api-blueprint-adapter')
apiaryBlueprintAdapter = require('../src/adapters/apiary-blueprint-adapter')
refractAdapter = require('../src/adapters/refract-adapter')


describe('#createAdapter', ->
  it('recognizes raw JSON serialization of API Blueprint AST', ->
    assert.equal(
      createAdapter('application/vnd.apiblueprint.ast.raw+json'),
      apiBlueprintAdapter
    )
  )

  it('recognizes JSON serialization of API Blueprint AST', ->
    assert.equal(
      createAdapter('application/vnd.apiblueprint.ast+json'),
      apiBlueprintAdapter
    )
  )

  it('recognizes JSON serialization of API Blueprint AST', ->
    assert.equal(
      createAdapter('application/vnd.apiblueprint.ast+json'),
      apiBlueprintAdapter
    )
  )

  it('recognizes API Blueprint AST', ->
    assert.equal(
      createAdapter('application/vnd.apiblueprint.ast'),
      apiBlueprintAdapter
    )
  )

  it('does not recognize raw YAML serialization of API Blueprint AST', ->
    assert.notOk(createAdapter('application/vnd.apiblueprint.ast.raw+yaml'))
  )

  it('does not recognize JSON serialization of API Blueprint AST with rendered HTML', ->
    assert.notOk(createAdapter('application/vnd.apiblueprint.ast.html+json'))
  )

  it('does not recognize YAML serialization of API Blueprint AST with rendered HTML', ->
    assert.notOk(createAdapter('application/vnd.apiblueprint.ast.html+yaml'))
  )

  it('recognizes JSON serialization of legacy Apiary Blueprint AST', ->
    assert.equal(
      createAdapter('application/vnd.legacyblueprint.ast+json'),
      apiaryBlueprintAdapter
    )
  )

  it('recognizes legacy Apiary Blueprint AST', ->
    assert.equal(
      createAdapter('application/vnd.legacyblueprint.ast'),
      apiaryBlueprintAdapter
    )
  )

  it('does not recognize mime type with wrong base type', ->
    assert.notOk(createAdapter('text/vnd.legacyblueprint.ast'))
  )

  it('recognizes JSON serialization of refract with json suffix', ->
    assert.equal(
      createAdapter('application/vnd.refract+json'),
      refractAdapter
    )
  )

  it('recognizes JSON serialization of refract without suffix', ->
    assert.equal(
      createAdapter('application/vnd.refract'),
      refractAdapter
    )
  )

  it('recognizes JSON serialization of refract with yaml suffix', ->
    assert.equal(createAdapter('application/vnd.refract+yaml'))
  )
)
