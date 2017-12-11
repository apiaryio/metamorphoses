/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS203: Remove `|| {}` from converted for-own loops
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const {assert} = require('chai');
const sinon = require('sinon');

const blueprintApi = require('../src/blueprint-api');


describe('Serialization of the Blueprint interface (Application AST)', function() {
  describe('Blueprint object', function() {
    const blueprint = `\
HOST: http://localhost:8002/v1/

--- Testing ---

HEAD /resource
< 200
\
`;

    let obj = null;
    let deserializedObj = null;

    before(function() {
      const ast = {
        location: 'http://localhost:8002/v1/',
        name: 'Testing',
        sections: [
          {
            resources: [
              {
                method: 'HEAD',
                uriTemplate: '/resource',
                responses: [
                  {
                    status: 200
                  }
                ]
              }
            ]
          }
        ]
      };

      obj = blueprintApi.Blueprint.fromJSON(ast);
      return deserializedObj = blueprintApi.Blueprint.fromJSON(obj.toJSON());
    });

    it('Instance should equal to deserialized instance', () => assert.deepEqual(obj, deserializedObj));
    it('JSON made from instance should equal to JSON made from deserialized instance', () => assert.deepEqual(obj.toJSON(), deserializedObj.toJSON()));
    it('Blueprint made from instance should equal to Blueprint made from deserialized instance', () => assert.equal(obj.toBlueprint(), deserializedObj.toBlueprint()));
    return it('Blueprint made from instance should equal to original Blueprint', () => assert.equal(obj.toBlueprint(), blueprint));
  });


  return describe('Resource object', function() {
    describe('Empty instance', function() {
      const obj = new blueprintApi.Resource();
      const deserializedObj = blueprintApi.Resource.fromJSON(obj.toJSON());

      it('Instance should equal to deserialized instance', () => assert.deepEqual(obj, deserializedObj));
      it('JSON made from instance should equal to JSON made from deserialized instance', () => assert.deepEqual(obj.toJSON(), deserializedObj.toJSON()));

      return describe('Default properties', function() {
        const tests = [
          {property: 'method', expected: 'GET'},
          {property: 'uriTemplate', expected: ''},
          {property: 'nameMethod'},
          {property: 'actionRelation'},
          {property: 'request'},
          {property: 'url', expected: '/'},
          {property: 'name'},
          {property: 'actionName'},
          {property: 'actionDescription'},
          {property: 'actionHtmlDescription'},
          {property: 'description'},
          {property: 'htmlDescription'},
          {property: 'descriptionMethod'},
          {property: 'resourceDescription'},
          {property: 'model'},
          {property: 'headers'},
          {property: 'actionHeaders'},
          {property: 'parameters'},
          {property: 'resourceParameters'},
          {property: 'actionParameters'},
          {property: 'requests', expected: []},
          {property: 'responses', expected: []},
          {property: 'attributes'},
          {property: 'resolvedAttributes'},
          {property: 'actionAttributes'},
          {property: 'resolvedActionAttributes'},
          {property: 'actionUriTemplate'}
        ];

        tests.forEach(({property, expected}) =>
          it(`Property '${property}' is set to '${expected}'`, () => assert.deepEqual(obj[property], expected))
        );

        return it('Instance does not include any other properties', function() {
          let property;
          const properties = ((() => {
            const result = [];
            for (property of Object.keys((new blueprintApi.Resource()) || {})) {
              result.push(property);
            }
            return result;
          })());
          const untestedProperties = ((() => {
            const result1 = [];
            for ({property} of Array.from(tests)) {               if (!Array.from(properties).includes(property)) {
                result1.push(property);
              }
            }
            return result1;
          })());

          return assert.deepEqual(untestedProperties, []);
        });
      });
    });

    return describe('Individual properties', function() {
      const tests = [{
        property: 'method',
        value: 'POST'
      }
      , {
        property: 'uriTemplate',
        value: '/user/save'
      }
      , {
        property: 'nameMethod',
        value: 'Create user'
      }
      , {
        property: 'actionRelation',
        value: 'save'
      }
      , {
        property: 'request',
        value: {
          name: 'request',
          reference: 'reference'
        },
        expected: blueprintApi.Request.fromJSON({
          name: 'request',
          reference: 'reference'
        })
      }
      , {
        property: 'url',
        value: '/path/to/something'
      }
      ];

      return tests.forEach(({property, value, expected}) =>
        describe(`With \"${property}\" set to ${JSON.stringify(value)}`, function() {
          if (expected == null) { expected = value; }

          const data = {};
          data[property] = value;

          const obj = blueprintApi.Resource.fromJSON(data);
          const deserializedObj = blueprintApi.Resource.fromJSON(obj.toJSON());

          it('instance should equal to deserialized instance', () => assert.deepEqual(obj, deserializedObj));
          it('JSON made from instance should equal to JSON made from deserialized instance', () => assert.deepEqual(obj.toJSON(), deserializedObj.toJSON()));
          return it(`value of \"${property}\" is ${JSON.stringify(expected)}`, () => assert.deepEqual(obj[property], expected));
        })
      );
    });
  });
});
