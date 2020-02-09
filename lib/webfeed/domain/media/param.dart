import 'package:xml/xml.dart';

class Param {
  final String name;
  final String value;

  Param({
    this.name,
    this.value,
  });

  factory Param.parse(XmlElement element) {
    if (element == null) {
      return null;
    }
    return new Param(
      name: element.getAttribute("name"),
      value: element.text,
    );
  }
}
