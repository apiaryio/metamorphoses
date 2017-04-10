# Metamorphoses Changelog

## 0.13.8

### Enhancements

- `headers1A` property added to the Request / Response transaction pairs for both API Blueprint and Refract adapters.

## 0.13.7

### Bug Fixes

- Fixes the duplication of metadata in refract adapter during certain cases.

- Fixes the parameter type to be enum in refract adapter to align with the AST adapter.

## 0.13.6

### Bug Fixes

- Fixes a problem in refract adapter when there's more than 1 choice for a particular parameter

## 0.13.5

### Enhancements

- Metamorphoses Refract adapter will use the title of an href variable as the
  type if available.
  [api-elements#20](https://github.com/apiaryio/api-elements/pull/20)

## 0.13.4

### Bug Fixes

- Fixes a crash in refract adapter when parameters have no default value

## 0.13.3

### Bug Fixes

- Fixes the format of an empty request in refract adapter when no requests are given.

## 0.13.2

### Enhancements

- Remove duplicate requests and responses from a transaction example in refract adapter. This works even in the case
  where the API Blueprint contains 2 continous transaction examples with the same request

### Bug Fixes

- Refract adapter's `transformAst` now returns `null` if no element is given as input'
- Fixed HOST url prefix handling in refract adapter
- Fixed a crash in refract adapter when parameters have no example values

## 0.13.1

### Bug Fixes

- Fixes Refract adapters `transformError` to handle errors which do not contain
  a source map.

## 0.13.0

## Breaking

- `transformError` now accepts a parse result.

- Removes support for Apiary Blueprint AST. [Fury Apiary Blueprint
  Parser](https://github.com/apiaryio/fury-adapter-apiary-blueprint-parser) can
  be used in conjunction with the API Elements adapter in Metamorphoses.

## 0.12.3

### Bug Fixes

- Fixed the behaviour of resource.parameters in Refract adapter when no action parameters are present

## 0.12.2

### BREAKING

- Removed robotskirt option

### Enhancements

- Streamlined the trimming of newlines in all descriptions just to trim one newline character
- Added resourceUriTemplate

### Bug Fixes

- Action name and Resource name are now completely trimmed in Refract adapter to be consistent with APIB AST adapter.
- Do not add resource to Apiary AST if no transition exists for that resource in Refract adapter.
- Provide actionAttributes in Refract adapter just like the API Blueprint AST
- Prevent wrapping parameter values in dictionaries inside the values list in
  the Refract Adapter. This aligns the behaviour with the API Blueprint
  adapter.
- A parameter is optional by default when there are no type attributes in the Refract Adapter.
- Set the action uri template to the actual uri template for an action instead
  of the resource in the API Blueprint Adapter.
- Expose the transition's href as the action uri template in the
  Refract Adapter.

## 0.9.1

### Bug Fixes

- Various improvements to the Refract adapter in order to align it with the
  existing API Blueprint and Apiary Blueprint adapters.

  - Data Structures are now provided for Refract source.
  - Trailing new lines are trimmed in titles and descriptions like the API
    Blueprint adapter.
  - The HOST metadata is translated to the ASTs location and is now
    removed from the ASTs metadata section.
  - Transition URLs and Resource URLs will now prepend the HOST path,
    similiarry to API Blueprint and Apiary Blueprint adapters.

# Unstable

## 0.12.1

### Bug Fixes

- Allows usage of NodeJS higher then 0.10
