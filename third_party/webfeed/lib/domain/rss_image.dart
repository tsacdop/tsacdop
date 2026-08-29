import 'package:webfeed/util/helpers.dart';
import 'package:xml/xml.dart';

class RssImage {
  final String? title;
  final String? url;
  final String? link;

  RssImage(this.title, this.url, this.link);

  static RssImage? parse(XmlElement? element) {
    if (element == null) {
      return null;
    }
    var title = findElementOrNull(element, "title")?.innerText;
    var url = findElementOrNull(element, "url")?.innerText;
    var link = findElementOrNull(element, "link")?.innerText;

    return RssImage(title, url, link);
  }
}
