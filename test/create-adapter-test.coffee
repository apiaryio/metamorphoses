{assert} = require('chai')

{createAdapter} = require('../src/metamorphoses')
refractAdapter = require('../src/adapters/refract-adapter')


describe('#createAdapter', ->
  it('does not recognize mime type with wrong base type', ->
    assert.notOk(createAdapter('text/vnd.legacyblueprint.ast'))
  )

  it('recognizes JSON serialization of refract with json suffix', ->
    assert.equal(
      createAdapter('application/vnd.refract.api-description+json'),
      refractAdapter
    )
  )

  it('recognizes JSON serialization of refract without suffix', ->
    assert.equal(
      createAdapter('application/vnd.refract.api-description'),
      refractAdapter
    )
  )

  it('does not recognizes YAML serialization of refract with yaml suffix', ->
    assert.equal(createAdapter('application/vnd.refract.api-description+yaml'))
  )
)
