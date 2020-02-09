import 'package:xml/xml.dart';

class Statistics {
  final int views;
  final int favorites;

  Statistics({
    this.views,
    this.favorites,
  });

  factory Statistics.parse(XmlElement element) {
    return new Statistics(
      views: int.tryParse(element.getAttribute("views") ?? "0"),
      favorites: int.tryParse(element.getAttribute("favorites") ?? "0"),
    );
  }
}
