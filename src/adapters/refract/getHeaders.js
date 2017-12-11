/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const _ = require('./helper');

const transformHeaders = function(element, type) {
  const result = type === 'legacy' ? {} : [];
  const httpHeaders = _.get(element, 'attributes.headers');

  if (!httpHeaders) { return result; }

  _.content(httpHeaders).forEach(function(headerElement) {
    const content = _.content(headerElement);
    const key = _.chain(content).get('key').contentOrValue().value();
    const value = _.chain(content).get('value').contentOrValue().value();

    switch (type) {
      case 'legacy':
        if (key) { return result[key] = value; }
        break;
      case '1A':
        return result.push({
          name: key,
          value
        });
    }
  });

  return result;
};

const getHeaders = element => transformHeaders(element, 'legacy');

const getHeaders1A = element => transformHeaders(element, '1A');

module.exports = {
  getHeaders,
  getHeaders1A
};
