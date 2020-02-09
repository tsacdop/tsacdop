import 'package:xml/xml.dart';

import '../util/helpers.dart';

class RssItunesOwner {
  final String name;
  final String email;

  RssItunesOwner({this.name, this.email});

  factory RssItunesOwner.parse(XmlElement element) {
    if (element == null) return null;
    return RssItunesOwner(
      name: findElementOrNull(element, "itunes:name")?.text?.trim(),
      email: findElementOrNull(element, "itunes:email")?.text?.trim(),
    );
  }
}
