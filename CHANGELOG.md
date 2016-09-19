# Metamorphoses Changelog

# Master

### Enhancements

- Streamlined the trimming of newlines in all descriptions just to trim one newline character

### Bug Fixes

- Action name and Resource name are now completely trimmed in Refract adapter to be consistent with APIB AST adapter.
- Do not add resource to Apiary AST if no transition exists for that resource in Refract adapter.

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
