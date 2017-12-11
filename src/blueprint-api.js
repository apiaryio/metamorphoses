/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// Current Application AST version
//
// Beware! Since November 2015 this version number isn't applied automatically
// to any Application AST which is created by metamorphoses. When transforming
// API Blueprint AST, certain older ASTs get fixed to 18. See
// api-blueprint-adapter.coffee for details.
const CURRENT_AST_VERSION = 19;

const fillProps = (object, props, defaults) =>
  (() => {
    const result = [];
    for (let key in defaults) {
      result.push(object[key] = props[key] != null ? props[key] : defaults[key]);
    }
    return result;
  })()
;

const combineParts = function(separator, builder) {
  const parts = [];
  builder(parts);
  return parts.join(separator);
};

const escapeBody = function(body) {
  if (/^>\s+|^<\s+|^\s*$/m.test(body)) {
    if (/^>>>\s*$/m.test(body)) {
      if (/^EOT$/m.test(body)) {
        let i = 1;
        while (/^EOT#{i}$/m.test(body)) {
          i++;
        }
        return `<<<EOT${i}\n${body}\nEOT${i}`;
      } else {
        return `<<<EOT\n${body}\nEOT`;
      }
    } else {
      return `<<<\n${body}\n>>>`;
    }
  } else {
    return body;
  }
};


class Blueprint {
  static fromJSON(json) {
    if (json == null) { json = {}; }
    return new (this)({
      location: json.location, // `HOST` metadata
      name: json.name, // Name of the API
      metadata: json.metadata, // Array of metadata, e.g. `[ { value: '1A', name: 'FORMAT' } ]`
      version: json.version, // Proprietary version of the Application AST (e.g. 17), see http://git.io/bbDJ
      description: json.description, // Description of the API (in Markdown)
      htmlDescription: json.htmlDescription, // Rendered description of the API
      authDefinitions: json.authDefinitions,
      sections: Array.from(json.sections || []).map((s) => Section.fromJSON(s)), // Array of resource groups
      validations: Array.from(json.validations || []).map((v) => JsonSchemaValidation.fromJSON(v)), // Array of JSON Schemas
      dataStructures: json.dataStructures // Array of data struture elements
    });
  }

  constructor(props) {
    if (props == null) { props = {}; }
    fillProps(this, props, {
      location: null,
      name: null,
      metadata: null,
      version: 1.0,
      description: null,
      htmlDescription: null,
      authDefinitions: [],
      sections: [],
      validations: [],
      dataStructures: []
    }
    );
  }

  // ### `resources`
  //
  // Returns a list of resources. You can filter the list
  // by the `opts` object.
  //
  // `resources method: 'GET'` returns resources
  // with `GET` HTTP method.
  //
  // `resources url: '/notes'` returns resources
  // with `/notes` URI template.
  resources(opts) {
    // Resource, see line #133 for more details.
    const resources = [];
    for (let s of Array.from(this.sections)) { for (let r of Array.from(s.resources)) {
      if ((opts != null ? opts.method : undefined) && (opts.method !== r.method)) { continue; }
      if ((opts != null ? opts.url : undefined) && (opts.url !== r.url)) { continue; }
      resources.push(r);
    } }
    return resources;
  }

  toJSON() {
    return {
      location: this.location,
      name: this.name,
      metadata: this.metadata,
      version: this.version,
      description: this.description,
      htmlDescription: this.htmlDescription,
      authDefinitions: this.authDefinitions,
      sections: Array.from(this.sections).map((s) => s.toJSON()),
      validations: Array.from(this.validations).map((v) => v.toJSON()),
      dataStructures: this.dataStructures
    };
  }

  // ### `toBlueprint`
  //
  // Turns the AST into a blueprint. Outputs
  // Legacy Blueprint Format.
  toBlueprint() {
    return combineParts("\n\n", parts => {
      if (this.location) { parts.push(`HOST: ${this.location}`); }
      if (this.name) { parts.push(`--- ${this.name} ---`); }
      if (this.description) { parts.push(`---\n${`${this.description}`.trim()}\n---`); }

      for (let s of Array.from(this.sections)) { parts.push(s.toBlueprint()); }

      if (this.validations.length > 0) { parts.push("-- JSON Schema Validations --"); }
      return Array.from(this.validations).map((v) => parts.push(v.toBlueprint()));
    });
  }
}

// ## `Section`
//
// Resource Group.
class Section {
  static fromJSON(json) {
    if (json == null) { json = {}; }
    return new (this)({
      name: json.name, // Name of the resource group
      description: json.description, // Markdown description of the resource group
      htmlDescription: json.htmlDescription, // Rendered description of the resource group
      resources: Array.from(json.resources || []).map((r) => Resource.fromJSON(r)) // Array of resources
    });
  }

  constructor(props) {
    if (props == null) { props = {}; }
    fillProps(this, props, {
      name: null,
      description: null,
      htmlDescription: null,
      resources: []
    }
    );
  }

  toJSON() { return {
    name: this.name,
    description: this.description,
    htmlDescription: this.htmlDescription,
    resources: Array.from(this.resources || []).map((r) => r.toJSON())
  }; }

  // ### `toBlueprint`
  //
  // Turns the AST into a blueprint. Outputs
  // Legacy Blueprint Format.
  toBlueprint() {
    return combineParts("\n\n", parts => {
      if (this.name) {
        if (this.description) {
          parts.push(`--\n${this.name}\n${`${this.description}`.trim()}\n--`);
        } else {
          parts.push(`-- ${this.name} --`);
        }
      }

      return Array.from(this.resources || []).map((r) => parts.push(`${r.toBlueprint()}\n`));
    });
  }
}


// ## `Resource`
//
// Represents an action (transition), inherits properties from a resource (e.g. `uriTemplate`,
// `headers`, `name`, ...).
class Resource {
  static fromJSON(json) {
    let r;
    if (json == null) { json = {}; }
    return new (this)({
      method: json.method, // HTTP method of the action

      // URI of the resource including path from the `HOST` metadata.
      // E.g. `/v2/notes`, where `/v2` is path from the `HOST` metadata,
      // `/notes` is URI template of the resource.
      url: json.url,

      uriTemplate: json.uriTemplate, // URI template of the resoruce
      name: json.name, // Name of the resource
      nameMethod: json.nameMethod, // Deprecated, use `actionName`
      actionName: json.actionName, // Name of the action
      actionDescription: json.actionDescription, // Markdown description of the action
      actionHtmlDescription: json.actionHtmlDescription, // Rendered description of the action
      description: json.description, // Markdown description of the resource
      htmlDescription: json.htmlDescription, // Rendered description of the resource
      descriptionMethod: json.descriptionMethod, // Deprecated, use `htmlDescription`
      resourceDescription: json.resourceDescription, // Deprecated, use `htmlDescription`
      model: json.model, // Resource model
      headers: json.headers, // Resource and action headers
      actionHeaders: json.actionHeaders, // Action headers
      parameters: json.parameters, // Resource and action URI parameters
      resourceParameters: json.resourceParameters, // Resource URI parameters
      actionParameters: json.actionParameters, // Action URI parameters
      request: json.request ? Request.fromJSON(json.request) : json.request, // First request in the `request` array
      requests: (() => {
        const result = [];
        for (r of Array.from(json.requests || [])) {           result.push(Request.fromJSON(r));
        }
        return result;
      })(), // Array of requests
      responses: (() => {
        const result1 = [];
        for (r of Array.from(json.responses || [])) {           result1.push(Response.fromJSON(r));
        }
        return result1;
      })(), // Array of responses
      attributes: json.attributes, // Resource attributes
      resolvedAttributes: json.resolvedAttributes, // Expanded resource attributes
      actionAttributes: json.actionAttributes, // Action attributes
      resolvedActionAttributes: json.resolvedActionAttributes, // Expanded action attributes
      actionRelation: json.actionRelation,
      actionUriTemplate: json.actionUriTemplate,
      resourceUriTemplate: json.resourceUriTemplate
    });
  }

  constructor(props) {
    if (props == null) { props = {}; }
    fillProps(this, props, {
      method: 'GET',
      url: '/',
      uriTemplate: '',
      name: undefined,
      nameMethod: undefined, // deprecated
      actionName: undefined,
      actionDescription: undefined,
      actionHtmlDescription: undefined,
      description: undefined,
      htmlDescription: undefined,
      descriptionMethod: undefined, // deprecated
      resourceDescription: undefined, // deprecated
      model: undefined,
      headers: undefined,
      actionHeaders: undefined,
      parameters: undefined,
      resourceParameters: undefined,
      actionParameters: undefined,
      request: undefined,
      requests: [],
      responses: [],
      attributes: undefined,
      resolvedAttributes: undefined,
      actionAttributes: undefined,
      resolvedActionAttributes: undefined,
      actionRelation: undefined,
      actionUriTemplate: undefined,
      resourceUriTemplate: ''
    }
    );
  }

  getUrlFragment() {
    return `${this.method.toLowerCase()}-${encodeURIComponent(this.url)}`;
  }

  // Returns array of "examples", each having 'requests' and 'responses'
  // properties containing arrays of corresponding items. The array is sorted
  // by exampleId, so "examples" should appear in the same order as they
  // were defined in the original blueprint.
  getExamples() {
    const ids = [];
    const examples = [];

    for (let name of ['requests', 'responses']) {
      for (let reqOrResp of Array.from(this[name] || [])) {
        const key = parseInt(reqOrResp.exampleId, 10) || 0;
        if ((examples[key] == null)) {
          examples[key] = {
            requests: [],
            responses: []
          };
        }
        examples[key][name].push(reqOrResp);
      }
    }

    return examples;
  }

  toJSON() { let r;   return {
    method: this.method,
    url: this.url,
    uriTemplate: this.uriTemplate,
    name: this.name,
    nameMethod: this.nameMethod, // deprecated
    actionName: this.actionName,
    actionDescription: this.actionDescription,
    actionHtmlDescription: this.actionHtmlDescription,
    description: this.description,
    htmlDescription: this.htmlDescription,
    descriptionMethod: this.descriptionMethod, // deprecated
    resourceDescription: this.resourceDescription, // deprecated
    model: this.model,
    headers: this.headers,
    actionHeaders: this.actionHeaders,
    parameters: this.parameters,
    resourceParameters: this.resourceParameters,
    actionParameters: this.actionParameters,
    request: (this.request != null ? this.request.toJSON() : undefined),
    requests: (() => {
      const result = [];
      for (r of Array.from(this.requests || [])) {         result.push(r.toJSON());
      }
      return result;
    })(),
    responses: (() => {
      const result1 = [];
      for (r of Array.from(this.responses || [])) {         result1.push(r.toJSON());
      }
      return result1;
    })(),
    attributes: this.attributes,
    resolvedAttributes: this.resolvedAttributes,
    actionAttributes: this.actionAttributes,
    resolvedActionAttributes: this.resolvedActionAttributes,
    actionRelation: this.actionRelation,
    actionUriTemplate: this.actionUriTemplate,
    resourceUriTemplate: this.resourceUriTemplate
  }; }

  // ### `toBlueprint`
  //
  // Turns the AST into a blueprint. Outputs
  // Legacy Blueprint Format.
  toBlueprint() {
    return combineParts("\n", parts => {
      if (this.description) { parts.push(`${this.description}`.trim()); }
      parts.push(`${this.method} ${this.uriTemplate}`);

      const requestBlueprint = this.request != null ? this.request.toBlueprint() : undefined;
      if (requestBlueprint) { parts.push(requestBlueprint); }

      const responsesBlueprint = combineParts("\n+++++\n", parts => {
        return Array.from(this.responses || []).map((r) => parts.push(r.toBlueprint()));
      });
      if (responsesBlueprint) { return parts.push(responsesBlueprint); }
    });
  }
}


class Request {
  static fromJSON(json) {
    if (json == null) { json = {}; }
    return new (this)({
      name: json.name, // Name of the request
      description: json.description, // Markdown description of the request
      htmlDescription: json.htmlDescription, // Rendered description of the request
      headers: json.headers,
      headers1A: json.headers1A,
      reference: json.reference,
      body: json.body,
      schema: json.schema,
      exampleId: json.exampleId,
      attributes: json.attributes, // Request attributes
      resolvedAttributes: json.resolvedAttributes, // Expanded request attributes
      authSchemes: json.authSchemes
    });
  }

  constructor(props) {
    if (props == null) { props = {}; }
    fillProps(this, props, {
      name: undefined,
      description: undefined,
      htmlDescription: undefined,
      headers: {},
      headers1A: [],
      reference: undefined,
      body: '',
      schema: '',
      exampleId: 0,
      attributes: undefined,
      resolvedAttributes: undefined,
      authSchemes: []
    }
    );
  }

  toJSON() { return {
    name: this.name,
    description: this.description,
    htmlDescription: this.htmlDescription,
    headers: this.headers,
    headers1A: this.headers1A,
    reference: this.reference,
    body: this.body,
    schema: this.schema,
    exampleId: this.exampleId,
    attributes: this.attributes,
    resolvedAttributes: this.resolvedAttributes,
    authSchemes: this.authSchemes
  }; }

  // ### `toBlueprint`
  //
  // Turns the AST into a blueprint. Outputs
  // Legacy Blueprint Format.
  toBlueprint() {
    return combineParts("\n", parts => {
      for (let name in this.headers) { const value = this.headers[name]; parts.push(`> ${name}: ${value}`); }
      if (this.body) { return parts.push(escapeBody(this.body)); }
    });
  }
}


class Response {
  static fromJSON(json) {
    if (json == null) { json = {}; }
    return new (this)({
      status: json.status,
      description: json.description,
      htmlDescription: json.htmlDescription,
      headers: json.headers,
      headers1A: json.headers1A,
      reference: json.reference,
      body: json.body,
      schema: json.schema,
      exampleId: json.exampleId,
      attributes: json.attributes,
      resolvedAttributes: json.resolvedAttributes
    });
  }

  constructor(props) {
    if (props == null) { props = {}; }
    fillProps(this, props, {
      status: 200,
      description: undefined,
      htmlDescription: undefined,
      headers: {},
      headers1A: [],
      reference: undefined,
      body: '',
      schema: '',
      exampleId: 0,
      attributes: undefined,
      resolvedAttributes: undefined
    }
    );
  }

  toJSON() { return {
    status: this.status,
    description: this.description,
    htmlDescription: this.htmlDescription,
    headers: this.headers,
    headers1A: this.headers1A,
    reference: this.reference,
    body: this.body,
    schema: this.schema,
    exampleId: this.exampleId,
    attributes: this.attributes,
    resolvedAttributes: this.resolvedAttributes
  }; }

  // ### `toBlueprint`
  //
  // Turns the AST into a blueprint. Outputs
  // Legacy Blueprint Format.
  toBlueprint() {
    return combineParts("\n", parts => {
      parts.push(`< ${this.status}`);
      for (let name in this.headers) { const value = this.headers[name]; parts.push(`< ${name}: ${value}`); }
      if (this.body) { return parts.push(escapeBody(this.body)); }
    });
  }
}


class JsonSchemaValidation {
  static fromJSON(json) {
    if (json == null) { json = {}; }
    return new (this)({
      status: json.status,
      method: json.method,
      url: json.url,
      body: json.body
    });
  }

  constructor(props) {
    if (props == null) { props = {}; }
    fillProps(this, props, {
      status: undefined,
      method: "GET",
      url: "/",
      body: undefined
    }
    );
  }

  toJSON() { return {
    status: this.status,
    method: this.method,
    url: this.url,
    body: this.body
  }; }

  // ### `toBlueprint`
  //
  // Turns the AST into a blueprint. Outputs
  // Legacy Blueprint Format.
  toBlueprint() {
    return combineParts("\n", parts => {
      parts.push(`${this.method} ${this.uriTemplate}`);
      if (this.body) { return parts.push(escapeBody(this.body)); }
    });
  }
}

class DataStructure {}


module.exports = {
  Blueprint,
  Section,
  Resource,
  Request,
  Response,
  Version: CURRENT_AST_VERSION
};
