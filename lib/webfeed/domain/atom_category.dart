import 'package:xml/xml.dart';

class AtomCategory {
  final String term;
  final String scheme;
  final String label;

  AtomCategory(this.term, this.scheme, this.label);

  factory AtomCategory.parse(XmlElement element) {
    var term = element.getAttribute("term");
    var scheme = element.getAttribute("scheme");
    var label = element.getAttribute("label");
    return AtomCategory(term, scheme, label);
  }
}
