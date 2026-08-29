import 'package:xml/xml.dart';

class PodcastTranscript {
  final String url;
  final String type;

  PodcastTranscript(this.url, this.type);

  static PodcastTranscript? parse(XmlElement? element) {
    if (element == null) {
      return null;
    }
    var url = element.getAttribute("url")?.trim() ?? "";
    var type = element.getAttribute("type")?.trim() ?? "";

    return PodcastTranscript(url, type);
  }
}
