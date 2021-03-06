{assert} = require('chai')
sinon = require('sinon')

markdown = require('../src/adapters/markdown')
lodash = require('../src/adapters/refract/helper')
refractAdapter = require('../src/adapters/refract-adapter')

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
)
