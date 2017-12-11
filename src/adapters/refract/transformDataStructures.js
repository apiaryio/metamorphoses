/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const _ = require('./helper');

module.exports = function(parentElement, options) {
  let dataStructures = [];

  _.forEach(_.get(parentElement, 'content'), function(element, index) {
    if (element.element === 'category') {
      const classes = _.get(element, 'meta.classes', []);

      if (classes.indexOf('dataStructures') !== -1) {
        return dataStructures = dataStructures.concat(
          _.get(element, 'content')
        );
      }
    }
  });

  return dataStructures;
};
