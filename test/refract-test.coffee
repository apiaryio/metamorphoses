{assert} = require('chai')

blueprint = require('../src/blueprint-api')
refractAdapter = require('../src/adapters/refract-adapter')

sampleParseResult = require('./fixtures/sampleParseResult.json')
sampleAppAst = require('./fixtures/sampleAppAst.json')

describe('Transformation • Refract' , ->
  context('Transforming sample refract without error', ->
    ast = null

    before( ->
      ast = refractAdapter.transformAst(sampleParseResult)
    )

    it('Returns object of instance Blueprint', ->
      assert.instanceOf(ast, blueprint.Blueprint)
      console.log JSON.stringify(ast.toJSON(), null, 2)
    )

    it('json value is equal', ->
      #assert.deepEqual(ast.toJSON(), sampleAppAst)
    )
  )
)
