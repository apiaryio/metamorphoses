/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const {assert} = require('chai');
const protagonist = require('protagonist');

const CURRENT_APPLICATION_AST_VERSION = require('../src/blueprint-api').Version;
const refractAdapter = require('../src/adapters/refract-adapter');
const apiNamespaceHelper = require('../src/adapters/refract/helper');

const parseApiBlueprint = function(source, cb) {
  const transform = function(err, result) {
    let ast = apiNamespaceHelper(result)
            .content()
            .find({element: 'category', meta: {classes: ['api']}});

    const warnings = result.content.filter(element => element.element === 'annotation').map(annotation =>
      ({
        message: annotation.content,
        code: annotation.attributes.code,
        location: [
          {
            index: annotation.attributes.sourceMap[0].content[0][0],
            length: annotation.attributes.sourceMap[0].content[0][1]
          }
        ]
      })
    );

    err = refractAdapter.transformError(source, result);
    ast = refractAdapter.transformAst(ast, null);

    return cb(err, ast, warnings);
  };

  const options =
    {requireBlueprintName: true};

  return protagonist.parse(source, options, transform);
};


describe('Transformations', () =>
  describe('API Blueprint', function() {
    [
      'refract'
    ].forEach(type =>
      context(`Parsed by protagonist as \`${type}\``, function() {
        describe('When I send in simple blueprint', function() {
          let ast = undefined;
          before(function(done) {
            const code = `VERSION: 2
# API name\
`;

            return parseApiBlueprint(code, function(err, newAst) {
              ast = newAst;
              return done(err);
            });
          });

          return it('I got API name', () => assert.equal(ast.name, 'API name'));
        });

        describe('When I send in more complex blueprint', function() {
          let ast = undefined;
          before(function(done) {
            const code = `VERSION: 2
# API name
Lorem ipsum 1

# Group Name
Lorem ipsum 2

## /resource
Lorem ipsum 3

### GET
Lorem ipsum 4

+ Response 200 (text/plain)
  + Headers

           Set-Cookie: Yo!
           Set-Cookie: Yo again!
           Set-Cookie: Yo moar!

  + Body

            Hello World\
`;

            return parseApiBlueprint(code, function(err, newAst) {
              ast = newAst;
              return done(err);
            });
          });

          it('I got API name', () => assert.equal(ast.name, 'API name'));
          it('I got API description', () => assert.equal(ast.description, 'Lorem ipsum 1'));
          it('I got API HTML description', () => assert.equal(ast.htmlDescription, '<p>Lorem ipsum 1</p>'));
          it('I got one resource group', () => assert.equal(ast.sections.length, 1));
          it('group has correct name', () => assert.equal(ast.sections[0].name, 'Name'));
          it('group has correct description', () => assert.equal(ast.sections[0].description, 'Lorem ipsum 2'));
          it('group has HTML description', () => assert.equal(ast.sections[0].htmlDescription, '<p>Lorem ipsum 2</p>'));
          it('group has one resource', () => assert.equal(ast.sections[0].resources.length, 1));
          it('resource has correct URI', () => assert.equal(ast.sections[0].resources[0].url, '/resource'));
          it('resource has correct description', () => assert.equal(ast.sections[0].resources[0].description, 'Lorem ipsum 3'));
          it('resource has HTML description', () => assert.equal(ast.sections[0].resources[0].htmlDescription, '<p>Lorem ipsum 3</p>'));
          it('resource has action description', () => assert.equal(ast.sections[0].resources[0].actionDescription, 'Lorem ipsum 4'));
          it('resource has action HTML description', () => assert.equal(ast.sections[0].resources[0].actionHtmlDescription, '<p>Lorem ipsum 4</p>'));
          it('resource has correct method', () => assert.equal(ast.sections[0].resources[0].method, 'GET'));
          it('resource has one response', () => assert.equal(ast.sections[0].resources[0].responses.length, 1));
          it('response has correct status', () => assert.equal(ast.sections[0].resources[0].responses[0].status, '200'));
          it('response has correct body', function() {
            // temporary hack before new protagonist with fix for from classes array in messageBody will be relased
            if (type !== 'refract') {
              return assert.equal(ast.sections[0].resources[0].responses[0].body, 'Hello World');
            }
          });
          it('response has headers1A property', () => assert.isDefined(ast.sections[0].resources[0].responses[0].headers1A));
          it('response has headers1A with three Set-Cookie headers', function() {
            const expectedValues = ['Yo!', 'Yo again!', 'Yo moar!'];
            const setCookieHeaders = ast.sections[0].resources[0].responses[0].headers1A.filter(item => item.name === 'Set-Cookie');

            assert.equal(setCookieHeaders.length, 3);

            return setCookieHeaders.forEach((item, index) => assert.equal(item.value, expectedValues[index]));
          });
          if (type.match(/source-map/)) {
            it('resource group has a valid source map', function() {
              assert.equal(ast.sections[0].sourcemap.length, 1);
              return assert.equal(ast.sections[0].sourcemap[0].length, 2);
            });
            it('resource has a valid source map', function() {
              assert.equal(ast.sections[0].resources[0].sourcemap.length, 1);
              return assert.equal(ast.sections[0].resources[0].sourcemap[0].length, 2);
            });
            return it('action has a valid source map', function() {
              assert.equal(ast.sections[0].resources[0].actionSourcemap.length, 1);
              return assert.equal(ast.sections[0].resources[0].actionSourcemap[0].length, 2);
            });
          } else {
            it('resource group has no source map', () => assert.equal(ast.sections[0].sourcemap, undefined));
            it('resource has no source map', () => assert.equal(ast.sections[0].resources[0].sourcemap, undefined));
            return it('action has no source map', () => assert.equal(ast.sections[0].resources[0].actionSourcemap, undefined));
          }
        });

        return describe('When I send a blueprint with attributes', function() {
          let ast = undefined;
          before(function(done) {
            const code = `VERSION: 2
# API Name
## Resource [/foo]
### Get a foo [GET]
+ Response 200
    + Attributes
        + status: ok\
`;
            return parseApiBlueprint(code, function(err, newAst) {
              ast = newAst;
              return done(err);
            });
          });

          return it('Contains a resource with an attributes object', () =>
            assert.deepEqual(ast.sections[0].resources[0].responses[0].attributes, {
              element: 'dataStructure',
              content: [{
                element: 'object',
                content: [{
                  element: 'member',
                  content: {
                    key: {
                      element: 'string',
                      content: 'status'
                    },
                    value: {
                      element: 'string',
                      content: 'ok'
                    }
                  }
                }
                ]
              }
              ]
            }
            )
          );
        });
      })
    );

    return describe('Legacy Apiary Blueprint with HOST suffix', function() {
      let resource = undefined;
      let resourceJSON = undefined;

      before(function(done) {
        const code = `\
HOST: http://localhost:8002/v1/

# Testing

## /resource
Lorem ipsum 3

### GET
Lorem ipsum 4

+ Response 200 (text/plain)
    + Body
        Hello World\
`;

        return parseApiBlueprint(code, function(err, ast) {
          resource = ast.sections[0].resources[0];
          resourceJSON = ast.toJSON().sections[0].resources[0];
          return done(err);
        });
      });

      describe('In the Application AST interface', function() {
        it('Resource has URL prefixed with path from HOST URL', () => assert.equal(resource.url, '/v1/resource'));
        it('Resource has URI Template without prefix', () => assert.equal(resource.uriTemplate, '/resource'));
        return it('Resource has Resource URI Template without prefix', () => assert.equal(resource.resourceUriTemplate, '/resource'));
      });

      return describe('In the JSON serialization', function() {
        it('Resource has URL prefixed with path from HOST URL', () => assert.equal(resourceJSON.url, '/v1/resource'));
        it('Resource has URI Template without prefix', () => assert.equal(resourceJSON.uriTemplate, '/resource'));
        return it('Resource has Resource URI Template without prefix', () => assert.equal(resourceJSON.resourceUriTemplate, '/resource'));
      });
    });
  })
);

describe('Test errors and warnings', function() {

  describe('When I send in simple blueprint with one resource and error', function() {
    let errors = null;
    before(function(done) {
      const code = `FORMAT: 1A
# Name\t

## GET /resource
\
`;

      return parseApiBlueprint(code, function(err, newAst, warnings) {
        if (err) {
          errors = err;
        }
        return done();
      });
    });

    it('I have error code', () => assert.equal(2, errors.code));
    it('I have error line', () => assert.equal(2, errors.line));
    it('I have error message', () => assert.equal("the use of tab(s) \'\\t\' in source data isn\'t currently supported, please contact makers", errors.message));
    it('I have error location index', () => assert.equal(17, errors.location[0].index));
    return it('I have error location length', () => assert.equal(1, errors.location[0].length));
  });

  return describe('When I send in simple blueprint with one resource and warnings', function() {
    let warn = null;
    before(function(done) {
      const code = `FORMAT: 1A
# Name

## GET /resource

## GET /resource
\
`;

      return parseApiBlueprint(code, function(err, newAst, warnings) {
        if (warnings) { warn = warnings; }
        const ast = newAst;
        return done(err);
      });
    });

    it('I have warning message', () => assert.equal("action is missing a response", warn[0].message));
    it('I have warning code', () => assert.equal(6, warn[0].code));
    it('I have warning location index', () => assert.equal(19, warn[0].location[0].index));
    return it('I have warning location length', () => assert.equal(18, warn[0].location[0].length));
  });
});
