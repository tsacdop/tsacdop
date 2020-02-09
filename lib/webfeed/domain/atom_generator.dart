import 'package:xml/xml.dart';

class AtomGenerator {
  final String uri;
  final String version;
  final String value;

  AtomGenerator(this.uri, this.version, this.value);

  factory AtomGenerator.parse(XmlElement element) {
    if (element == null) {
      return null;
    }
    var uri = element.getAttribute("uri");
    var version = element.getAttribute("version");
    var value = element.text;
    return new AtomGenerator(uri, version, value);
  }
}
