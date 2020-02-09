import 'package:webfeed/domain/media/star_rating.dart';
import 'package:webfeed/domain/media/statistics.dart';
import 'package:webfeed/domain/media/tags.dart';
import 'package:webfeed/util/helpers.dart';
import 'package:xml/xml.dart';

class Community {
  final StarRating starRating;
  final Statistics statistics;
  final Tags tags;

  Community({
    this.starRating,
    this.statistics,
    this.tags,
  });

  factory Community.parse(XmlElement element) {
    if (element == null) {
      return null;
    }
    return new Community(
      starRating: new StarRating.parse(
        findElementOrNull(element, "media:starRating"),
      ),
      statistics: new Statistics.parse(
        findElementOrNull(element, "media:statistics"),
      ),
      tags: new Tags.parse(
        findElementOrNull(element, "media:tags"),
      ),
    );
  }
}
