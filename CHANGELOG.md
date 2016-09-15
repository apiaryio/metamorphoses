# Metamorphoses Changelog

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
