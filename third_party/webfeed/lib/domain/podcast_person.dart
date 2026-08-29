import 'package:xml/xml.dart';

class PodcastPerson {
  final String name;
  final String? role;
  final String? group;
  final String? image;
  final String? href;

  PodcastPerson(this.name, {this.role, this.group, this.image, this.href});

  static PodcastPerson? parse(XmlElement? element) {
    if (element == null) {
      return null;
    }
    var name = element.innerText.trim();
    var role = element.getAttribute("role")?.trim() ?? "";
    var group = element.getAttribute("group")?.trim() ?? "";
    var image = element.getAttribute("image")?.trim() ?? "";
    var href = element.getAttribute("href")?.trim() ?? "";

    return PodcastPerson(
      name,
      role: role,
      group: group,
      image: image,
      href: href,
    );
  }
}
