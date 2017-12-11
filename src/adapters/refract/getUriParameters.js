/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const lodash = require('./helper');
const getMetaDescription = require('./getMetaDescription');

const getUriParameters = function(hrefVariables, options) {
  const hrefVariablesContent = lodash.content(hrefVariables);

  if (hrefVariablesContent === undefined) {
    return undefined;
  }

  return hrefVariablesContent.map(function(hrefVariable) {
    let example, required;
    const lodashedHrefVariable = lodash.chain(hrefVariable);
    const typeAttributes = lodashedHrefVariable
                        .get('attributes.typeAttributes')
                        .value();

    if (typeAttributes) {
      required = typeAttributes.indexOf('required') !== -1;
    } else {
      required = false;
    }

    const memberContent = lodashedHrefVariable.content();
    const title = lodashedHrefVariable.get('meta.title', '').contentOrValue().value();
    const key = memberContent.get('key').contentOrValue().value();
    const memberContentValue = memberContent.get('value');

    const type = title || memberContentValue.get('element').value();

    const sampleValues = memberContentValue.get('attributes.samples', '').contentOrValue();
    let defaultValue = memberContentValue.get('attributes.default', '').contentOrValue();
    let exampleValue = '';
    let values = [];

    if (lodash.isArray(defaultValue.value())) {
      defaultValue = __guard__(defaultValue.first().contentOrValue().value(), x => x.toString());
    } else {
      defaultValue = defaultValue.value().toString();
    }

    if (sampleValues.value()) {
      example = sampleValues.first().contentOrValue();

      if (lodash.isArray(example.value())) {
        exampleValue = __guard__(example.first().contentOrValue().value(), x1 => x1.toString());
      } else {
        exampleValue = example.value().toString();
      }
    }

    const memberContentValueContent = memberContentValue.content();

    if (!lodash.isArray(memberContentValueContent.value())) {
      exampleValue = __guard__(memberContentValueContent.value(), x2 => x2.toString()) || '';
    } else {
      values = memberContentValueContent.map(function(element) {
        const elementContent = lodash(element).content();

        if (lodash.isArray(elementContent.value())) {
          return elementContent.map('content').value();
        } else {
          return __guard__(elementContent.value(), x3 => x3.toString());
        }
      }).flatten().value();
    }

    return {
      description: getMetaDescription(hrefVariable, options),
      type,
      required,
      default: defaultValue,
      example: exampleValue,
      values,
      key
    };
  });
};

module.exports = getUriParameters;

function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}