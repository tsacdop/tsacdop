# Upstream provenance

- Repository: https://github.com/2d-inc/Flare-Flutter
- Package: `flare_flutter`
- Commit: `3c3146429418eaae09b20704a48754f7b5b53e82`
- Imported: 2026-08-23

## Local changes

- Supports Dart 3.13 and Flutter 3.47.
- Replaces the removed Flutter `hashValues()` helper with `Object.hash()`.
- Marks the legacy classes used with `with` as Dart 3 `abstract mixin class`
  declarations.
- Updates RenderObject disposal, callback, equality, and exhaustive switch code
  for current Flutter and Dart analyzer contracts.
- Removes legacy manual render-object disposal during widget unmount and
  detach; current Flutter owns disposal, and the old lifecycle caused a
  double-dispose assertion.
- Migrates deprecated color component access to normalized `r`, `g`, and `b`
  values.
