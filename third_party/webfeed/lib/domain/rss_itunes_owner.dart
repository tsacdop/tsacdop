import 'package:xml/xml.dart';

import '../util/helpers.dart';

class RssItunesOwner {
  final String? name;
  final String? email;

  RssItunesOwner({this.name, this.email});

  static RssItunesOwner? parse(XmlElement? element) {
    if (element == null) return null;
    return RssItunesOwner(
      name: findElementOrNull(element, "itunes:name")?.innerText.trim(),
      email: findElementOrNull(element, "itunes:email")?.innerText.trim(),
    );
  }
}
