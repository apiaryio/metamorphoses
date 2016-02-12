{assert} = require('chai')

apiBlueprintAdapter = require('../src/adapters/api-blueprint-adapter')

describe('Transformations • API Blueprint AST', ->
  describe('Multiple Data Structures', ->
    applicationAst = null;
    before(->
      applicationAst = apiBlueprintAdapter.transformAst(
        require('./fixtures/api-blueprint-parse-result-data-structures.json')
      )
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
)
