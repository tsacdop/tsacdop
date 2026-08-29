import 'package:webfeed/domain/media/star_rating.dart';
import 'package:webfeed/domain/media/statistics.dart';
import 'package:webfeed/domain/media/tags.dart';
import 'package:webfeed/util/helpers.dart';
import 'package:xml/xml.dart';

class Community {
  final StarRating? starRating;
  final Statistics? statistics;
  final Tags? tags;

  Community({this.starRating, this.statistics, this.tags});

  static Community? parse(XmlElement? element) {
    if (element == null) {
      return null;
    }
    return Community(
      starRating: StarRating.parse(
        findElementOrNull(element, "media:starRating")!,
      ),
      statistics: Statistics.parse(
        findElementOrNull(element, "media:statistics")!,
      ),
      tags: Tags.parse(findElementOrNull(element, "media:tags")),
    );
  }
}
