import 'package:xml/xml.dart';

import '../../util/helpers.dart';
import 'category.dart';
import 'content.dart';
import 'credit.dart';
import 'rating.dart';

class Group {
  final List<Content> contents;
  final List<Credit> credits;
  final Category category;
  final Rating rating;

  Group({
    this.contents,
    this.credits,
    this.category,
    this.rating,
  });

  factory Group.parse(XmlElement element) {
    if (element == null) {
      return null;
    }
    return Group(
      contents: element.findElements("media:content").map((e) {
        return Content.parse(e);
      }).toList(),
      credits: element.findElements("media:credit").map((e) {
        return Credit.parse(e);
      }).toList(),
      category: Category.parse(
        findElementOrNull(element, "media:category"),
      ),
      rating: Rating.parse(
        findElementOrNull(element, "media:rating"),
      ),
    );
  }
}
