/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const {assert} = require('chai');
const {mergeParams} = require('../src/metamorphoses');


describe('Metamorphoses • Utility', function() {
  context('Merging 0 resource parameter with 1 action parameter', function() {
    const actionParams = [{
      key: 'name',
      type: 'string',
      values: [],
      required: false,
      example: 'name value',
      default: null,
      description: 'Name'
    }];

    const params = mergeParams([], actionParams);

    it('should give 1 parameter', () => assert.equal(params.length, 1));

    return it('should have action parameter', () => assert.equal(params[0].key, 'name'));
  });

  context('Merging 1 resource parameter with 0 action parameter', function() {
    const resourceParams = [{
      key: 'id',
      type: 'string',
      values: [],
      required: false,
      example: 'id value',
      default: null,
      description: 'Id'
    }];

    const params = mergeParams(resourceParams);

    it('should give 1 parameter', () => assert.equal(params.length, 1));

    return it('should have resource parameter', () => assert.equal(params[0].key, 'id'));
  });

  context('Merging 1 resource parameter and 1 action parameter', function() {
    const resourceParams = [{
      key: 'id',
      type: 'string',
      values: [],
      required: false,
      example: 'id value',
      default: null,
      description: 'Id'
    }];

    const actionParams = [{
      key: 'name',
      type: 'string',
      values: [],
      required: false,
      example: 'name value',
      default: null,
      description: 'Name'
    }];

    const params = mergeParams(resourceParams, actionParams);

    it('should give 2 parameters', () => assert.equal(params.length, 2));

    it('should have resource parameter first', () => assert.equal(params[0].key, 'id'));

    return it('should have action parameter last', () => assert.equal(params[1].key, 'name'));
  });

  context('Merging 1 resource parameter and 1 action parameter with the same name', function() {
    const resourceParams = [{
      key: 'name',
      type: 'string',
      values: [],
      required: false,
      example: 'id value',
      default: null,
      description: 'Id'
    }];

    const actionParams = [{
      key: 'name',
      type: 'string',
      values: [],
      required: false,
      example: 'name value',
      default: null,
      description: 'Name'
    }];

    const params = mergeParams(resourceParams, actionParams);

    it('should give 1 parameter', () => assert.equal(params.length, 1));

    return it('should have action parameter', function() {
      assert.equal(params[0].key, 'name');
      return assert.equal(params[0].description, 'Name');
    });
  });

  return context('Merging 2 resource parameters and 2 action parameters with the same names', function() {
    const resourceParams = [{
      key: 'name1',
      type: 'string',
      values: [],
      required: false,
      example: 'id1 value',
      default: null,
      description: 'Id1'
    }, {
      key: 'name2',
      type: 'string',
      values: [],
      required: false,
      example: 'id2 value',
      default: null,
      description: 'Id2'
    }];

    const actionParams = [{
      key: 'name1',
      type: 'string',
      values: [],
      required: false,
      example: 'name1 value',
      default: null,
      description: 'Name1'
    }, {
      key: 'name2',
      type: 'string',
      values: [],
      required: false,
      example: 'name2 value',
      default: null,
      description: 'Name2'
    }];

    const params = mergeParams(resourceParams, actionParams);

    it('should give 2 parameters', () => assert.equal(params.length, 2));

    return it('should have action parameters', function() {
      assert.equal(params[0].key, 'name1');
      assert.equal(params[0].description, 'Name1');
      assert.equal(params[1].key, 'name2');
      return assert.equal(params[1].description, 'Name2');
    });
  });
});
