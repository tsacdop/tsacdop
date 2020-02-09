import 'package:xml/xml.dart';

class Restriction {
  final String relationship;
  final String type;
  final String value;

  Restriction({
    this.relationship,
    this.type,
    this.value,
  });

  factory Restriction.parse(XmlElement element) {
    if (element == null) {
      return null;
    }
    return new Restriction(
      relationship: element.getAttribute("relationship"),
      type: element.getAttribute("type"),
      value: element.text,
    );
  }
}
