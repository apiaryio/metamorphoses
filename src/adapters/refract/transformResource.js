/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const _ = require('./helper');
const blueprintApi = require('../../blueprint-api');
const getDescription = require('./getDescription');
const getUriParameters = require('./getUriParameters');
const transformTransactions = require('./transformTransactions');

module.exports = function(resourceElement, urlPrefix, options) {
  const resources = [];

  const resourceDescription = getDescription(resourceElement, options);
  const transitions = _.transitions(resourceElement);

  const resourceUriTemplate = _.chain(resourceElement).get('attributes.href', '').contentOrValue().value();
  const resourceUrl = urlPrefix + resourceUriTemplate;

  if (transitions.length === 0) {
    return [];
  }

  transitions.forEach(function(transitionElement) {
    const description = getDescription(transitionElement, options);

    const resourceParameters = getUriParameters(_.get(resourceElement, 'attributes.hrefVariables'), options);
    const actionParameters = getUriParameters(_.get(transitionElement, 'attributes.hrefVariables'), options);

    let attributes = _.dataStructures(resourceElement);
    attributes = _.isEmpty(attributes) ? undefined : attributes[0];
    const actionAttributes = _.get(transitionElement, 'attributes.data');

    // Resource
    //
    // * `method` is set when iterating `httpTransaction`
    // * Dtto, `actionUriTemplate`
    //
    const transitionUriTemplate = _.chain(transitionElement).get('attributes.href', '').contentOrValue().value();

    const resource = new blueprintApi.Resource({
      url: urlPrefix + (transitionUriTemplate || resourceUriTemplate),
      uriTemplate: transitionUriTemplate || resourceUriTemplate,
      resourceUriTemplate,
      actionUriTemplate: transitionUriTemplate,

      name: _.chain(resourceElement).get('meta.title', '').contentOrValue().value().trim(),

      // We can safely leave these empty for now.
      headers: {},
      actionHeaders: {},

      description: resourceDescription.raw,
      htmlDescription: resourceDescription.html,
      actionName: _.chain(transitionElement).get('meta.title', '').contentOrValue().value().trim(),

      // Model has been deprecated in the API Blueprint format,
      // therfore we can safely skip it.
      model: {},

      actionDescription: description.raw,
      actionHtmlDescription: description.html,
      attributes,
      actionAttributes,

      actionRelation: _.chain(transitionElement).get('attributes.relation', '').contentOrValue().value()
    });

    [resource.method, resource.requests, resource.responses] = Array.from(transformTransactions(_.httpTransactions(transitionElement), options));

    resource.request = resource.requests[0];

    resource.resourceParameters = resourceParameters || [];
    resource.actionParameters = actionParameters || [];
    resource.parameters = actionParameters || resourceParameters || [];

    return resources.push(resource);
  });

  return resources;
};
