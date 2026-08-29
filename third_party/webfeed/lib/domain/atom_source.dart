import 'package:webfeed/util/helpers.dart';
import 'package:xml/xml.dart';

class AtomSource {
  final String? id;
  final String? title;
  final String? updated;

  AtomSource(this.id, this.title, this.updated);

  static AtomSource? parse(XmlElement? element) {
    if (element == null) {
      return null;
    }
    var id = findElementOrNull(element, "id")?.innerText;
    var title = findElementOrNull(element, "title")?.innerText;
    var updated = findElementOrNull(element, "updated")?.innerText;

    return AtomSource(id, title, updated);
  }
}
