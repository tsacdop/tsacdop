import 'package:linkify/linkify.dart';

final _phoneNumberRegex = RegExp(
  r'^(.*?)((tel:)?[+]*[\s/0-9]{8,15})',
  caseSensitive: false,
  dotAll: true,
);

class PhoneNumberLinkifier extends Linkifier {
  const PhoneNumberLinkifier();

  @override
  List<LinkifyElement> parse(elements, options) {
    final list = <LinkifyElement>[];

    for (var element in elements) {
      if (element is TextElement) {
        var match = _phoneNumberRegex.firstMatch(element.text);

        if (match == null) {
          list.add(element);
        } else {
          final text = element.text.replaceFirst(match.group(0)!, '');

          if (match.group(1)?.isNotEmpty == true) {
            list.add(TextElement(match.group(1)!));
          }

          if (match.group(2)?.isNotEmpty == true) {
            list.add(
              PhoneNumberElement(
                match.group(2)!.replaceFirst(RegExp(r'tel:'), ''),
              ),
            );
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

/// Represents an element containing a phone number
class PhoneNumberElement extends LinkableElement {
  final String phoneNumber;

  PhoneNumberElement(this.phoneNumber) : super(phoneNumber, 'tel:$phoneNumber');

  @override
  String toString() {
    return "PhoneNumberElement: '$phoneNumber' ($text)";
  }

  @override
  bool operator ==(other) => equals(other);

  @override
  int get hashCode => Object.hash(text, originText, url, phoneNumber);

  @override
  bool equals(other) =>
      other is PhoneNumberElement && phoneNumber == other.phoneNumber;
}
