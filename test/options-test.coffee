{assert} = require('chai')
sinon = require('sinon')
protagonist = require('protagonist')

markdown = require('../src/adapters/markdown')

lodash = require('../src/adapters/refract/helper')

refractAdapter = require('../src/adapters/refract-adapter')
apiaryBlueprintAdapter = require('../src/adapters/apiary-blueprint-adapter')
apiBlueprintAdapter = require('../src/adapters/api-blueprint-adapter')

describe('Options are passed to markdown renderer functions', ->
  markdownSpy = null
  markdownAsyncSpy = null
  sourcemaps = undefined

  before(->
    markdownSpy = sinon.spy(markdown, 'toHtmlSync')
    markdownAsyncSpy = sinon.spy(markdown, 'toHtml')
  )

  beforeEach(->
    markdownSpy.reset()
    markdownAsyncSpy.reset()
  )

  after(->
    markdown.toHtmlSync.restore()
    markdown.toHtml.restore()
  )

  context('Refract adapter passes options to markdown renderer', ->
    parseResultElement = JSON.parse(JSON.stringify(require('./fixtures/refract-parse-result-x-values.json')))
    apiDescriptionElement = null
    options = undefined

    beforeEach( ->
      apiDescriptionElement = lodash.chain(parseResultElement)
        .content()
        .find({element: 'category', meta: {classes: ['api']}})
        .value()
      refractAdapter.transformAst(apiDescriptionElement, sourcemaps, options)
    )

    describe('When called without options', ->
      before(->
        options = undefined
      )

      it('It does call Robotskirt Markdown to HTML renderer', ->
        assert.isTrue(markdownSpy.called)
        for callArgs in markdownSpy.args
          assert.isUndefined(callArgs[1])
        assert.isFalse(markdownAsyncSpy.called)
      )
    )
    describe('When called with options `{testOption: true}`', ->
      before(->
        options = {testOption: true}
      )

      it('It does call CommonMark Markdown to HTML renderer', ->
        assert.isTrue(markdownSpy.called)
        for callArgs in markdownSpy.args
          assert.equal(callArgs[0], 'Resource Description')
          assert.deepEqual(callArgs[1], {'testOption': true})
        assert.isFalse(markdownAsyncSpy.called)
      )
    )
  )

  context('API Blueprint adapter passes options to markdown renderer', ->
    options = undefined

    beforeEach((done) ->
      source = """
        FORMAT: 1A
        # apiName
        such _description_.
        ## GET [/api]
        Yours lines are good!
      """

      protagonist.parse(source, {type: 'ast'}, (err, result = {}) ->
        return done(err) if err
        apiBlueprintAdapter.transformAst(result.ast, sourcemaps, options)
        done(err)
      )
    )

    describe('When called without options', ->
      before(->
        options = undefined
      )
      it('It does call Robotskirt Markdown to HTML renderer', ->
        assert.isTrue(markdownSpy.called)
        for callArgs in markdownSpy.args
          # Allow empty string because resource group description
          assert.oneOf(callArgs[0], ['Yours lines are good!', 'such _description_.', ''])
          assert.isUndefined(callArgs[1])
        assert.isFalse(markdownAsyncSpy.called)
      )
    )

    describe('When called with options `{testOption: true}`', ->
      before(->
        options = {testOption: true}
      )
      it('It does call CommonMark Markdown to HTML renderer', ->
        assert.isTrue(markdownSpy.called)
        for callArgs in markdownSpy.args
          assert.deepEqual(callArgs[1], {'testOption': true})
        assert.isFalse(markdownAsyncSpy.called)
      )
    )
  )
)
