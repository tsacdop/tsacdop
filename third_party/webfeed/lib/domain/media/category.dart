import 'package:xml/xml.dart';

class Category {
  final String? scheme;
  final String? label;
  final String? value;

  Category({this.scheme, this.label, this.value});

  static Category? parse(XmlElement? element) {
    if (element == null) {
      return null;
    }
    return Category(
      scheme: element.getAttribute("scheme"),
      label: element.getAttribute("label"),
      value: element.innerText,
    );
  }
}
