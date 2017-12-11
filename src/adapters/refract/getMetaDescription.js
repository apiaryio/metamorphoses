/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const lodash = require('./helper');
const markdown = require('../markdown');

module.exports = function(element, options) {
  const rawDescription = lodash
                    .chain(element)
                    .get('meta.description', '')
                    .contentOrValue()
                    .trimLastNewline()
                    .value();

  return markdown.toHtmlSync(rawDescription, options);
};
