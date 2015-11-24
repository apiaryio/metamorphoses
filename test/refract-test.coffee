{assert} = require('chai')
swaggerZoo = require('@apiaryio/swagger-zoo')

lodash = require('../src/adapters/refract/helper')
refractAdapter = require('../src/adapters/refract-adapter')


getApiDescription = (parseResultElement) ->
  lodash.chain(parseResultElement)
    .content()
    .find({element: 'category', meta: {classes: ['api']}})
    .value()

convertToApplicationAst = (parseResultElement) ->
  apiDescriptionElement = getApiDescription(parseResultElement)
  refractAdapter.transformAst(apiDescriptionElement)

getZooFeature = (name, debug) ->
  {refract, swagger} = lodash.chain(swaggerZoo.features()).find({name}).value()
  ast = convertToApplicationAst(refract)

  if debug
    console.log 'SWAGGER:', swagger
    console.log '\n----------------------------\n'
    console.log 'REFRACT:', JSON.stringify(refract, null, 2)
    console.log '\n----------------------------\n'
    console.log 'AST:', JSON.stringify(ast, null, 2)



  {ast, refract, swagger}


describe('Transformations • Refract', ->
  describe('Resources', ->
    [
        label: 'Parse Result with Resource Group'
        ast: convertToApplicationAst(require('./fixtures/refract-parse-result-with-resource-group.json'))
      ,
        label: 'Parse Result without Resource Group'
        ast: convertToApplicationAst(require('./fixtures/refract-parse-result-without-resource-group.json'))
    ].forEach(({label, ast}) ->
      context(label, ->
        it('has one resource group', ->
          assert.equal(ast.sections.length, 1)
        )

        it('has two resources', ->
          assert.equal(ast.sections[0].resources.length, 2)
        )

        it('Resource with GET method', ->
          resource = lodash
            .chain(ast.sections[0].resources)
            .find({method: 'GET'})
            .value()

          assert.isOk(resource)
        )

        it('Resource with POST method', ->
          resource = lodash
            .chain(ast.sections[0].resources)
            .find({method: 'POST'})
            .value()

          assert.isOk(resource)
        )
      )
    )
  )

  context('Features', ->
    describe('Minimal JSON', ->
      ast = null
      before( ->
        {ast} = getZooFeature('minimal-json')
      )

      it('has a name', ->
        assert.isOk(ast.name)
      )

      it('has one section', ->
        assert.equal(ast.sections.length, 1)
      )

      it('section has no name', ->
        assert.equal(ast.sections[0].name, '')
      )
    )

    describe('Action', ->
      ast = null
      before( ->
        {ast} = getZooFeature('action')
      )

      it('has one artificial section', ->
        assert.equal(ast.sections.length, 1)
        assert.equal(ast.sections[0].name, '')
      )

      it('has 7 resources', ->
        assert.equal(ast.sections[0].resources.length, 7)
      )

      describe('GET method properties', ->
        resource = null
        before( ->
          resource = lodash
            .chain(ast.sections[0].resources)
            .find({method: 'GET'})
            .value()
        )

        it('has actionName', ->
          assert.isOk(resource.actionName)
        )

        it('has actionDescription', ->
          assert.isOk(resource.actionDescription)
        )

        it('has actionRelation', ->
          assert.isOk(resource.actionRelation)
        )
      )
    )

    describe('Description', ->
      ast = null
      before( ->
        {ast} = getZooFeature('description')
      )

      it('has name', ->
        assert.isOk(ast.name)
      )

      it('has description', ->
        assert.isOk(ast.description)
      )
    )

    describe('Example Header', ->
      ast = null
      before( ->
        {ast} = getZooFeature('example-header')
      )

      it('Response has correct headers', ->
        expected = {
          'Content-Type': 'application/json'
          'Accepts': ''
          'X-Test1': 100
          'X-Test2': 'abc'
        }
        assert.deepEqual(ast.sections[0].resources[0].responses[0].headers, expected)
      )
    )

    describe('Parameter and No Response', ->
      ast = null
      before( ->
        {ast} = getZooFeature('param-no-response')
      )

      it('resource has reqest schema', ->
        expected = '{\"type\":\"string\"}'
        assert.equal(ast.sections[0].resources[0].requests[0].schema, expected)
      )
    )

    describe('Params', ->
      ast = null
      before( ->
        {ast} = getZooFeature('params')
      )

      context('GET', ->
        resource = null
        before( ->
          resource = ast.sections[0].resources[0]
        )

        it('method is GET', ->
          assert.equal(resource.method, 'GET')
        )

        it('url equals to `/test/{id}{?arg}`', ->
          assert.equal(resource.uriTemplate, '/test/{id}{?arg}')
        )

        it('uriTemplate equals to `/test/{id}{?arg}`', ->
          assert.equal(resource.uriTemplate, '/test/{id}{?arg}')
        )

        it('has two parameters', ->
          assert.equal(resource.parameters.length, 2)
        )

        it('has two actionParameters', ->
          assert.equal(resource.actionParameters.length, 2)
        )

        it('first parameter is `id`', ->
          assert.equal(resource.parameters[0].key, 'id')
        )

        it('first parameter is required', ->
          assert.isTrue(resource.parameters[0].required)
        )

        it('first parameter has `type` equal to `string`', ->
          assert.equal(resource.parameters[0].type, 'string')
        )

        it('second parameter is `arg`', ->
          assert.equal(resource.parameters[1].key, 'arg')
        )

        it('second parameter isn\'t required', ->
          assert.isFalse(resource.parameters[1].required)
        )
      )

      context('POST', ->
        resource = null
        before( ->
          resource = ast.sections[0].resources[1]
        )

        it('method is POST', ->
          assert.equal(resource.method, 'POST')
        )

        it('url equals to `/test`', ->
          assert.equal(resource.uriTemplate, '/test')
        )

        it('uriTemplate equals to `/test`', ->
          assert.equal(resource.uriTemplate, '/test')
        )

        it('has schema', ->
          assert.equal(resource.request.schema, '{\"type\":\"string\"}')
        )
      )
    )
  )
)
