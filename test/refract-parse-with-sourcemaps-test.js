/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const {assert} = require('chai');

const lodash = require('../src/adapters/refract/helper');
const refractAdapter = require('../src/adapters/refract-adapter');

describe('Transformations • Refract', () =>
  context('Parse result with source maps', function() {
    const parseResultElement = require('./fixtures/refract-parse-result-with-sourcemaps.json');
    let apiDescriptionElement = null;
    before( () =>
      apiDescriptionElement = lodash.chain(parseResultElement)
        .content()
        .find({element: 'category', meta: {classes: ['api']}})
        .value()
    );

    return it('Transformation does not throw any exception', () => assert.doesNotThrow(() => refractAdapter.transformAst(apiDescriptionElement)));
  })
);
