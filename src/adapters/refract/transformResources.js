/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const _ = require('./helper');
const blueprintApi = require('../../blueprint-api');
const transformResource = require('./transformResource');

module.exports = function(element, urlPrefix, options) {
  let resources = [];

  _.resources(element).forEach(resourceElement => resources = resources.concat(transformResource(resourceElement, urlPrefix, options)));

  return resources;
};
