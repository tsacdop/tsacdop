import 'package:linkify/src/email.dart';
import 'package:linkify/src/time_stamp.dart';
import 'package:linkify/src/url.dart';

export 'package:linkify/src/email.dart' show EmailLinkifier, EmailElement;
export 'package:linkify/src/url.dart' show UrlLinkifier, UrlElement;
export 'package:linkify/src/user_tag.dart'
    show UserTagLinkifier, UserTagElement;
export 'package:linkify/src/phone_number.dart'
    show PhoneNumberLinkifier, PhoneNumberElement;
export 'package:linkify/src/time_stamp.dart'
    show TimeStampLinkifier, TimeStampElement;

abstract class LinkifyElement {
  final String text;
  final String originText;

  LinkifyElement(this.text, [String? originText])
    : originText = originText ?? text;

  @override
  bool operator ==(Object other) => equals(other);

  @override
  int get hashCode => Object.hash(text, originText);

  bool equals(Object? other) => other is LinkifyElement && other.text == text;
}

class LinkableElement extends LinkifyElement {
  final String url;

  LinkableElement(String? text, this.url, [String? originText])
    : super(text ?? url, originText);

  @override
  bool operator ==(Object other) => equals(other);

  @override
  int get hashCode => Object.hash(text, originText, url);

  @override
  bool equals(Object? other) =>
      other is LinkableElement && super.equals(other) && other.url == url;
}

/// Represents an element containing text
class TextElement extends LinkifyElement {
  TextElement(super.text);

  @override
  String toString() {
    return "TextElement: '$text'";
  }

  @override
  bool operator ==(Object other) => equals(other);

  @override
  int get hashCode => Object.hash(text, originText);

  @override
  bool equals(Object? other) => other is TextElement && super.equals(other);
}

abstract class Linkifier {
  const Linkifier();

  List<LinkifyElement> parse(
    List<LinkifyElement> elements,
    LinkifyOptions options,
  );
}

class LinkifyOptions {
  /// Removes http/https from shown URLs.
  final bool humanize;

  /// Removes www. from shown URLs.
  final bool removeWww;

  /// Enables loose URL parsing (any string with "." is a URL).
  final bool looseUrl;

  /// When used with [looseUrl], default to `https` instead of `http`.
  final bool defaultToHttps;

  /// Excludes `.` at end of URLs.
  final bool excludeLastPeriod;

  const LinkifyOptions({
    this.humanize = true,
    this.removeWww = false,
    this.looseUrl = false,
    this.defaultToHttps = false,
    this.excludeLastPeriod = true,
  });
}

const _urlLinkifier = UrlLinkifier();
const _emailLinkifier = EmailLinkifier();
const _timeStampLinkifier = TimeStampLinkifier();
const defaultLinkifiers = [_urlLinkifier, _emailLinkifier, _timeStampLinkifier];

/// Turns [text] into a list of [LinkifyElement]
///
/// Use [humanize] to remove http/https from the start of the URL shown.
/// Will default to `false` (if `null`)
///
/// Uses [linkTypes] to enable some types of links (URL, email).
/// Will default to all (if `null`).
List<LinkifyElement> linkify(
  String text, {
  LinkifyOptions options = const LinkifyOptions(),
  List<Linkifier> linkifiers = defaultLinkifiers,
}) {
  var list = <LinkifyElement>[TextElement(text)];

  if (text.isEmpty) {
    return [];
  }

  if (linkifiers.isEmpty) {
    return list;
  }

  for (var linkifier in linkifiers) {
    list = linkifier.parse(list, options);
  }

  return list;
}
