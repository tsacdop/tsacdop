import 'package:xml/xml.dart';

class RssEnclosure {
  final String url;
  final String type;
  final int length;

  RssEnclosure(this.url, this.type, this.length);

  factory RssEnclosure.parse(XmlElement element) {
    if (element == null) {
      return null;
    }
    var url = element.getAttribute("url");
    var type = element.getAttribute("type");
    var length = int.tryParse(element.getAttribute("length") ?? "0");
    return RssEnclosure(url, type, length);
  }
}
