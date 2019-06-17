{assert} = require('chai')
drafter = require('drafter.js')

metamorphoses = require('../src/metamorphoses')


source = '''
  FORMAT: 1A

  # Test API
  ## Test [/test]
  ### Test Test Test [GET]

  + Request
  + Response 200 (application/json)
      + Body

              {"message": "Hello World!"}

  + Request User Error
  + Response 400 (application/json)
      + Body

              {"error": "This is error :("}

  + Request Something Not Found
  + Response 404 (application/json)
      + Body

              {"error": "This is error :("}
'''


isApiElement = (element) ->
  return false if element.element isnt 'category'
  return element.meta?.classes.indexOf('api') isnt -1


describe('Multiple Transactions', ->
  describe('when API Blueprint has three request-response pairs', ->
    applicationAst = undefined

    beforeEach((done) ->
      mediaType = 'application/vnd.refract.api-description+json'
      adapter = metamorphoses.createAdapter(mediaType)

      drafter.parse(source, {
        generateSourceMap: false,
        json: true,
        requireBlueprintName: false,
      }, (err, parseResult) ->
        return done(err) if err

        apiElement = parseResult.content.filter(isApiElement)[0]
        applicationAst = adapter.transformAst(apiElement)
        done()
      )
    )

    it('produces three requests', ->
      assert.equal(applicationAst.sections[0].resources[0].requests.length, 3)
    )
    it('produces three responses', ->
      assert.equal(applicationAst.sections[0].resources[0].responses.length, 3)
    )

    examples = [
      {reqName: '', resStatusCode: 200}
      {reqName: 'User Error', resStatusCode: 400}
      {reqName: 'Something Not Found', resStatusCode: 404}
    ]
    examples.forEach((pair, pairNumber) ->
      context("pair ##{pairNumber}", ->
        it("has request example ID equal to #{pairNumber}", ->
          req = applicationAst.sections[0].resources[0].requests[pairNumber]
          assert.equal(req.exampleId, pairNumber)
        )
        it("has response example ID equal to #{pairNumber}", ->
          res = applicationAst.sections[0].resources[0].responses[pairNumber]
          assert.equal(res.exampleId, pairNumber)
        )
        it("has request name '#{pair.reqName}'", ->
          req = applicationAst.sections[0].resources[0].requests[pairNumber]
          assert.equal(req.name, pair.reqName)
        )
        it("has response status code '#{pair.resStatusCode}'", ->
          res = applicationAst.sections[0].resources[0].responses[pairNumber]
          assert.equal(res.status, pair.resStatusCode)
        )
      )
    )
  )
)
