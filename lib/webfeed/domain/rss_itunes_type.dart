import 'package:xml/xml.dart';

enum RssItunesType { episodic, serial }

RssItunesType newRssItunesType(XmlElement element) {
  // "episodic" is default type
  if (element == null) return RssItunesType.episodic;

  switch (element.text) {
    case "episodic":
      return RssItunesType.episodic;
    case "serial":
      return RssItunesType.serial;
    default:
      return null;
  }
}
