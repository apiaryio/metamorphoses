# Metamorphoses

*In nova fert animus mutatas dicere formas / corpora;*

Transforms *API Blueprint AST* or *legacy Apiary Blueprint AST* into *Apiary Application AST*.

## Use

**Do not use this library. You do not need it.**

Really! We needed to create it for internal use within [Apiary](https://apiary.io/), but it is going to be deprecated and removed even internally as soon as we fully migrate to [API Description Parse Result Namespace](https://github.com/refractproject/refract-spec/blob/master/namespaces/parse-result.md).

You ended up here for some reason though:

- Looking for [API Blueprint spec](https://github.com/apiaryio/api-blueprint/)?
- Looking for [Apiary](https://apiary.io/)?
- Looking for [API Blueprint parser](https://github.com/apiaryio/drafter)?
- Looking for [API Description SDK](https://github.com/apiaryio/fury.js)?
- Just being curious? Well, there are probably better things to do. Have you already read today's [featured article on Wikipedia](https://en.wikipedia.org/wiki/Main_Page)?

## Purpose

Apiary supports two API description formats as of now:

#### API Blueprint - `text/vnd.apiblueprint`

-   **Status:** recommended, heavily used and under active development
-   **Parser:** [Drafter](https://github.com/apiaryio/drafter)
-   **Parser Output:** [API Blueprint AST](https://github.com/apiaryio/api-blueprint-ast) - `application/vnd.apiblueprint.ast.raw+json` or `+yaml`

#### legacy Apiary Blueprint - `text/vnd.legacyblueprint`

-   **Status:** deprecated and supported only for backward compatibility
-   **Parser:** PEG.js-based [blueprint-parser](https://github.com/apiaryio/blueprint-parser)
-   **Parser Output:** legacy Apiary Blueprint AST - `application/vnd.legacyblueprint.ast+json`

To be able to work with both of these formats through some sort of uniform interface, *Apiary* internally transforms ASTs to a so-called *Application AST*. The Metamorphoses library does exactly this job, i.e. transforms any AST to the internal *Apiary Application AST*.

> **Note:** The information above is *simplified* for the context of the Metamorphoses library. As noted in the introduction, API Blueprint AST is about to be slowly replaced by [API Description Parse Result Namespace](https://github.com/refractproject/refract-spec/blob/master/namespaces/parse-result.md) as the parser output. Once [Fury](https://github.com/apiaryio/fury.js) has adapters to both *API Blueprint* and the *legacy Apiary Blueprint*, producing *API Description Parse Result Namespace* for both, and once *Apiary* starts to use the *API Description Parse Result Namespace* exclusively, this library becomes redundant.

## Interface

```javascript
var metamorphoses = require('metamorphoses');


// Blueprint source
var source = '# Sample API...';


// Select adapter by mime type:
// -   API Blueprint AST: 'application/vnd.apiblueprint.ast'
// -   Legacy Apiary Blueprint AST: 'application/vnd.legacyblueprint.ast'
var mimeType = 'application/vnd.apiblueprint.ast';
var adapter = metamorphoses.createAdapter(mimeType);


// You can also import the adapter directly:
// -   API Blueprint AST: apiBlueprintAdapter
// -   Legacy Apiary Blueprint AST: apiaryBlueprintAdapter
var adapter = metamorphoses.apiBlueprintAdapter;


parse(source, ..., function (err, result) {

  // transform the error object
  var err = adapter.transformError(source, err);
  console.log(err); // transformed error object

  // transform the AST
  var ast = adapter.transformAst(result.ast);
  console.log(ast); // transformed AST (application AST)
  console.log(result.warnings); // parser warnings
  ...

});
```

## Name

[Wikipedia](https://en.wikipedia.org/wiki/Metamorphoses): The Metamorphoses (Latin: *Metamorphōseōn librī*: "Books of Transformations") is a Latin narrative poem by the Roman poet Ovid.
