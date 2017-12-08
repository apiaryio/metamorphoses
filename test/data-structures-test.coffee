{assert} = require('chai')

lodash = require('../src/adapters/refract/helper')
refractAdapter = require('../src/adapters/refract-adapter')

describe('Transformations • API Elements', ->
  describe('Multiple Data Structures', ->
    applicationAst = null

    before(->
      parseResultElement = require('./fixtures/refract-parse-result-data-structures.json')
      apiElement = lodash.chain(parseResultElement)
        .content()
        .find({element: 'category', meta: {classes: ['api']}})
        .value()

      applicationAst = refractAdapter.transformAst(apiElement)
    )

    it('Has correct number of Data Structure elements', ->
      assert.strictEqual(
        applicationAst.dataStructures.length,
        2
      )
    )

    it('First element has the correct structure', ->
      assert.deepEqual(
        {
          "element": "dataStructure",
          "content": [
            {
              "element": "object",
              "meta": {
                "id": "Message Base"
              },
              "content": [
                {
                  "element": "member",
                  "meta": {
                    "description": "asdasd-asdasd-asdasd"
                  },
                  "content": {
                    "key": {
                      "element": "string",
                      "content": "id"
                    },
                    "value": {
                      "element": "string",
                      "content": "asdasd"
                    }
                  }
                }
              ]
            }
          ]
        },
        applicationAst.dataStructures[0]
      )
    )

    it('Second element has the correct structure', ->
      assert.deepEqual(
        {
          "element": "dataStructure",
          "content": [
            {
              "element": "object",
              "meta": {
                "id": "Message"
              },
              "content": [
                {
                  "element": "member",
                  "content": {
                    "key": {
                      "element": "string",
                      "content": "text"
                    },
                    "value": {
                      "element": "string",
                      "content": "Hello!"
                    }
                  }
                }
              ]
            }
          ]
        },
        applicationAst.dataStructures[1]
      )
    )
  )

  describe('No Data Structures', ->
    applicationAst = null

    before(->
      parseResultElement = require('./fixtures/refract-parse-result-no-data-structures.json')
      apiElement = lodash.chain(parseResultElement)
        .content()
        .find({element: 'category', meta: {classes: ['api']}})
        .value()

      applicationAst = refractAdapter.transformAst(apiElement)
    )

    it('Has no Data Structure elements', ->
      assert.strictEqual(
        applicationAst.dataStructures.length,
        0
      )
    )
  )
)
