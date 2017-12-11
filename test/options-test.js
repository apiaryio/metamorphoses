/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const {assert} = require('chai');
const sinon = require('sinon');
const protagonist = require('protagonist');

const markdown = require('../src/adapters/markdown');
const lodash = require('../src/adapters/refract/helper');
const refractAdapter = require('../src/adapters/refract-adapter');

describe('Options are passed to markdown renderer functions', function() {
  let markdownSpy = null;
  let markdownAsyncSpy = null;
  const sourcemaps = undefined;

  before(function() {
    markdownSpy = sinon.spy(markdown, 'toHtmlSync');
    return markdownAsyncSpy = sinon.spy(markdown, 'toHtml');
  });

  beforeEach(function() {
    markdownSpy.reset();
    return markdownAsyncSpy.reset();
  });

  after(function() {
    markdown.toHtmlSync.restore();
    return markdown.toHtml.restore();
  });

  return context('Refract adapter passes options to markdown renderer', function() {
    const parseResultElement = JSON.parse(JSON.stringify(require('./fixtures/refract-parse-result-x-values.json')));
    let apiDescriptionElement = null;
    let options = undefined;

    beforeEach( function() {
      apiDescriptionElement = lodash.chain(parseResultElement)
        .content()
        .find({element: 'category', meta: {classes: ['api']}})
        .value();
      return refractAdapter.transformAst(apiDescriptionElement, sourcemaps, options);
    });

    describe('When called without options', function() {
      before(() => options = undefined);

      return it('It does call Robotskirt Markdown to HTML renderer', function() {
        assert.isTrue(markdownSpy.called);
        for (let callArgs of Array.from(markdownSpy.args)) {
          assert.isUndefined(callArgs[1]);
        }
        return assert.isFalse(markdownAsyncSpy.called);
      });
    });
    return describe('When called with options `{testOption: true}`', function() {
      before(() => options = {testOption: true});

      return it('It does call CommonMark Markdown to HTML renderer', function() {
        assert.isTrue(markdownSpy.called);
        for (let callArgs of Array.from(markdownSpy.args)) {
          assert.equal(callArgs[0], 'Resource Description');
          assert.deepEqual(callArgs[1], {'testOption': true});
        }
        return assert.isFalse(markdownAsyncSpy.called);
      });
    });
  });
});
