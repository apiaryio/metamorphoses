{assert} = require('chai')

blueprint = require('../lib/blueprint-api')
refractAdapter = require('../lib/adapters/refract-adapter')
sampleRefract = require('./fixtures/sampleRefract.json')

describe('Transformation • Refract' , ->
  context('Transforming sample refract without error', ->
    ast = null

    before( ->
      ast = refractAdapter.transformAst(sampleRefract)
    )

    it('Returns object of instance Blueprint', ->
      assert.instanceOf(ast, blueprint.Blueprint)
    )

    it('Blueprint has name: `Swagger Sample App`', ->
      assert.equal(ast.name, 'Swagger Sample App')
    )
  )
)
