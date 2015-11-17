
{assert} = require('chai')
sinon = require('sinon')
ApiaryBlueprintParser = require('apiary-blueprint-parser')

blueprintApi = require('../src/blueprint-api')
apiaryBlueprintAdapter = require('../src/adapters/apiary-blueprint-adapter')


getTransformedAst = (apiaryBlueprint) ->
  transformedAst = undefined
  stub = sinon.stub(blueprintApi.Blueprint, 'fromJSON', (json) ->
    # We need to catch the plain JS object after it is transformed, but
    # before it is used for deserialization. The
    # `apiaryBlueprintAdapter.transformAst` function calls
    # `blueprintApi.Blueprint.fromJSON` as the very last thing, so here we
    # should get exactly what we need.
    transformedAst = json
  )
  parserAst = ApiaryBlueprintParser.parse(apiaryBlueprint)
  apiaryBlueprintAdapter.transformAst(parserAst.toJSON())
  stub.restore()
  return transformedAst


describe('Serialization of the Blueprint interface (Application AST)', ->
  describe('Blueprint object', ->
    blueprint = '''
      HOST: http://localhost:8002/v1/

      --- Testing ---

      HEAD /resource
      < 200

    '''
    transformedAst = getTransformedAst(blueprint)
    obj = blueprintApi.Blueprint.fromJSON(transformedAst)
    deserializedObj = blueprintApi.Blueprint.fromJSON(obj.toJSON())

    it('Instance should equal to deserialized instance', ->
      assert.deepEqual(obj, deserializedObj)
    )
    it('JSON made from instance should equal to JSON made from deserialized instance', ->
      assert.deepEqual(obj.toJSON(), deserializedObj.toJSON())
    )
    it('Blueprint made from instance should equal to Blueprint made from deserialized instance', ->
      assert.equal(obj.toBlueprint(), deserializedObj.toBlueprint())
    )
    it('Blueprint made from instance should equal to original Blueprint', ->
      assert.equal(obj.toBlueprint(), blueprint)
    )
  )


  describe('Resource object', ->
    describe('Empty instance', ->
      obj = new blueprintApi.Resource()
      deserializedObj = blueprintApi.Resource.fromJSON(obj.toJSON())

      it('Instance should equal to deserialized instance', ->
        assert.deepEqual(obj, deserializedObj)
      )
      it('JSON made from instance should equal to JSON made from deserialized instance', ->
        assert.deepEqual(obj.toJSON(), deserializedObj.toJSON())
      )

      describe('Default properties', ->
        tests = [
          {property: 'method', expected: 'GET'}
          {property: 'uriTemplate', expected: ''}
          {property: 'nameMethod'}
          {property: 'actionRelation'}
          {property: 'request'}
          {property: 'url', expected: '/'}
          {property: 'name'}
          {property: 'actionName'}
          {property: 'actionDescription'}
          {property: 'actionHtmlDescription'}
          {property: 'description'}
          {property: 'htmlDescription'}
          {property: 'descriptionMethod'}
          {property: 'resourceDescription'}
          {property: 'model'}
          {property: 'headers'}
          {property: 'actionHeaders'}
          {property: 'parameters'}
          {property: 'resourceParameters'}
          {property: 'actionParameters'}
          {property: 'requests', expected: []}
          {property: 'responses', expected: []}
          {property: 'attributes'}
          {property: 'resolvedAttributes'}
          {property: 'actionAttributes'}
          {property: 'resolvedActionAttributes'}
          {property: 'actionUriTemplate'}
        ]

        tests.forEach(({property, expected}) ->
          it("Property '#{property}' is set to '#{expected}'", ->
            assert.deepEqual(obj[property], expected)
          )
        )

        it('Instance does not include any other properties', ->
          properties = (property for own property of (new blueprintApi.Resource()))
          untestedProperties = (property for {property} in tests when property not in properties)

          assert.deepEqual(untestedProperties, [])
        )
      )
    )

    describe('Individual properties', ->
      tests = [
        property: 'method'
        value: 'POST'
      ,
        property: 'uriTemplate'
        value: '/user/save'
      ,
        property: 'nameMethod'
        value: 'Create user'
      ,
        property: 'actionRelation'
        value: 'save'
      ,
        property: 'request'
        value:
          name: 'request'
          reference: 'reference'
        expected: blueprintApi.Request.fromJSON(
          name: 'request'
          reference: 'reference'
        )
      ,
        property: 'url'
        value: '/path/to/something'
      ]

      tests.forEach(({property, value, expected}) ->
        describe("With \"#{property}\" set to #{JSON.stringify(value)}", ->
          expected ?= value

          data = {}
          data[property] = value

          obj = blueprintApi.Resource.fromJSON(data)
          deserializedObj = blueprintApi.Resource.fromJSON(obj.toJSON())

          it('instance should equal to deserialized instance', ->
            assert.deepEqual(obj, deserializedObj)
          )
          it('JSON made from instance should equal to JSON made from deserialized instance', ->
            assert.deepEqual(obj.toJSON(), deserializedObj.toJSON())
          )
          it("value of \"#{property}\" is #{JSON.stringify(expected)}", ->
            assert.deepEqual(obj[property], expected)
          )
        )
      )
    )
  )
)
