/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

const typer = require('media-typer');

const blueprintApi = require('./blueprint-api');
const markdown = require('./adapters/markdown');
const refractAdapter = require('./adapters/refract-adapter');


const createAdapter = function(mimeType) {
  let parsedMimeType;
  try {
    parsedMimeType = typer.parse(mimeType);
  } catch (e) {
    return; // not parseable mime type?!
  }

  if (parsedMimeType.type !== 'application') {
    return;
  }

  // Refract
  // https://github.com/refractproject/refract-spec
  if (parsedMimeType.subtype === 'vnd.refract.api-description') {
    if (!parsedMimeType.suffix || (parsedMimeType.suffix === 'json')) {
      return refractAdapter;
    }
    return;
  }
};


const mergeParams = function(resourceParams, actionParams) {
  if (resourceParams == null) { resourceParams = []; }
  if (actionParams == null) { actionParams = []; }
  const params = [];

  const actionParamKeys = actionParams.map(param => param.key);

  for (let param of Array.from(resourceParams)) {
    if (!Array.from(actionParamKeys).includes(param.key)) {
      params.push(param);
    }
  }

  return params.concat(actionParams);
};

module.exports = {
  // Blueprint API (aka Application AST)
  blueprintApi,

  // Adapters
  createAdapter,
  refractAdapter,

  // Markdown rendering
  markdown,

  // Utility
  mergeParams
};
