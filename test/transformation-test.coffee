{assert} = require('chai')
ApiaryBlueprintParser = require('apiary-blueprint-parser')
protagonist = require('protagonist')

CURRENT_APPLICATION_AST_VERSION = require('../src/blueprint-api').Version
apiBlueprintAdapter = require('../src/adapters/api-blueprint-adapter')
apiaryBlueprintAdapter = require('../src/adapters/apiary-blueprint-adapter')
refractAdapter = require('../src/adapters/refract-adapter')
apiNamespaceHelper = require('../src/adapters/refract/helper')


parseApiaryBlueprint = (source, cb) ->
  adapter = apiaryBlueprintAdapter
  try
    ast = ApiaryBlueprintParser.parse(source)
  catch err
    err = adapter.transformError(source, err)
    return cb(err)
  cb(null, adapter.transformAst(ast.toJSON()), [])


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

    err = adapter.transformError(source, err)
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
            expected = if type is 'refract' then 'Lorem ipsum 1\n' else 'Lorem ipsum 1'
            assert.equal(ast.description, expected)
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
            expected = if type is 'refract' then 'Lorem ipsum 2\n' else 'Lorem ipsum 2'
            assert.equal(ast.sections[0].description, expected)
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
            assert.equal(ast.sections[0].resources[0].description, 'Lorem ipsum 3\n')
          )
          it('resource has HTML description', ->
            assert.equal(ast.sections[0].resources[0].htmlDescription, '<p>Lorem ipsum 3</p>')
          )
          it('resource has action description', ->
            assert.equal(ast.sections[0].resources[0].actionDescription, 'Lorem ipsum 4\n')
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
      )

      describe('In the JSON serialization', ->
        it('Resource has URL prefixed with path from HOST URL', ->
          assert.equal(resourceJSON.url, '/v1/resource')
        )
        it('Resource has URI Template without prefix', ->
          assert.equal(resourceJSON.uriTemplate, '/resource')
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
            assert.equal(headers['Set-Cookie'], 'efgh')
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

  describe('Legacy Apiary Blueprint', ->
    describe('When I send in simple blueprint with one resource', ->
      ast = undefined
      before((done) ->
        code = '''--- Name ---

        GET /resource
        < 200
        '''

        parseApiaryBlueprint(code, (err, newAst) ->
          ast = newAst
          done(err)
        )
      )

      it('I got API name', ->
        assert.equal('Name', ast.name)
      )
      it('I can see my resource url', ->
        assert.equal('/resource', ast.sections[0].resources[0].url)
      )
      it('I can see my resource method', ->
        assert.equal('GET', ast.sections[0].resources[0].method)
      )
      it('I can see my response status', ->
        assert.equal(200, ast.sections[0].resources[0].responses[0].status)
      )
      it('I have send nothing in request body', ->
        assert.equal('', ast.sections[0].resources[0].request.body)
      )

      it('I have send nothing in request headers', ->
        assert.deepEqual({}, ast.sections[0].resources[0].request.headers)
      )
    )

    describe('When I send in simple legacy apiary blueprint with one POST resource and headers', ->
      ast = undefined
      before((done) ->
        code = '''--- Name ---

        POST /resource
        > Content-Type: application/json
        { "product":"1AB23ORM", "quantity": 2 }
        < 201
        < Content-Type: application/json
        { "status": "created", "url": "/shopping-cart/2" }
        '''

        parseApiaryBlueprint(code, (err, newAst) ->
          ast = newAst
          done(err)
        )
      )

      it('I got API name', ->
        assert.equal('Name', ast.name)
      )
      it('I can see my resource url', ->
        assert.equal('/resource', ast.sections[0].resources[0].url)
      )
      it('I can see my resource method', ->
        assert.equal('POST', ast.sections[0].resources[0].method)
      )
      it('I can see my response status', ->
        assert.equal(201, ast.sections[0].resources[0].responses[0].status)
      )
      it('I have send values in request body', ->
        assert.equal('{ "product":"1AB23ORM", "quantity": 2 }', ast.sections[0].resources[0].request.body)
      )

      it('I have send content-type in request headers', ->
        assert.deepEqual({'Content-Type': 'application/json'}, ast.sections[0].resources[0].request.headers)
      )
    )

    describe('When I send in legacy apiary blueprint with many empty sections', ->
      it('should parse in less than 2000ms', (done) ->
        code = '''
--- API ---

-- S1 --

-- S2 --

-- S3 --

-- S4 --

-- S5 --

-- S6 --

-- S7 --

-- S8 --

-- S9 --

-- S10 --

-- S11 --

-- S12 --

-- S13 --

-- S14 --

-- S15 --

-- S16 --

-- S17 --

-- S18 --

-- S19 --

-- S20 --
'''
        parseTimestamp = Date.now() # Since parser is blocking result to comparing timestamps
        parseApiaryBlueprint(code, (err, ast) ->
          assert.isNull(err)
          assert.isDefined(ast)
          assert.strictEqual(ast.sections.length, 20)
          assert(Date.now() - parseTimestamp < 2000, 'parsing not under 2000ms')
          done(err)
        )
      )
    )

    describe('Blueprint with HOST suffix', ->
      resource = undefined
      resourceJSON = undefined

      before((done) ->
        code = '''
          HOST: http://localhost:8002/v1/

          --- Testing ---

          -- basic methods --
          GET /resource
          < 200
          { "items": [
            { "url": "/shopping-cart/1", "product":"2ZY48XPZ", "quantity": 1, "name": "New socks", "price": 1.25 }
          ] }
        '''

        parseApiaryBlueprint(code, (err, ast) ->
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
      )

      describe('In the JSON serialization', ->
        it('Resource has URL prefixed with path from HOST URL', ->
          assert.equal(resourceJSON.url, '/v1/resource')
        )
        it('Resource has URI Template without prefix', ->
          assert.equal(resourceJSON.uriTemplate, '/resource')
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

  describe('When I send in simple legacy apiary blueprint with one resource and error', ->
    ast = null
    errors = null
    before((done) ->
      code = '''\t--- Name ---

      GET /resource
      < 200
      '''

      parseApiaryBlueprint(code, (err, newAst) ->
        if err
          errors = err
        ast = newAst
        done()
      )
    )

    it('I have error line', ->
      assert.equal(1, errors.line)
    )
    it('I have error message', ->
      assert.equal('Expected \"---\", \"HOST:\" or empty line but \"\\t\" found.', errors.message)
    )
    it('I have error column', ->
      assert.equal(1, errors.column)
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
