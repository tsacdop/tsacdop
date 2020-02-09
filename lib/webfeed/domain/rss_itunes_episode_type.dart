import 'package:xml/xml.dart';

enum RssItunesEpisodeType {full, trailer, bonus}

RssItunesEpisodeType newRssItunesEpisodeType(XmlElement element) {
  // "full" is default type
  if (element == null) return RssItunesEpisodeType.full;

  switch (element.text) {
    case "full":
      return RssItunesEpisodeType.full;
    case "trailer":
      return RssItunesEpisodeType.trailer;
    case "bonus":
      return RssItunesEpisodeType.bonus;
    default:
      return null;
  }
}
