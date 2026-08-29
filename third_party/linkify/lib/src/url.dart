import 'package:linkify/linkify.dart';

final _urlRegex = RegExp(
  r'^(.*?)((?:https?:\/\/|www\.)[^\s/$.?#].[^\s]*)',
  caseSensitive: false,
  dotAll: true,
);

final _looseUrlRegex = RegExp(
  r'''^(.*?)((https?:\/\/)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,4}\b([-a-zA-Z0-9@:%_\+.~#?&//="'`]*))''',
  caseSensitive: false,
  dotAll: true,
);

final _protocolIdentifierRegex = RegExp(
  r'^(https?:\/\/)',
  caseSensitive: false,
);

class UrlLinkifier extends Linkifier {
  const UrlLinkifier();

  @override
  List<LinkifyElement> parse(elements, options) {
    final list = <LinkifyElement>[];

    for (var element in elements) {
      if (element is TextElement) {
        var match = options.looseUrl
            ? _looseUrlRegex.firstMatch(element.text)
            : _urlRegex.firstMatch(element.text);

        if (match == null) {
          list.add(element);
        } else {
          final text = element.text.replaceFirst(match.group(0)!, '');

          if (match.group(1)?.isNotEmpty == true) {
            list.add(TextElement(match.group(1)!));
          }

          if (match.group(2)?.isNotEmpty == true) {
            var originalUrl = match.group(2)!;
            var originText = originalUrl;
            String? end;

            if ((options.excludeLastPeriod) &&
                originalUrl[originalUrl.length - 1] == ".") {
              end = ".";
              originText = originText.substring(0, originText.length - 1);
              originalUrl = originalUrl.substring(0, originalUrl.length - 1);
            }

            var url = originalUrl;

            if (!originalUrl.startsWith(_protocolIdentifierRegex)) {
              originalUrl =
                  (options.defaultToHttps ? "https://" : "http://") +
                  originalUrl;
            }

            if ((options.humanize) || (options.removeWww)) {
              if (options.humanize) {
                url = url.replaceFirst(RegExp(r'https?://'), '');
              }
              if (options.removeWww) {
                url = url.replaceFirst(RegExp(r'www\.'), '');
              }

              list.add(UrlElement(originalUrl, url, originText));
            } else {
              list.add(UrlElement(originalUrl, null, originText));
            }

            if (end != null) {
              list.add(TextElement(end));
            }
          }

          if (text.isNotEmpty) {
            list.addAll(parse([TextElement(text)], options));
          }
        }
      } else {
        list.add(element);
      }
    }

    return list;
  }
}

/// Represents an element containing a link
class UrlElement extends LinkableElement {
  UrlElement(String url, [String? text, String? originText])
    : super(text, url, originText);

  @override
  String toString() {
    return "LinkElement: '$url' ($text)";
  }

  @override
  bool operator ==(other) => equals(other);

  @override
  int get hashCode => Object.hash(text, originText, url);

  @override
  bool equals(other) => other is UrlElement && super.equals(other);
}
