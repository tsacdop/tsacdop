# Upstream provenance

- Repository: https://github.com/alexmercerind/flutter_media_metadata
- Commit: `1c05ac616bfbc2dc88a8f82e2c0f9c9b8ac078b6`
- Retrieved: 2026-08-23

Local compatibility changes:

- Require Dart 3.13.2 and Flutter 3.47.2.
- Limit the plugin declaration to this application's Android and iOS targets.
- Add the Android namespace and migrate to AGP 9.3.1, SDK 37.0, Java 17, and API 24.
- Raise the iOS deployment target to 13.0.
- Handle the checked `IOException` raised by API 37 metadata retriever cleanup
  and report asynchronous extraction failures to Dart.
