# Metamorphoses Changelog

# Master

### Enhancements

- Streamlined the trimming of newlines in all descriptions just to trim one newline character

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
