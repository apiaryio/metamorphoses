/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const _ = require('./helper');

const blueprintApi = require('../../blueprint-api');
const getDescription = require('./getDescription');

const transformResources = require('./transformResources');
const transformResource = require('./transformResource');


module.exports = function(parentElement, location, options) {
  const resourceGroups = [];

  // List of Application AST Resources (= already transformed
  // Refract Resources into the Application AST Resource).
  let resourcesWithoutGroup = [];

  let urlPrefix = '';

  if (location) {
    const urlWithoutProtocol = location.replace(/^https?:\/\//, '');
    const pathIndex = urlWithoutProtocol.indexOf("/");

    if (pathIndex > 0) {
      urlPrefix = urlWithoutProtocol.slice(pathIndex);

      if (urlPrefix !== '') {
        urlPrefix = urlPrefix.replace(/\/$/, '');
      }
    }
  }

  _.forEach(_.get(parentElement, 'content'), function(element, index) {
    // There might be two types of elements—resource and
    // category. Categories are being mapped 1:1 to
    // sections (resource groups), resources are being
    // pushed to a temporary array and then assigned to
    // an artificial section.
    if (element.element === 'resource') {
      resourcesWithoutGroup = resourcesWithoutGroup.concat(
        transformResource(element, urlPrefix, options)
      );
    }

    if (element.element === 'category') {
      // First let's create an artificial resource group (section)
      // for resources without a group.
      if (resourcesWithoutGroup.length) {
        resourceGroups.push(new blueprintApi.Section({
          name: '',
          resources: resourcesWithoutGroup
        }));

        // Resources have been added to a group, reset.
        resourcesWithoutGroup = [];
      }

      const description = getDescription(element, options);

      const classes = _.get(element, 'meta.classes', []);
      if ((classes.length === 0) || (classes.indexOf('resourceGroup') !== -1)) {
        // Then create a new section in the Application AST
        // corresponding to the Category element.
        const resourceGroup = new blueprintApi.Section({
          name: _.chain(element).get('meta.title', '').contentOrValue().value(),
          description: description.raw,
          htmlDescription: description.html,
          resources: transformResources(element, urlPrefix, options)
        });

        return resourceGroups.push(resourceGroup);
      }
    }
  });

  // Make sure tu flush the resources into an an artificial
  // resource group (section).
  if (resourcesWithoutGroup.length) {
    resourceGroups.push(
      new blueprintApi.Section({
        name: '',
        resources: resourcesWithoutGroup
      })
    );
  }

  return resourceGroups;
};
