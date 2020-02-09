import 'package:xml/xml.dart';

class Tags {
  final String tags;
  final int weight;

  Tags({
    this.tags,
    this.weight,
  });

  factory Tags.parse(XmlElement element) {
    if (element == null) {
      return null;
    }
    return new Tags(
      tags: element.text,
      weight: int.tryParse(element.getAttribute("weight") ?? "1"),
    );
  }
}
