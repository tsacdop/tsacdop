import 'package:xml/xml.dart';

class AtomGenerator {
  final String? uri;
  final String? version;
  final String value;

  AtomGenerator(this.uri, this.version, this.value);

  static AtomGenerator? parse(XmlElement? element) {
    if (element == null) return null;
    var uri = element.getAttribute("uri");
    var version = element.getAttribute("version");
    var value = element.innerText;
    return AtomGenerator(uri, version, value);
  }
}
