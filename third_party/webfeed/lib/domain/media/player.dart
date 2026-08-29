import 'package:xml/xml.dart';

class Player {
  final String? url;
  final int? width;
  final int? height;
  final String? value;

  Player({this.url, this.width, this.height, this.value});

  static Player? parse(XmlElement? element) {
    if (element == null) {
      return null;
    }
    return Player(
      url: element.getAttribute("url"),
      width: int.tryParse(element.getAttribute("width") ?? "0"),
      height: int.tryParse(element.getAttribute("height") ?? "0"),
      value: element.innerText,
    );
  }
}
