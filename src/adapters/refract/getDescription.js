const _ = require('./helper');
const markdown = require('../markdown');

module.exports = function(element, options) {
  const copyElement = _(element).copy().first();

  const raw = _.trimLastNewline(_.content(copyElement) || '');
  const html = _.trimLastNewline(raw ? markdown.toHtmlSync(raw, options) : '');

  return {raw, html};
};
