/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const _ = require('./helper');

const getDescription = require('./getDescription');

module.exports = function(parentElement, options) {
  // Auth information can be present in two places:
  // 1. An `authSchemes` category that contains definitions
  // 2. An `authSchems` attribute that defines which definition to use
  let authSchemes = [];

  if (parentElement && (parentElement.element === 'category')) {
    for (let child of Array.from(_.get(parentElement, 'content', []))) {
      if (child && (child.element === 'category') && (_.get(child, 'meta.classes', []).indexOf('authSchemes') !== -1)) {
        authSchemes = authSchemes.concat(child.content);
      }
    }
  }

  if (_.get(parentElement, 'attributes.authSchemes')) {
    authSchemes = authSchemes.concat(parentElement.attributes.authSchemes);
  }

  return authSchemes;
};
