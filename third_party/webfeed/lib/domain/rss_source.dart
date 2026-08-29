import 'package:xml/xml.dart';

class RssSource {
  final String? url;
  final String value;

  RssSource(this.url, this.value);

  static RssSource? parse(XmlElement? element) {
    if (element == null) return null;
    var url = element.getAttribute("url");
    var value = element.innerText;

    return RssSource(url, value);
  }
}
