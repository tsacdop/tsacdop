import 'package:xml/xml.dart';

class PodcastFunding {
  final String info;
  final String url;

  PodcastFunding(this.info, this.url);

  static PodcastFunding? parse(XmlElement? element) {
    if (element == null) {
      return null;
    }
    var url = element.getAttribute("url")?.trim() ?? "";
    var info = element.innerText.trim();

    return PodcastFunding(info, url);
  }
}
