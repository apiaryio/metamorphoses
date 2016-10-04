{assert} = require('chai')
{mergeParams} = require('../src/metamorphoses')

resourceParams = [{
  key: 'id'
  type: 'string'
  values: []
  required: false
  example: 'id value'
  default: null
  description: 'Id'
}]

actionParams = [{
  key: 'name'
  type: 'string'
  values: []
  required: false
  example: 'name value'
  default: null
  description: 'Name'
}]

describe('Metamorphoses • Utility', ->
  context('Merging 1 resource parameter and 1 action parameter', ->
    params = undefined

    beforeEach( ->
      params = mergeParams(resourceParams, actionParams)
    )

    it('should give 2 parameters', ->
      assert.equal(params.length, 2)
    )

    it('should have resource parameter first', ->
      assert.equal(params[0].key, 'id')
    )

    it('should have action parameter last', ->
      assert.equal(params[1].key, 'name')
    )
  )

  context('Merging 1 resource parameter and 1 action parameter with the same name', ->
    params = undefined

    beforeEach( ->
      resourceParamsWithName = [{
        key: 'name'
        type: 'string'
        values: []
        required: false
        example: 'id value'
        default: null
        description: 'Id'
      }]

      params = mergeParams(resourceParamsWithName, actionParams)
    )

    it('should give 1 parameter', ->
      assert.equal(params.length, 1)
    )

    it('should have action parameter', ->
      assert.equal(params[0].key, 'name')
      assert.equal(params[0].description, 'Name')
    )
  )
)
