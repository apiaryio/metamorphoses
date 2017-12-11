/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const {assert} = require('chai');

const lodash = require('../src/adapters/refract/helper');
const refractAdapter = require('../src/adapters/refract-adapter');

describe('Transformations • API Elements', function() {
  describe('Multiple Data Structures', function() {
    let applicationAst = null;

    before(function() {
      const parseResultElement = require('./fixtures/refract-parse-result-data-structures.json');
      const apiElement = lodash.chain(parseResultElement)
        .content()
        .find({element: 'category', meta: {classes: ['api']}})
        .value();

      return applicationAst = refractAdapter.transformAst(apiElement);
    });

    it('Has correct number of Data Structure elements', () =>
      assert.strictEqual(
        applicationAst.dataStructures.length,
        2
      )
    );

    it('First element has the correct structure', () =>
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
    );

    return it('Second element has the correct structure', () =>
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
    );
  });

  return describe('No Data Structures', function() {
    let applicationAst = null;

    before(function() {
      const parseResultElement = require('./fixtures/refract-parse-result-no-data-structures.json');
      const apiElement = lodash.chain(parseResultElement)
        .content()
        .find({element: 'category', meta: {classes: ['api']}})
        .value();

      return applicationAst = refractAdapter.transformAst(apiElement);
    });

    return it('Has no Data Structure elements', () =>
      assert.strictEqual(
        applicationAst.dataStructures.length,
        0
      )
    );
  });
});
