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
    )

    it('Blueprint has name: `Sample`', ->
      assert.equal(ast.name, 'Sample')
    )
  )

  describe('#getDescription', ->
    getDescription = require('../src/adapters/refract/getDescription')

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
      it('returns description', ->
        assert.isDefined(getDescription(input)['description'])
      )

      it('returns htmlDescription', ->
        assert.isDefined(getDescription(input)['htmlDescription'])
      )

      it('result is equal', ->
        assert.deepEqual(getDescription(input), result)
      )
    )
  )
)
