import 'package:xml/xml.dart';

class Credit {
  final String role;
  final String scheme;
  final String value;

  Credit({
    this.role,
    this.scheme,
    this.value,
  });

  factory Credit.parse(XmlElement element) {
    return new Credit(
      role: element.getAttribute("role"),
      scheme: element.getAttribute("scheme"),
      value: element.text,
    );
  }
}
