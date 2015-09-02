
{assert} = require('chai')

blueprintApi = require('../lib/blueprint-api')


describe('Blueprint de/serialization Tests', ->
  describe('Try de/serialize empty resource class', ->
    emptyResource = new blueprintApi.Resource()
    deserializedResource = blueprintApi.Resource.fromJSON(emptyResource.toJSON())

    it 'empty resource should same as deserialized', ->  assert.deepEqual deserializedResource, emptyResource
    it 'serialization request should be same for both resources', ->  assert.deepEqual emptyResource.toJSON(), deserializedResource.toJSON()

  describe 'Try de/serialize empty resource class', ->
    json =
      method: 'POST'
      uriTemplate: '/user/save'
      nameMethod: 'Create user'
      actionRelation: 'save'
      request:
        name: 'request'
        reference: 'refer'

    resource = blueprintApi.Resource.fromJSON(json)

    it('should have setted values from json', ->
      assert.equal(resource.method, 'POST')
      assert.equal(resource.uriTemplate, '/user/save')
      assert.equal(resource.nameMethod, 'Create user')
      assert.equal(resource.actionRelation, 'save')
      assert.deepEqual(resource.request, blueprintApi.Request.fromJSON(json.request))
    )

    it('have other values undefined or empty array', ->
      assert.isUndefined(resource.actionUriTemplate)
      assert.isUndefined(resource.resolvedAttributes)
      assert.isUndefined(resource.model)
      assert.deepEqual(resource.requests, [])
    )

    it('should be equal serialized and deserialized object', ->
      copy = blueprintApi.Resource.fromJSON(resource.toJSON())
      assert.deepEqual(resource, copy)
      assert.deepEqual(resource.toJSON(), copy.toJSON())
    )
  )
)
