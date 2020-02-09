import 'package:xml/xml.dart';

class Thumbnail {
  final String url;
  final String width;
  final String height;
  final String time;

  Thumbnail({
    this.url,
    this.width,
    this.height,
    this.time,
  });

  factory Thumbnail.parse(XmlElement element) {
    return new Thumbnail(
      url: element.getAttribute("url"),
      width: element.getAttribute("width"),
      height: element.getAttribute("height"),
      time: element.getAttribute("time"),
    );
  }
}
