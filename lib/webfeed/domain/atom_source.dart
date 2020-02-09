import 'package:webfeed/util/helpers.dart';
import 'package:xml/xml.dart';

class AtomSource {
  final String id;
  final String title;
  final String updated;

  AtomSource(this.id, this.title, this.updated);

  factory AtomSource.parse(XmlElement element) {
    if (element == null) {
      return null;
    }
    var id = findElementOrNull(element, "id")?.text;
    var title = findElementOrNull(element, "title")?.text;
    var updated = findElementOrNull(element, "updated")?.text;

    return AtomSource(id, title, updated);
  }
}
