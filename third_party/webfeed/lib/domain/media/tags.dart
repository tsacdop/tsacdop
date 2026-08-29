import 'package:xml/xml.dart';

class Tags {
  final String? tags;
  final int? weight;

  Tags({this.tags, this.weight});

  static Tags? parse(XmlElement? element) {
    if (element == null) {
      return null;
    }
    return Tags(
      tags: element.innerText,
      weight: int.tryParse(element.getAttribute("weight") ?? "1"),
    );
  }
}
