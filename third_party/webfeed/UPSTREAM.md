# Upstream provenance

- Repository: https://github.com/tsacdop/webfeed
- Upstream project: https://github.com/witochandra/webfeed
- Commit: `fb613f8ecfbaf38a1b78db291079e8b94eddd396`
- Imported: 2026-08-23

## Local changes

- Supports Dart 3.13 and `xml` 7.
- Replaces the removed global XML `parse()` helper with
  `XmlDocument.parse()`.
- Replaces deprecated XML node text access with `innerText` and routes parse
  diagnostics through `dart:developer` logging.
