/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const {assert} = require('chai');
const swaggerZoo = require('swagger-zoo');

const lodash = require('../src/adapters/refract/helper');
const refractAdapter = require('../src/adapters/refract-adapter');


const getApiDescription = parseResultElement =>
  lodash.chain(parseResultElement)
    .content()
    .find({element: 'category', meta: {classes: ['api']}})
    .value()
;

const convertToApplicationAst = function(parseResultElement) {
  const apiDescriptionElement = getApiDescription(parseResultElement);
  return refractAdapter.transformAst(apiDescriptionElement);
};

const getZooFeature = function(name, debug) {
  const fixture = lodash.chain(swaggerZoo.features()).find({name}).value();

  const { swagger } = fixture;
  const refract = fixture.apiElements;
  const ast = convertToApplicationAst(refract);

  if (debug) {
    console.log('SWAGGER:', swagger);
    console.log('\n----------------------------\n');
    console.log('REFRACT:', JSON.stringify(refract, null, 2));
    console.log('\n----------------------------\n');
    console.log('APPLICATION AST:', JSON.stringify(ast, null, 2));
  }

  return {ast, refract, swagger};
};


describe('Transformations • Refract', function() {
  describe('Title', () =>
    [{
        label: 'as primitive value',
        ast: convertToApplicationAst(
          require('./fixtures/refract-parse-result-title-as-primitive-value.json')
        )
      }
      , {
        label: 'as refract element',
        ast: convertToApplicationAst(
          require('./fixtures/refract-parse-result-title-as-refract-element.json')
        )
      }
    ].forEach(({label, ast}) =>
      context(label, () =>
        it('has name equal to `Title example`', () => assert.equal(ast.name, 'Title example'))
      )
    )
  );

  describe('Metadata', function() {
    let ast = null;

    before( () => ast = convertToApplicationAst(require('./fixtures/refract-parse-result-metadata.json')));

    it('has location', () => assert.equal(ast.location, 'https://example.com'));

    return it('has metadata without the HOST', function() {
      assert.equal(ast.metadata.length, 1);
      assert.equal(ast.metadata[0].name, 'FORMAT');
      return assert.equal(ast.metadata[0].value, '1A');
    });
  });

  describe('Resources', () =>
    [{
        label: 'Parse Result with Resource Group',
        ast: convertToApplicationAst(require('./fixtures/refract-parse-result-with-resource-group.json'))
      }
      , {
        label: 'Parse Result without Resource Group',
        ast: convertToApplicationAst(require('./fixtures/refract-parse-result-without-resource-group.json'))
      }
    ].forEach(({label, ast}) =>
      context(label, function() {
        it('has one resource group', () => assert.equal(ast.sections.length, 1));

        it('has two resources', () => assert.equal(ast.sections[0].resources.length, 2));

        it('Resource with GET method', function() {
          const resource = lodash
            .chain(ast.sections[0].resources)
            .find({method: 'GET'})
            .value();

          return assert.isOk(resource);
        });

        return it('Resource with POST method', function() {
          const resource = lodash
            .chain(ast.sections[0].resources)
            .find({method: 'POST'})
            .value();

          return assert.isOk(resource);
        });
      })
    )
  );

  describe('hrefVariables', function() {
    let ast = null;
    let resource = null;
    before( function() {
      ast = convertToApplicationAst(require('./fixtures/refract-parse-result-href-variables.json'));
      return resource = ast.sections[0].resources[0];
    });

    it('resource has one resource parameter', () => assert.equal(resource.resourceParameters.length, 1));

    it('resource has one action parameter', () => assert.equal(resource.actionParameters.length, 1));

    return it('resource has 1 parameters from action parameters', () => assert.equal(resource.parameters.length, 1));
  });

  describe('With no response', function() {
    let ast = null;
    let resource = null;

    before( function() {
      ast = convertToApplicationAst(require('./fixtures/refract-parse-result-no-response.json'));
      return resource = ast.sections[0].resources[0];
    });

    return it('resource has no responses', () => assert.equal(resource.responses.length, 0));
  });

  context('Features', function() {
    describe('Minimal JSON', function() {
      let ast = null;
      before( () => ({ast} = getZooFeature('minimal-json')));

      it('has a name', () => assert.isOk(ast.name));

      return it('doesn\'t have any sections', () => assert.equal(ast.sections.length, 0));
    });

    describe('Action', function() {
      let ast = null;
      before( () => ({ast} = getZooFeature('action')));

      it('has one artificial section', function() {
        assert.equal(ast.sections.length, 1);
        return assert.equal(ast.sections[0].name, '');
      });

      it('has 7 resources', () => assert.equal(ast.sections[0].resources.length, 7));

      return describe('GET method properties', function() {
        let resource = null;
        before( () =>
          resource = lodash
            .chain(ast.sections[0].resources)
            .find({method: 'GET'})
            .value()
        );

        it('has actionName', () => assert.isOk(resource.actionName));

        return it('has actionDescription', () => assert.isOk(resource.actionDescription));
      });
    });

    describe('Description', function() {
      let ast = null;
      before( () => ({ast} = getZooFeature('description')));

      it('has name', () => assert.isOk(ast.name));

      return it('has description', () => assert.isOk(ast.description));
    });

    describe('Example Header', function() {
      let ast = null;
      before( () => ({ast} = getZooFeature('example-header')));

      return it('Response has correct headers', function() {
        const expected = {
          'Content-Type': 'application/json',
          'Accepts': '',
          'X-Test1': 100,
          'X-Test2': 'abc'
        };
        return assert.deepEqual(ast.sections[0].resources[0].responses[0].headers, expected);
      });
    });

    describe('Body and Schema', function() {
      let ast = null;
      before( () => ({ast} = getZooFeature('body-schema-example')));

      it('resource has response body', function() {
        const expected = '{\n  "id": 123,\n  "name": "Resource 1"\n}';
        return assert.equal(ast.sections[0].resources[0].responses[0].body, expected);
      });

      return it('resource has response schema', function() {
        const expected = '{}';
        return assert.equal(ast.sections[0].resources[0].responses[0].schema, expected);
      });
    });

    describe('Params', function() {
      let ast = null;
      before( () => ({ast} = getZooFeature('params')));

      context('GET', function() {
        let resource = null;
        before( () => resource = ast.sections[0].resources[0]);

        it('method is GET', () => assert.equal(resource.method, 'GET'));

        it('url equals to `/test/{id}{?arg}`', () => assert.equal(resource.uriTemplate, '/test/{id}{?arg}'));

        it('uriTemplate equals to `/test/{id}{?arg}`', () => assert.equal(resource.uriTemplate, '/test/{id}{?arg}'));

        it('resourceUriTemplate equals to `/test/{id}`', () => assert.equal(resource.resourceUriTemplate, '/test/{id}'));

        it('actionUriTemplate equals to `/test/{id}{?arg}`', () => assert.equal(resource.actionUriTemplate, '/test/{id}{?arg}'));

        it('has two parameters', () => assert.equal(resource.parameters.length, 2));

        it('has two actionParameters', () => assert.equal(resource.actionParameters.length, 2));

        it('first parameter is `id`', () => assert.equal(resource.parameters[0].key, 'id'));

        it('first parameter is required', () => assert.isTrue(resource.parameters[0].required));

        it('first parameter has `type` equal to `string`', () => assert.equal(resource.parameters[0].type, 'string'));

        it('second parameter is `arg`', () => assert.equal(resource.parameters[1].key, 'arg'));

        return it('second parameter is required', () => assert.isTrue(resource.parameters[1].required));
      });

      return context('POST', function() {
        let resource = null;
        before( () => resource = ast.sections[0].resources[1]);

        it('method is POST', () => assert.equal(resource.method, 'POST'));

        it('url equals to `/test`', () => assert.equal(resource.uriTemplate, '/test'));

        it('uriTemplate equals to `/test`', () => assert.equal(resource.uriTemplate, '/test'));

        it('resourceUriTemplate equals to `/test`', () => assert.equal(resource.resourceUriTemplate, '/test'));

        it('actionUriTemplate is empty', () => assert.equal(resource.actionUriTemplate, ''));

        return it('has schema', () => assert.equal(resource.request.schema, '{\"type\":\"string\"}'));
      });
    });

    describe('Path level parameters', function() {
      let ast = null;
      let resource = null;
      before( function() {
        ({ast} = getZooFeature('path-level-params'));
        return resource = ast.sections[0].resources[0];
      });

      it('URI template contains all parameters', () => assert.equal(resource.uriTemplate, '/test/{id}{?search,arg}'));

      it('2 paramters are resource paramters', () => assert.equal(resource.resourceParameters.length, 2));

      it('1 paramter is action paramter', () => assert.equal(resource.actionParameters.length, 1));

      return it('resource have one paramters from action parameter', () => assert.equal(resource.parameters.length, 1));
    });

    describe('Tags', function() {
      let ast = null;
      before( () => ({ast} = getZooFeature('tags')));

      it('has two sections', () => assert.equal(ast.sections.length, 2));

      it('first section has name `Group1`', () => assert.equal(ast.sections[0].name, 'Group1'));

      it('`Group1` contains 3 resources', () => assert.equal(ast.sections[0].resources.length, 3));

      it('second section has name `Group2`', () => assert.equal(ast.sections[1].name, 'Group2'));

      return it('`Group2` contains 2 resources', () => assert.equal(ast.sections[1].resources.length, 2));
    });

    describe('Mixed Resources and Resource Groups', function() {
      let applicationAst = null;

      before(() =>
        applicationAst = convertToApplicationAst(
          require('./fixtures/refract-parse-result-tags.json')
        )
      );

      it('Has the correct sections', () => assert.strictEqual(applicationAst.sections.length, 2));

      it('First section has the correct resources', () => assert.strictEqual(applicationAst.sections[0].resources.length, 6));

      return it('Second section has the correct resources', () => assert.strictEqual(applicationAst.sections[1].resources.length, 1));
    });

    describe('Resource without Action', function() {
      let applicationAst = null;

      before(() =>
        applicationAst = convertToApplicationAst(
          require('./fixtures/refract-parse-result-no-action.json')
        )
      );

      it('Has one section', () => assert.strictEqual(applicationAst.sections.length, 1));

      return it('Has no resources', () => assert.strictEqual(applicationAst.sections[0].resources.length, 0));
    });

    describe('Support for x-summary and x-description', function() {
      let applicationAst = null;

      before(() =>
        applicationAst = convertToApplicationAst(
          // TODO: Use Swagger Zoo when it is brought up to be in sync
          // This file is copy/paste in fury-adapter-swagger currently
          // File: test/fixtures/refract/x-summary-and-description.json
          require('./fixtures/refract-parse-result-x-values.json')
        )
      );

      it('Resource name is correct', () => assert.strictEqual(applicationAst.sections[0].resources[0].name, 'Resource Title'));

      return it('Resource description is correct', () => assert.strictEqual(applicationAst.sections[0].resources[0].description, 'Resource Description'));
    });

    describe('HTTP Payload Data Structures', function() {
      let applicationAst = null;

      before(() =>
        applicationAst = convertToApplicationAst(
          require('./fixtures/refract-parse-result-payload-data-structures.json')
        )
      );

      it('Data Structure is present for HTTP Requests', function() {
        const dataStructureElement = applicationAst.sections[0].resources[0].requests[0].attributes.element;
        return assert.strictEqual(dataStructureElement, 'dataStructure');
      });

      return it('Data Structure is present for HTTP Responses', function() {
        const dataStructureElement = applicationAst.sections[0].resources[0].responses[0].attributes.element;
        return assert.strictEqual(dataStructureElement, 'dataStructure');
      });
    });

    describe('Redundant requests', function() {
      let applicationAst = null;

      before(() =>
        applicationAst = convertToApplicationAst(
          require('./fixtures/refract-parse-result-redundant-requests.json')
        )
      );

      it('Has a request', () => assert.isObject(applicationAst.sections[0].resources[0].request));

      return it('Has the correct HTTP request', () => assert.strictEqual(applicationAst.sections[0].resources[0].requests.length, 1));
    });

    describe('No request', function() {
      let applicationAst = null;

      before(() =>
        applicationAst = convertToApplicationAst(
          require('./fixtures/refract-parse-result-no-request.json')
        )
      );

      it('Has a request', () => assert.isObject(applicationAst.sections[0].resources[0].request));

      return it('Has empty name, description and htmlDescription', function() {
        assert.strictEqual(applicationAst.sections[0].resources[0].request.name, '');
        assert.strictEqual(applicationAst.sections[0].resources[0].request.description, '');
        return assert.strictEqual(applicationAst.sections[0].resources[0].request.htmlDescription, '');
      });
    });

    describe('Empty request', function() {
      let applicationAst = null;

      before(() =>
        applicationAst = convertToApplicationAst(
          require('./fixtures/refract-parse-result-empty-request.json')
        )
      );

      it('Has a request', function() {
        assert.isObject(applicationAst.sections[0].resources[0].request);
        return assert.strictEqual(applicationAst.sections[0].resources[0].request.name, '');
      });

      return it('Has the correct HTTP requests', function() {
        assert.strictEqual(applicationAst.sections[0].resources[0].requests.length, 2);
        assert.strictEqual(applicationAst.sections[0].resources[0].requests[0].name, '');
        return assert.strictEqual(applicationAst.sections[0].resources[0].requests[1].name, 'Only one user');
      });
    });

    describe('Request and Response exampleId', function() {
      let applicationAst = null;

      before(() =>
        applicationAst = convertToApplicationAst(
          require('./fixtures/refract-parse-result-empty-request.json')
        )
      );

      it('has a single request with correct exampleId', function() {
        assert.strictEqual(applicationAst.sections[0].resources[0].requests.length, 2);
        assert.strictEqual(applicationAst.sections[0].resources[0].requests[0].exampleId, 0);
        return assert.strictEqual(applicationAst.sections[0].resources[0].requests[1].exampleId, 0);
      });

      return it('has two responses with correct exampleId', function() {
        assert.strictEqual(applicationAst.sections[0].resources[0].responses.length, 1);
        return assert.strictEqual(applicationAst.sections[0].resources[0].responses[0].exampleId, 0);
      });
    });

    describe('‘x-summary’ and ‘x-description’', function() {
      let applicationAst = null;

      before( () => applicationAst = getZooFeature('x-summary-and-description').ast);

      it('Has the correct number of resources', () => assert.strictEqual(applicationAst.sections[0].resources.length, 1));

      it('Resource has the correct URL and URI Template', function() {
        assert.strictEqual(
          applicationAst.sections[0].resources[0].url,
          '/test'
        );
        return assert.strictEqual(
          applicationAst.sections[0].resources[0].uriTemplate,
          '/test'
        );
      });

      it('Resource has the correct description', () =>
        assert.strictEqual(
          applicationAst.sections[0].resources[0].description,
          'Resource Description'
        )
      );

      return it('Resource has the correct name', () =>
        assert.strictEqual(
          applicationAst.sections[0].resources[0].name,
          'Resource Title'
        )
      );
    });

    describe('Authentication', function() {
      let applicationAst = null;

      before(() =>
        applicationAst = convertToApplicationAst(
          require('./fixtures/refract-parse-result-with-auth.json')
        )
      );

      it('Has the correct number of sections', () => assert.strictEqual(applicationAst.sections.length, 1));

      it('Has the correct number of resources', () => assert.strictEqual(applicationAst.sections[0].resources.length, 1));

      it('Has authentication definitions', function() {
        assert.strictEqual(applicationAst.authDefinitions[0].element, 'Basic Authentication Scheme');
        return assert.strictEqual(applicationAst.authDefinitions[0].content.length, 2);
      });

      return it('Has authentication information for resource actions', function() {
        const request = applicationAst.sections[0].resources[0].requests[0];
        assert.strictEqual(request.authSchemes.length, 1);
        return assert.strictEqual(request.authSchemes[0].element, 'Custom Basic Auth');
      });
    });

    return describe('Bad input', () =>
      it('Should not crash', () => refractAdapter.transformAst())
    );
  });

  describe('Host metadata', function() {
    describe('without a trailing slash', function() {
      let ast = null;
      let resource = null;

      before( function() {
        ast = convertToApplicationAst(require('./fixtures/refract-parse-result-host.json'));
        return resource = ast.sections[0].resources[0];
      });

      return it('has a url including the host prefix', () => assert.equal(resource.url, '/prefix/example'));
    });

    describe('with a trailing slash', function() {
      let ast = null;
      let resource = null;

      before( function() {
        ast = convertToApplicationAst(require('./fixtures/refract-parse-result-host-trailing.json'));
        return resource = ast.sections[0].resources[0];
      });

      return it('has a url including the host prefix', () => assert.equal(resource.url, '/prefix/example'));
    });

    return describe('with bad value', function() {
      let ast = null;
      let resource = null;

      before( function() {
        ast = convertToApplicationAst(require('./fixtures/refract-parse-result-host-bad.json'));
        return resource = ast.sections[0].resources[0];
      });

      return it('has a url including the host prefix', () => assert.equal(resource.url, '/prefix/example'));
    });
  });

  return describe('Transforming an Error', function() {
    it('can transform an error from a parse result', function() {
      const parseResult = {
        element: 'parseResult',
        content: [
          {
            element: 'annotation',
            meta: {
              classes: ['error'],
            },
            attributes: {
              sourceMap: [
                {
                  element: 'sourceMap',
                  content: [
                    [9, 5],
                    [16, 2],
                  ]
                }
              ],
              code: 10,
            },
            content: 'Malformed syntax'
          }
        ]
      };

      const err = refractAdapter.transformError('source\n\n\nerror line\n\nerr', parseResult);
      assert.isDefined(err);
      assert.equal(err.message, 'Malformed syntax');
      assert.equal(err.code, 10);
      assert.equal(err.line, 4);
      assert.equal(err.location.length, 2);
      assert.equal(err.location[0].index, 9);
      assert.equal(err.location[0].length, 5);
      assert.equal(err.location[1].index, 16);
      return assert.equal(err.location[1].length, 2);
    });

    it('can transform an error from a parse result with missing source maps', function() {
      const parseResult = {
        element: 'parseResult',
        content: [
          {
            element: 'annotation',
            meta: {
              classes: ['error'],
            },
            attributes: {
              code: 10,
            },
            content: 'Malformed syntax'
          }
        ]
      };

      const err = refractAdapter.transformError('source\n\n\nerror line\n\nerr', parseResult);
      assert.isDefined(err);
      assert.equal(err.message, 'Malformed syntax');
      assert.equal(err.code, 10);
      assert.equal(err.line, 1);
      assert.equal(err.location.length, 1);
      assert.equal(err.location[0].index, 0);
      return assert.equal(err.location[0].length, 24);
    });

    return it('does not return an error when there is no error in parse result', function() {
      const parseResult = {
        element: 'parseResult',
        content: [
          {
            element: 'annotation',
            meta: {
              classes: ['warning'],
            },
            attributes: {
              sourceMap: [
                {
                  element: 'sourceMap',
                  content: [[18, 1]],
                }
              ]
            },
            content: 'Something is wrong'
          }
        ]
      };

      const err = refractAdapter.transformError('source', parseResult);
      return assert.isUndefined(err);
    });
  });
});
