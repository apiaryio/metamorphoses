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
    console.log('SWAGGER:', swagger)
    console.log('\n----------------------------\n')
    console.log('REFRACT:', JSON.stringify(refract, null, 2))
    console.log('\n----------------------------\n')
    console.log('AST:', JSON.stringify(ast, null, 2))

  {ast, refract, swagger}


describe('Transformations • Refract', ->
  describe('Title', ->
    [
        label: 'as primitive value'
        ast: convertToApplicationAst(
          require('./fixtures/refract-parse-result-title-as-primitive-value.json')
        )
      ,
        label: 'as refract element'
        ast: convertToApplicationAst(
          require('./fixtures/refract-parse-result-title-as-refract-element.json')
        )
    ].forEach(({label, ast}) ->
      context(label, ->
        it('has name equal to `Title example`', ->
          assert.equal(ast.name, 'Title example')
        )
      )
    )
  )

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

  describe('hrefVariables', ->
    ast = null
    resource = null
    before( ->
      ast = convertToApplicationAst(require('./fixtures/refract-parse-result-href-variables.json'))
      resource = ast.sections[0].resources[0]
    )

    it('resource has three parameters', ->
      assert.equal(resource.parameters.length, 3)
    )

    it('resource has one resource parameter', ->
      assert.equal(resource.resourceParameters.length, 1)
    )

    it('resource has two action parameters', ->
      assert.equal(resource.actionParameters.length, 2)
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

      it('doesn\'t have any sections', ->
        assert.equal(ast.sections.length, 0)
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

    describe('Path level parameters', ->
      ast = null
      resource = null
      before( ->
        {ast} = getZooFeature('path-level-params')
        resource = ast.sections[0].resources[0]
      )

      it('URI template contains all parameters', ->
        assert.equal(resource.uriTemplate, '/test/{id}{?search,arg}')
      )

      it('resource have three paramters', ->
        assert.equal(resource.parameters.length, 3)
      )

      it('2 paramters are resource paramters', ->
        assert.equal(resource.resourceParameters.length, 2)
      )

      it('1 paramter is action paramter', ->
        assert.equal(resource.actionParameters.length, 1)
      )
    )

    describe('Tags', ->
      ast = null
      before( ->
        {ast} = getZooFeature('tags')
      )

      it('has two sections', ->
        assert.equal(ast.sections.length, 2)
      )

      it('first section has name `Group1`', ->
        assert.equal(ast.sections[0].name, 'Group1')
      )

      it('`Group1` contains 3 resources', ->
        assert.equal(ast.sections[0].resources.length, 3)
      )

      it('second section has name `Group2`', ->
        assert.equal(ast.sections[1].name, 'Group2')
      )

      it('`Group2` contains 2 resources', ->
        assert.equal(ast.sections[1].resources.length, 2)
      )
    )

    describe('Mixed Resources and Resource Groups', ->
      applicationAst = null

      before(->
        applicationAst = convertToApplicationAst(
          require('./fixtures/refract-parse-result-tags.json')
        )
      )

      it('Has the correct sections', ->
        assert.strictEqual(applicationAst.sections.length, 2)
      )

      it('First section has the correct resources', ->
        assert.strictEqual(applicationAst.sections[0].resources.length, 6)
      )

      it('Second section has the correct resources', ->
        assert.strictEqual(applicationAst.sections[1].resources.length, 1)
      )
    )

    describe('Support for x-summary and x-description', ->
      applicationAst = null

      before(->
        applicationAst = convertToApplicationAst(
          # TODO: Use Swagger Zoo when it is brought up to be in sync
          # This file is copy/paste in fury-adapter-swagger currently
          # File: test/fixtures/refract/x-summary-and-description.json
          require('./fixtures/refract-parse-result-x-values.json')
        )
      )

      it('Resource name is correct', ->
        assert.strictEqual(applicationAst.sections[0].resources[0].name, 'Resource Title')
      )

      it('Resource description is correct', ->
        assert.strictEqual(applicationAst.sections[0].resources[0].description, 'Resource Description')
      )
    )

    describe('HTTP Payload Data Structures', ->
      applicationAst = null

      before(->
        applicationAst = convertToApplicationAst(
          require('./fixtures/refract-parse-result-payload-data-structures.json')
        )
      )

      it('Data Structure is present for HTTP Requests', ->
        dataStructureElement = applicationAst.sections[0].resources[0].requests[0].attributes.element
        assert.strictEqual(dataStructureElement, 'dataStructure')
      )

      it('Data Structure is present for HTTP Responses', ->
        dataStructureElement = applicationAst.sections[0].resources[0].responses[0].attributes.element
        assert.strictEqual(dataStructureElement, 'dataStructure')
      )
    )

    describe('Redundant requests', ->
      applicationAst = null

      before(->
        applicationAst = convertToApplicationAst(
          require('./fixtures/refract-parse-result-redundant-requests.json')
        )
      )

      it('Has the correct HTTP request', ->
        assert.strictEqual(applicationAst.sections[0].resources[0].requests.length, 1)
      )
    )

    describe('‘x-summary’ and ‘x-description’', ->
      applicationAst = null

      before(->
        applicationAst = convertToApplicationAst(
          require('./fixtures/refract-parse-result-x-summary.json')
        )
      )

      it('Has the correct number of resources', ->
        assert.strictEqual(applicationAst.sections[0].resources.length, 2)
      )

      it('First resource has the correct URL and URI Template', ->
        assert.strictEqual(
          applicationAst.sections[0].resources[0].url,
          '/test'
        )
        assert.strictEqual(
          applicationAst.sections[0].resources[0].uriTemplate,
          '/test'
        )
      )

      it('First resource has the correct description', ->
        assert.strictEqual(
          applicationAst.sections[0].resources[0].description,
          'I am a description'
        )
      )

      it('Second resource has the correct URL and URI Template', ->
        assert.strictEqual(
          applicationAst.sections[0].resources[1].url,
          '/test2'
        )
        assert.strictEqual(
          applicationAst.sections[0].resources[1].uriTemplate,
          '/test2'
        )
      )

      it('Second resource has the correct name', ->
        assert.strictEqual(
          applicationAst.sections[0].resources[1].name,
          'I am a summary'
        )
      )
    )
  )
)
