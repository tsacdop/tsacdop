import 'package:xml/xml.dart';

class PodcastLocation {
  final String name;
  final String? geo;
  final String? osm;
  PodcastLocation(this.name, {this.geo, this.osm});

  static PodcastLocation? parse(XmlElement? element) {
    if (element == null) {
      return null;
    }
    var name = element.innerText.trim();
    var geo = element.getAttribute("geo")?.trim() ?? "";
    var osm = element.getAttribute("osm")?.trim() ?? "";

    return PodcastLocation(name, geo: geo, osm: osm);
  }
}
