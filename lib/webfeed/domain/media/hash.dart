import 'package:xml/xml.dart';

class Hash {
  final String algo;
  final String value;

  Hash({
    this.algo,
    this.value,
  });

  factory Hash.parse(XmlElement element) {
    if (element == null) {
      return null;
    }
    return new Hash(
      algo: element.getAttribute("algo"),
      value: element.text,
    );
  }
}
