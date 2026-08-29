import 'package:xml/xml.dart';

class Title {
  final String? type;
  final String? value;

  Title({this.type, this.value});

  static Title? parse(XmlElement? element) {
    if (element == null) {
      return null;
    }
    return Title(type: element.getAttribute("type"), value: element.innerText);
  }
}
