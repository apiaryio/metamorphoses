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

  describe('#getDescription', ->
    getDescription = require('../lib/adapters/refract/getDescription')

    [
      {
        input:
          element: 'resource'
          meta:
            title: 'Question'
            description: 'A __Question__ object has the following attributes.'
          attributes: {}
          content: [{element: 'dataStructure'}]
        result:
          description: 'A __Question__ object has the following attributes.'
          htmlDescription: '<p>A <strong>Question</strong> object has the following attributes.</p>\n'
      }
      {
        input:
          element: 'resource'
          meta:
            title: 'Question'
          attributes: {}
          content: [{element: 'dataStructure'}]
        result:
          description: null
          htmlDescription: null
      }
    ].forEach(({input, result}) ->
      it("returns `#{result}`", ->
        assert.deepEqual(getDescription(input), result)
      )
    )
  )
)
