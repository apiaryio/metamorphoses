{assert} = require('chai')

lodash = require('../src/adapters/refract/helper')
refractAdapter = require('../src/adapters/refract-adapter')

describe('Transformations • Refract', ->
  context('Parse result with source maps', ->
    parseResultElement = require('./fixtures/refract-parse-result-with-sourcemaps.json')
    apiDescriptionElement = null
    before( ->
      apiDescriptionElement = lodash.chain(parseResultElement)
        .content()
        .find({element: 'category', meta: {classes: ['api']}})
        .value()
    )

    it('Transformation does not throw any exception', ->
      assert.doesNotThrow(-> refractAdapter.transformAst(apiDescriptionElement))
    )
  )
)
