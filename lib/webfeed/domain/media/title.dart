import 'package:xml/xml.dart';

class Title {
  final String type;
  final String value;

  Title({
    this.type,
    this.value,
  });

  factory Title.parse(XmlElement element) {
    if (element == null) {
      return null;
    }
    return new Title(
      type: element.getAttribute("type"),
      value: element.text,
    );
  }
}
