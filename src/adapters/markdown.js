/*
 * decaffeinate suggestions:
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// This is our Markdown parser implementation

const {renderHtml} = require('blueprint-markdown-renderer');

const parseMarkdown = function(markdown, params, cb) {
  // do not mutate passed-in argument "params", create our own options
  const options = {
    sanitize: (params != null ? params.sanitize : undefined)
  };

  // sanitize is enabled by default
  if (options.sanitize == null) { options.sanitize = true; }

  let results = renderHtml(markdown, options);

  // Return <span> if the results are empty. This way other code
  // that renders knows this code has been parsed.
  if (results.trim() === '') {
    results = '<span></span>';
  }

  if (cb) {
    return cb(null, results);
  } else {
    return results;
  }
};


const toHtml = function(markdown, params, cb) {
  let options = {};
  // Allow for second arg to be the callback
  if (typeof params === 'function') {
    cb = params;
  } else {
    // do not mutate passed-in argument "params", create our own options
    options = {
      sanitize: (params != null ? params.sanitize : undefined)
    };
  }

  if (!cb) {
    return parseMarkdown(markdown, options);
  }

  if (!markdown) {
    return cb(null, '');
  }

  parseMarkdown(markdown, options, cb);
};


const toHtmlSync = function(markdown, params) {
  if (!markdown) {
    return '';
  }
  return parseMarkdown(markdown, params);
};

module.exports = {
  toHtml,
  toHtmlSync
};
