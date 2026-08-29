import 'package:xml/xml.dart';

class Param {
  final String? name;
  final String? value;

  Param({this.name, this.value});

  static Param? parse(XmlElement? element) {
    if (element == null) {
      return null;
    }
    return Param(name: element.getAttribute("name"), value: element.innerText);
  }
}
