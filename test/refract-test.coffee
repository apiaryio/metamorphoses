{assert} = require('chai')

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


describe('Transformations • Refract', ->
  describe('Title', ->
    [
        label: 'as primitive value'
        ast: convertToApplicationAst(require('./fixtures/refract-parse-result-title-as-primitive-value.json'))
      ,
        label: 'as refract element'
        ast: convertToApplicationAst(require('./fixtures/refract-parse-result-title-as-refract-element.json'))
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
        label: 'Parse Result sith Resource Group'
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
)
