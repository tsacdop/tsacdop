# `linkify` [![pub package](https://img.shields.io/pub/v/linkify.svg)](https://pub.dartlang.org/packages/linkify)

Low-level link (text, URLs, emails, phone numbers, user tags) parsing library in Dart.

Required Dart >=2.12 (has null-safety support).

[Flutter library](https://github.com/Cretezy/flutter_linkify).

[Pub](https://pub.dartlang.org/packages/linkify) - [API Docs](https://pub.dartlang.org/documentation/linkify/latest/) - [GitHub](https://github.com/Cretezy/linkify)

## Install

Install by adding this package to your `pubspec.yaml`:

```yaml
dependencies:
  linkify: ^5.0.0
```

## Usage

```dart
import 'package:linkify/linkify.dart';

linkify("Made by https://cretezy.com person@example.com");
// Output: [TextElement: 'Made by ', UrlElement: 'https://cretezy.com' (cretezy.com), TextElement: ' ', EmailElement: 'person@example.com' (person@example.com)]
```

### Options

You can pass `LinkifyOptions` to the `linkify` method to change the humanization of URLs (turning `https://example.com` to `example.com`):

```dart
linkify("https://cretezy.com");
// [UrlElement: 'https://cretezy.com' (cretezy.com)]

linkify("https://cretezy.com", options: LinkifyOptions(humanize: false));
// [UrlElement: 'https://cretezy.com' (https://cretezy.com)]
```

- `humanize`: Removes http/https from shown URLs
- `removeWww`: Removes `www.` from shown URLs
- `looseUrl`: Enables loose URL parsing (should parse most URLs such as `abc.com/xyz`)
  - `defaultToHttps`: When used with [looseUrl], default to `https` instead of `http`
- `excludeLastPeriod`: Excludes `.` at end of URLs

### Linkifiers

You can pass linkifiers to `linkify` as such:

```dart
linkify("@cretezy", linkifiers: [UserTagLinkifier()]);
```

Available linkifiers:

- `EmailLinkifier`
- `UrlLinkifier`
- `PhoneNumberLinkifier`
- `UserTagLinkifier`

## Custom Linkifier

You can write custom linkifiers for phone numbers or other types of links. Look at the [URL linkifier](./lib/src/url.dart) for an example.

This is the flow:

- Calls `parse` in the linkifier with a list of `LinkifyElement`. This starts as `[TextElement(text)]`
- Your parsers then splits each element into it's parts. For example, `[TextElement("Hello https://example.com")]` would become `[TextElement("Hello "), UrlElement("https://example.com")]`
- Each parsers is ran in order of how they are passed to the main `linkify` function. By default, this is URL and email linkifiers
