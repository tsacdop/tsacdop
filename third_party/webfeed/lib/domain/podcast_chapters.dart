import 'package:xml/xml.dart';

class PodcastChapters {
  final String url;
  final String type;

  PodcastChapters(this.url, this.type);

  static PodcastChapters? parse(XmlElement? element) {
    if (element == null) {
      return null;
    }
    var url = element.getAttribute("url")?.trim() ?? "";
    var type = element.getAttribute("type")?.trim() ?? "";

    return PodcastChapters(url, type);
  }
}
