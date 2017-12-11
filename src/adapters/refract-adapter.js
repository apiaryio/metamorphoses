/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const _ = require('./refract/helper');
const blueprintApi = require('../blueprint-api');

const getDescription = require('./refract/getDescription');
const transformAuth = require('./refract/transformAuth');
const transformSections = require('./refract/transformSections');
const transformDataStructures = require('./refract/transformDataStructures');


const countLines = function(code, index) {
  if (index > 0) {
    const excerpt = code.substr(0, index);
    return excerpt.split(/\r\n|\r|\n/).length;
  } else {
    return 1;
  }
};


const transformAst = function(element, sourcemap, options) {
  if (!element) { return null; }

  const applicationAst = new blueprintApi.Blueprint({
    name: _.chain(element).get('meta.title', '').contentOrValue().trimLastNewline().value(),
    version: blueprintApi.Version,
    metadata: []
  });

  // Metadata and location
  applicationAst.metadata =
    _.chain(element)
    .get('attributes.meta')
    .contentOrValue()
    .filter({meta: {classes: ['user']}})
    .map(function(entry) {
      const content = _.content(entry);

      const name = _.chain(entry).content().get('key').contentOrValue().value();
      const value = _.chain(entry).content().get('value', '').contentOrValue().value();

      if (name === 'HOST') {
        if (name === 'HOST') { applicationAst.location = value; }
        return null;
      } else {
        return {name, value};
      }
    }).compact()
    .uniqBy('name')
    .value();

  // description
  const description = getDescription(element, options);

  applicationAst.description = description.raw;
  applicationAst.htmlDescription = description.html;

  // Authentication definitions
  applicationAst.authDefinitions = transformAuth(element, options);

  // Sections
  applicationAst.sections = transformSections(element, applicationAst.location, options);
  applicationAst.dataStructures = transformDataStructures(element, options);

  return applicationAst;
};


const transformError = function(source, parseResult) {
  const errors = _.chain(parseResult)
    .filterContent({element: 'annotation'})
    .filter({meta: {classes: ['error']}})
    .value();

  if (errors.length > 0) {
    const errorElement = errors[0];
    const sourceMaps = __guard__(__guard__(errorElement.attributes != null ? errorElement.attributes.sourceMap : undefined, x1 => x1[0]), x => x.content);
    let locations = sourceMaps != null ? sourceMaps.map(sourceMap => ({index: sourceMap[0], length: sourceMap[1]})) : undefined;

    if (!locations) {
      // When there is no existing source maps, treat whole document as source
      locations = [{index: 0, length: source.length}];
    }

    const error = {
      message: errorElement.content,
      code: (errorElement.attributes != null ? errorElement.attributes.code : undefined) || 1,
      line: countLines(source, __guard__(locations != null ? locations[0] : undefined, x2 => x2.index)),
      location: locations
    };

    return error;
  }
};


module.exports = {
  transformAst,
  transformError
};

function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}