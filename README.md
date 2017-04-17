# Metamorphoses

*In nova fert animus mutatas dicere formas / corpora;*

Transforms *API Blueprint AST* or *Refract API Description Namespace* into *Apiary Application AST*.

## Use

**Do not use this library. You do not need it.**

Really! We needed to create it for internal use within [Apiary](https://apiary.io/), but it is going to be deprecated and removed even internally as soon as we fully migrate to [API Description Parse Result Namespace](https://github.com/refractproject/refract-spec/blob/master/namespaces/parse-result-namespace.md).

You ended up here for some reason though:

- Looking for [API Blueprint spec](https://github.com/apiaryio/api-blueprint/)?
- Looking for [API Elements](http://api-elements.readthedocs.io/en/latest/)
- Looking for [Apiary](https://apiary.io/)?
- Looking for [API Blueprint parser](https://github.com/apiaryio/drafter)?
- Looking for [API Description SDK](https://github.com/apiaryio/fury.js)?
- Just being curious? Well, there are probably better things to do. Have you already read today's [featured article on Wikipedia](https://en.wikipedia.org/wiki/Main_Page)?

## Purpose

Apiary supports three API description formats as of now:

#### API Blueprint - `text/vnd.apiblueprint`

-   **Status:** recommended, heavily used and under active development
-   **Parser:** [Drafter](https://github.com/apiaryio/drafter)
-   **Parser Outputs:**
    - [API Blueprint AST](https://github.com/apiaryio/api-blueprint-ast) - `application/vnd.apiblueprint.ast+json` or `+yaml`
    - [API Elements](http://api-elements.readthedocs.io/en/latest/) - `application/vnd.refract.parse-result+json` or `+yaml`

#### Swagger - `application/swagger+json` or `+yaml`

-   **Parser:** [fury-adapter-swagger](https://github.com/apiaryio/fury-adapter-swagger)
-   **Parser Outputs:**
    - [API Elements](http://api-elements.readthedocs.io/en/latest/) - `application/vnd.refract.parse-result+json` or `+yaml`

To be able to work with both of these formats through some sort of uniform interface, *Apiary* internally transforms ASTs to a so-called *Application AST*. The Metamorphoses library does exactly this job, i.e. transforms any AST to the internal *Apiary Application AST*.

> **Note:** The information above is *simplified* for the context of the Metamorphoses library. As noted in the introduction, API Blueprint AST is about to be slowly replaced by [API Description Parse Result Namespace](https://github.com/refractproject/refract-spec/blob/master/namespaces/api-description-namespace.md) as the parser output. Once [Fury](https://github.com/apiaryio/fury.js) has adapters to both *API Blueprint* and the *legacy Apiary Blueprint*, producing *API Description Parse Result Namespace* for both, and once *Apiary* starts to use the *API Description API Description Namespace* exclusively, this library becomes redundant.

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
var adapter = metamorphoses.apiBlueprintAdapter;


// Pseudo-code parse function. It is a placeholder for parser
// interface of either Drafter (https://github.com/apiaryio/drafter)
// or the legacy Blueprint Parser (https://github.com/apiaryio/blueprint-parser)
parse(source, ..., function (err, result) {

  // transform the error parse result into an error
  var err = adapter.transformError(source, parseResult);
  console.log(err); // transformed error object

  // transform the AST
  var ast = adapter.transformAst(result.ast);
  console.log(ast); // transformed AST (application AST)
  console.log(result.warnings); // parser warnings
  ...

});


// Blueprint API (Application AST)
metamorphoses.blueprintApi.Blueprint.fromJSON({
  ...
});
```

### `transformError`

Transforming an error accepts the source API Description Document and the
resultant parse result. The method returns an error if there was an error in
the parse result, the error will be a JSON object as follows:

- message - Error message
- code - Error code
- location (array) - Error source map
    - (object)
        - index (number)
        - length (number)
- line - The line producing the error from the source API Description Document derived from the source map

## Interface

```javascript
metamorphoses = require('metamorphoses');

// Turning API Blueprint AST into the Apiary Application AST
var apiBlueprintAst = {...};
applicationAst = metamorphoses.transform(apiBlueprintAst, 'application/vnd.apiblueprint.ast');

// Turning legacy Apiary Blueprint AST into the Apiary Application AST
var apiaryBlueprintAst = {...};
applicationAst = metamorphoses.transform(apiaryBlueprintAst, 'application/vnd.legacyblueprint.ast');
```

## Name

[Wikipedia](https://en.wikipedia.org/wiki/Metamorphoses): The Metamorphoses (Latin: *Metamorphōseōn librī*: "Books of Transformations") is a Latin narrative poem by the Roman poet Ovid.
