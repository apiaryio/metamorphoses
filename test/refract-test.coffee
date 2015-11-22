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
  )
)
