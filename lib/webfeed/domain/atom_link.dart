import 'package:xml/xml.dart';

class AtomLink {
  final String href;
  final String rel;
  final String type;
  final String hreflang;
  final String title;
  final int length;

  AtomLink(
    this.href,
    this.rel,
    this.type,
    this.hreflang,
    this.title,
    this.length,
  );

  factory AtomLink.parse(XmlElement element) {
    var href = element.getAttribute("href");
    var rel = element.getAttribute("rel");
    var type = element.getAttribute("type");
    var title = element.getAttribute("title");
    var hreflang = element.getAttribute("hreflang");
    var length = 0;
    if (element.getAttribute("length") != null) {
      length = int.parse(element.getAttribute("length"));
    }
    return AtomLink(href, rel, type, hreflang, title, length);
  }
}
