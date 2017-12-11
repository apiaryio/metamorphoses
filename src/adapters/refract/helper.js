/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const lodash = require('lodash');
require('lodash-api-description')(lodash);

const trimLastNewline = function(str) {
  if (!lodash.isString(str)) { return; }
  return str.replace(/\n$/, '');
};

lodash.mixin({
  trimLastNewline
});

module.exports = lodash;
