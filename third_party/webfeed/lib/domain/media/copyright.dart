import 'package:xml/xml.dart';

class Copyright {
  final String? url;
  final String? value;

  Copyright({this.url, this.value});

  static Copyright? parse(XmlElement? element) {
    if (element == null) {
      return null;
    }
    return Copyright(
      url: element.getAttribute("url"),
      value: element.innerText,
    );
  }
}
