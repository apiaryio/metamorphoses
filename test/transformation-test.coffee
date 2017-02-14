{assert} = require('chai')
protagonist = require('protagonist')

CURRENT_APPLICATION_AST_VERSION = require('../src/blueprint-api').Version
apiBlueprintAdapter = require('../src/adapters/api-blueprint-adapter')
refractAdapter = require('../src/adapters/refract-adapter')
apiNamespaceHelper = require('../src/adapters/refract/helper')




# Supported types:
#
# - 'refract'
#   Uses Protagonist and returns everything as Refract.
#
# - 'ast' (default)
#   Uses Protagonist and returns API Blueprint AST, which includes MSON
#   returned as Refract.
#
# - 'ast-source-map'
#   Uses Protagonist and returns API Blueprint AST, which includes MSON
#   returned as Refract and also includes source maps.
parseApiBlueprint = (source, type, cb) ->
  [cb, type] = [type, 'ast'] if typeof type is 'function'

  transform = (err, result) ->
    adapter = if type is 'refract' then refractAdapter else apiBlueprintAdapter

    ast = result?.ast
    if type is 'refract'
      ast = apiNamespaceHelper(result)
                .content()
                .find({element: 'category', meta: {classes: ['api']}})

    sourcemap = result?.sourcemap

    if err
      # Protagonist does not include error in parse result, only in err
      result.error = err

    err = adapter.transformError(source, result)
    ast = adapter.transformAst(ast, sourcemap)
    cb(err, ast, result?.warnings or [])

  options =
    requireBlueprintName: true
    type: if type.match(/refract/) then 'refract' else 'ast'

  if type.match(/source-map/)
    options.exportSourcemap = true

  protagonist.parse(source, options, transform)


describe('Transformations', ->
  describe('API Blueprint', ->
    [
      'ast',
      'ast-source-map',
      'refract'
    ].forEach((type) ->
      context("Parsed by protagonist as `#{type}`", ->
        describe('When I send in simple blueprint', ->
          ast = undefined
          before((done) ->
            code = '''VERSION: 2
                   # API name
                   '''

            parseApiBlueprint(code, type, (err, newAst) ->
              ast = newAst
              done(err)
            )
          )

          it('I got API name', ->
            assert.equal(ast.name, 'API name')
          )
        )

        describe('When I send in more complex blueprint', ->
          ast = undefined
          before((done) ->
            code = '''VERSION: 2
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

                               Hello World
                   '''

            parseApiBlueprint(code, type, (err, newAst) ->
              ast = newAst
              done(err)
            )
          )

          it('I got API name', ->
            assert.equal(ast.name, 'API name')
          )
          it('I got API description', ->
            assert.equal(ast.description, 'Lorem ipsum 1')
          )
          it('I got API HTML description', ->
            assert.equal(ast.htmlDescription, '<p>Lorem ipsum 1</p>')
          )
          it('I got one resource group', ->
            assert.equal(ast.sections.length, 1)
          )
          it('group has correct name', ->
            assert.equal(ast.sections[0].name, 'Name')
          )
          it('group has correct description', ->
            assert.equal(ast.sections[0].description, 'Lorem ipsum 2')
          )
          it('group has HTML description', ->
            assert.equal(ast.sections[0].htmlDescription, '<p>Lorem ipsum 2</p>')
          )
          it('group has one resource', ->
            assert.equal(ast.sections[0].resources.length, 1)
          )
          it('resource has correct URI', ->
            assert.equal(ast.sections[0].resources[0].url, '/resource')
          )
          it('resource has correct description', ->
            assert.equal(ast.sections[0].resources[0].description, 'Lorem ipsum 3')
          )
          it('resource has HTML description', ->
            assert.equal(ast.sections[0].resources[0].htmlDescription, '<p>Lorem ipsum 3</p>')
          )
          it('resource has action description', ->
            assert.equal(ast.sections[0].resources[0].actionDescription, 'Lorem ipsum 4')
          )
          it('resource has action HTML description', ->
            assert.equal(ast.sections[0].resources[0].actionHtmlDescription, '<p>Lorem ipsum 4</p>')
          )
          it('resource has correct method', ->
            assert.equal(ast.sections[0].resources[0].method, 'GET')
          )
          it('resource has one response', ->
            assert.equal(ast.sections[0].resources[0].responses.length, 1)
          )
          it('response has correct status', ->
            assert.equal(ast.sections[0].resources[0].responses[0].status, '200')
          )
          it('response has correct body', ->
            # temporary hack before new protagonist with fix for from classes array in messageBody will be relased
            if type isnt 'refract'
              assert.equal(ast.sections[0].resources[0].responses[0].body, 'Hello World')
          )
          it('response has correctly merged headers', ->
            assert.equal(ast.sections[0].resources[0].responses[0].headers['Set-Cookie'], 'Yo!, Yo again!, Yo moar!')
          )
          if type.match(/source-map/)
            it('resource group has a valid source map', ->
              assert.equal(ast.sections[0].sourcemap.length, 1)
              assert.equal(ast.sections[0].sourcemap[0].length, 2)
            )
            it('resource has a valid source map', ->
              assert.equal(ast.sections[0].resources[0].sourcemap.length, 1)
              assert.equal(ast.sections[0].resources[0].sourcemap[0].length, 2)
            )
            it('action has a valid source map', ->
              assert.equal(ast.sections[0].resources[0].actionSourcemap.length, 1)
              assert.equal(ast.sections[0].resources[0].actionSourcemap[0].length, 2)
            )
          else
            it('resource group has no source map', ->
              assert.equal(ast.sections[0].sourcemap, undefined)
            )
            it('resource has no source map', ->
              assert.equal(ast.sections[0].resources[0].sourcemap, undefined)
            )
            it('action has no source map', ->
              assert.equal(ast.sections[0].resources[0].actionSourcemap, undefined)
            )
        )

        describe('When I send a blueprint with attributes', ->
          ast = undefined
          before((done) ->
            code = '''VERSION: 2
                  # API Name
                  ## Resource [/foo]
                  ### Get a foo [GET]
                  + Response 200
                      + Attributes
                          + status: ok
                  '''
            parseApiBlueprint(code, type, (err, newAst) ->
              ast = newAst
              done(err)
            )
          )

          it('Contains a resource with an attributes object', ->
            assert.deepEqual(ast.sections[0].resources[0].responses[0].attributes,
              element: 'dataStructure'
              content: [
                element: 'object'
                content: [
                  element: 'member'
                  content:
                    key:
                      element: 'string'
                      content: 'status'
                    value:
                      element: 'string'
                      content: 'ok'
                ]
              ]
            )
          )
        )
      )
    )

    describe('Legacy Apiary Blueprint with HOST suffix', ->
      resource = undefined
      resourceJSON = undefined

      before((done) ->
        code = '''
          HOST: http://localhost:8002/v1/

          # Testing

          ## /resource
          Lorem ipsum 3

          ### GET
          Lorem ipsum 4

          + Response 200 (text/plain)
              + Body
                  Hello World
        '''

        parseApiBlueprint(code, (err, ast) ->
          resource = ast.sections[0].resources[0]
          resourceJSON = ast.toJSON().sections[0].resources[0]
          done(err)
        )
      )

      describe('In the Application AST interface', ->
        it('Resource has URL prefixed with path from HOST URL', ->
          assert.equal(resource.url, '/v1/resource')
        )
        it('Resource has URI Template without prefix', ->
          assert.equal(resource.uriTemplate, '/resource')
        )
        it('Resource has Resource URI Template without prefix', ->
          assert.equal(resource.resourceUriTemplate, '/resource')
        )
      )

      describe('In the JSON serialization', ->
        it('Resource has URL prefixed with path from HOST URL', ->
          assert.equal(resourceJSON.url, '/v1/resource')
        )
        it('Resource has URI Template without prefix', ->
          assert.equal(resourceJSON.uriTemplate, '/resource')
        )
        it('Resource has Resource URI Template without prefix', ->
          assert.equal(resourceJSON.resourceUriTemplate, '/resource')
        )
      )
    )

    describe('Upgrade of Protagonist from 0.8 to 0.11', ->
      astCaches =
        '0.8':
          _version: '2.0'
          metadata:
            FORMAT: {value: '1A'}
            HOST: {value: 'http://www.example.com'}
          name: ''
          description: ''
          resourceGroups: [
            name: ''
            description: ''
            resources: [
              name: 'Note'
              description: ''
              uriTemplate: '/notes/{id}'
              model: {}
              headers: {}
              parameters:
                id:
                  description: 'Numeric `id` of the Note to perform action with. Has example value.\n'
                  type: 'number'
                  required: true
                  default: ''
                  example: ''
                  values: ['A', 'B', 'C']
              actions: [
                name: 'Retrieve a Note'
                description: ''
                method: 'GET'
                parameters: []
                headers: {}
                examples: [
                  name: ''
                  description: ''
                  requests: []
                  responses: [
                    name: '200'
                    description: ''
                    headers:
                      'Content-Type': {value: 'application/json'}
                      'X-My-Header': {value: 'The Value'}
                      'Set-Cookie': {value: 'efgh'}
                    body: '{ "id": 2, "title": "Pick-up posters from post-office" }\n'
                    schema: ''
                  ]
                ]
              ]
            ]
          ]

        '0.11':
          _version: '2.0'
          metadata: [
            {name: 'FORMAT', value: '1A'}
            {name: 'HOST', value: 'http://www.example.com'}
          ]
          name: ''
          description: ''
          resourceGroups: [
            name: ''
            description: ''
            resources: [
              name: 'Note'
              description: ''
              uriTemplate: '/notes/{id}'
              model: {}
              parameters: [
                name: 'id'
                description: 'Numeric `id` of the Note to perform action with. Has example value.\n'
                type: 'number'
                required: true
                default: ''
                example: ''
                values: [
                  {value: 'A'}
                  {value: 'B'}
                  {value: 'C'}
                ]
              ]
              actions: [
                name: 'Retrieve a Note'
                description: ''
                method: 'GET'
                parameters: []
                examples: [
                  name: ''
                  description: ''
                  requests: []
                  responses: [
                    name: '200'
                    description: ''
                    headers: [
                      {name: 'Content-Type', value: 'application/json'}
                      {name: 'X-My-Header', value: 'The Value'}
                      {name: 'Set-Cookie', value: 'abcd'}
                      {name: 'Set-Cookie', value: 'efgh'}
                    ]
                    body: '{ "id": 2, "title": "Pick-up posters from post-office" }\n'
                    schema: ''
                  ]
                ]
              ]
            ]
          ]

      for version, astCache of astCaches
        describe("When I transform an AST produced by Protagonist v#{version}", ->
          ast = undefined
          before( ->
            ast = apiBlueprintAdapter.transformAst(astCache)
          )

          it('I got metadata right, with location is aside', ->
            assert.equal(ast.location, 'http://www.example.com')
            assert.equal(ast.metadata.length, 1)
            assert.equal(ast.metadata[0].name, 'FORMAT')
            assert.equal(ast.metadata[0].value, '1A')
          )

          it('I got headers right', ->
            headers = ast.sections[0].resources[0].responses[0].headers
            assert.equal(headers['Content-Type'], 'application/json')
            assert.equal(headers['X-My-Header'], 'The Value')
            assert.equal(headers['Set-Cookie'], 'abcd, efgh')
          )

          it('I got parameters right', ->
            param = ast.sections[0].resources[0].parameters[0]
            assert.equal(param.key, 'id')
          )

          it('I got parameter values right', ->
            values = ast.sections[0].resources[0].parameters[0].values
            assert.equal(values[0], 'A')
            assert.equal(values[1], 'B')
            assert.equal(values[2], 'C')
          )
        )
    )
  )

  describe('Coercing to object of objects from', ->
    describe('null', ->
      data = undefined
      before( ->
        data = apiBlueprintAdapter.ensureObjectOfObjects(null)
      )
      it('results in {}', ->
        assert.deepEqual(data, {})
      )
    )

    describe('object', ->
      data = undefined
      before( ->
        data = apiBlueprintAdapter.ensureObjectOfObjects(
          'Accept-Language': {'value': 'cs'}
          'Accept': {'value': 'beverage/beer'}
        )
      )
      it('results in the same object', ->
        assert.deepEqual(data,
          'Accept-Language': {'value': 'cs'}
          'Accept': {'value': 'beverage/beer'}
        )
      )
    )

    describe('array of objects', ->
      data = undefined
      before( ->
        data = apiBlueprintAdapter.ensureObjectOfObjects([
          {'name': 'Accept-Language', 'value': 'cs'}
          {'name': 'Accept', 'value': 'beverage/beer'}
        ])
      )
      it('results in the right object', ->
        assert.deepEqual(data,
          'Accept-Language': {'value': 'cs'}
          'Accept': {'value': 'beverage/beer'}
        )
      )
    )

    describe('array of objects with custom key selected', ->
      data = undefined
      before( ->
        data = apiBlueprintAdapter.ensureObjectOfObjects([
          {'name': 'Accept-Language', 'value': 'cs'}
          {'name': 'Accept', 'value': 'beverage/beer'}
        ], 'value')
      )
      it('results in the right object', ->
        assert.deepEqual(data,
          'cs': {'name': 'Accept-Language'}
          'beverage/beer': {'name': 'Accept'}
        )
      )
    )
  )
)

describe('Test errors and warnings', ->

  describe('When I send in simple blueprint with one resource and error', ->
    errors = null
    before((done) ->
      code = '''FORMAT: 1A
      # Name\t

      ## GET /resource

      '''

      parseApiBlueprint(code, (err, newAst, warnings) ->
        if err
          errors = err
        done()
      )
    )

    it('I have error code', ->
      assert.equal(2, errors.code)
    )
    it('I have error line', ->
      assert.equal(2, errors.line)
    )
    it('I have error message', ->
      assert.equal("the use of tab(s) \'\\t\' in source data isn\'t currently supported, please contact makers", errors.message)
    )
    it('I have error location index', ->
      assert.equal(17, errors.location[0].index)
    )
    it('I have error location length', ->
      assert.equal(1, errors.location[0].length)
    )
  )

  describe('When I send in simple blueprint with one resource and warnings', ->
    warn = null
    before((done) ->
      code = '''FORMAT: 1A
      # Name

      ## GET /resource

      ## GET /resource

      '''

      parseApiBlueprint(code, (err, newAst, warnings) ->
        if warnings then warn = warnings
        ast = newAst
        done(err)
      )
    )

    it('I have warning message', ->
      assert.equal("action is missing a response", warn[0].message)
    )
    it('I have warning code', ->
      assert.equal(6, warn[0].code)
    )
    it('I have warning location index', ->
      assert.equal(19, warn[0].location[0].index)
    )
    it('I have warning location length', ->
      assert.equal(18, warn[0].location[0].length)
    )
  )
)
