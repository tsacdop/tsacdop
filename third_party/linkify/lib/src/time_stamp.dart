import 'package:linkify/linkify.dart';

final _timeStampRegex = RegExp(
  r'^((?:.|\n)*?)(([0-9]?[0-9]:)?[0-6]?[0-9]:[0-6][0-9])',
  caseSensitive: false,
);

class TimeStampLinkifier extends Linkifier {
  const TimeStampLinkifier();

  @override
  List<LinkifyElement> parse(
    List<LinkifyElement> elements,
    LinkifyOptions options,
  ) {
    final list = <LinkifyElement>[];

    for (final element in elements) {
      if (element is! TextElement) {
        list.add(element);
        continue;
      }

      final match = _timeStampRegex.firstMatch(element.text);
      if (match == null) {
        list.add(element);
        continue;
      }

      final remainingText = element.text.replaceFirst(match.group(0)!, '');
      final precedingText = match.group(1)!;
      final timeStamp = match.group(2)!;

      if (precedingText.isNotEmpty) {
        list.add(TextElement(precedingText));
      }
      list.add(TimeStampElement(timeStamp));
      if (remainingText.isNotEmpty) {
        list.addAll(parse([TextElement(remainingText)], options));
      }
    }

    return list;
  }
}

/// Represents a time stamp such as `01:23` or `1:02:03`.
class TimeStampElement extends LinkableElement {
  final String timeStamp;

  TimeStampElement(this.timeStamp) : super(timeStamp, timeStamp);

  @override
  String toString() => "TimeStampElement: '$timeStamp' ($text)";

  @override
  bool equals(Object? other) =>
      other is TimeStampElement &&
      super.equals(other) &&
      other.timeStamp == timeStamp;

  @override
  bool operator ==(Object other) => equals(other);

  @override
  int get hashCode => Object.hash(super.hashCode, timeStamp);
}
