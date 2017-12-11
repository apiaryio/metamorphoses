/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const {assert} = require('chai');

const {createAdapter} = require('../src/metamorphoses');
const refractAdapter = require('../src/adapters/refract-adapter');


describe('#createAdapter', function() {
  it('does not recognize mime type with wrong base type', () => assert.notOk(createAdapter('text/vnd.legacyblueprint.ast')));

  it('recognizes JSON serialization of refract with json suffix', () =>
    assert.equal(
      createAdapter('application/vnd.refract.api-description+json'),
      refractAdapter
    )
  );

  it('recognizes JSON serialization of refract without suffix', () =>
    assert.equal(
      createAdapter('application/vnd.refract.api-description'),
      refractAdapter
    )
  );

  return it('does not recognizes YAML serialization of refract with yaml suffix', () => assert.equal(createAdapter('application/vnd.refract.api-description+yaml')));
});
