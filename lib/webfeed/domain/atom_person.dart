import 'package:webfeed/util/helpers.dart';
import 'package:xml/xml.dart';

class AtomPerson {
  final String name;
  final String uri;
  final String email;

  AtomPerson(this.name, this.uri, this.email);

  factory AtomPerson.parse(XmlElement element) {
    var name = findElementOrNull(element, "name")?.text;
    var uri = findElementOrNull(element, "uri")?.text;
    var email = findElementOrNull(element, "email")?.text;
    return AtomPerson(name, uri, email);
  }
}
