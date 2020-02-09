import 'package:xml/xml.dart';

class PeerLink {
  final String type;
  final String href;
  final String value;

  PeerLink({
    this.type,
    this.href,
    this.value,
  });

  factory PeerLink.parse(XmlElement element) {
    if (element == null) {
      return null;
    }
    return new PeerLink(
      type: element.getAttribute("type"),
      href: element.getAttribute("href"),
      value: element.text,
    );
  }
}
