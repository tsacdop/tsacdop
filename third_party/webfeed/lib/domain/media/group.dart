import 'package:webfeed/domain/media/category.dart';
import 'package:webfeed/domain/media/content.dart';
import 'package:webfeed/domain/media/credit.dart';
import 'package:webfeed/domain/media/rating.dart';
import 'package:webfeed/util/helpers.dart';
import 'package:xml/xml.dart';

class Group {
  final List<Content>? contents;
  final List<Credit>? credits;
  final Category? category;
  final Rating? rating;

  Group({this.contents, this.credits, this.category, this.rating});

  static Group? parse(XmlElement? element) {
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
      category: Category.parse(findElementOrNull(element, "media:category")),
      rating: Rating.parse(findElementOrNull(element, "media:rating")),
    );
  }
}
