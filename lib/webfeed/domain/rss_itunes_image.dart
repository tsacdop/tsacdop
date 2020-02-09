import 'package:xml/xml.dart';

class RssItunesImage {
  final String href;

  RssItunesImage({this.href});

  factory RssItunesImage.parse(XmlElement element) {
    if (element == null) return null;
    return RssItunesImage(
      href: element.getAttribute("href")?.trim(),
    );
  }
}
