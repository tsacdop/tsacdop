# Upstream provenance

- Repository: https://github.com/Baseflow/flutter-permission-handler
- Package: `permission_handler_android`
- Commit: `5c989b1be9abbbb325424ad96e5be4efdc0987c2`
- Imported: 2026-08-23

## Local changes

- Declares Android API 37.0 explicitly through `compileSdkMinor`.
- Uses Android Gradle Plugin 9.3.1 and Java 17.
- Removes the unused Kotlin Gradle plugin from this Java-only package.
- Removes the monorepo-only pub workspace resolution and aligns SDK constraints
  with this application.
