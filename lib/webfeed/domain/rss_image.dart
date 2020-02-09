import '../util/helpers.dart';
import 'package:xml/xml.dart';

class RssImage {
  final String title;
  final String url;
  final String link;

  RssImage(this.title, this.url, this.link);

  factory RssImage.parse(XmlElement element) {
    if (element == null) {
      return null;
    }
    var title = findElementOrNull(element, "title")?.text;
    var url = findElementOrNull(element, "url")?.text;
    var link = findElementOrNull(element, "link")?.text;

    return RssImage(title, url, link);
  }
}
