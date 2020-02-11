import '../util/helpers.dart';
import 'package:xml/xml.dart';

import 'rss_itunes_category.dart';
import 'rss_itunes_episode_type.dart';
import 'rss_itunes_image.dart';

class RssItemItunes {
  final String title;
  final int episode;
  final int season;
  final Duration duration;
  final RssItunesEpisodeType episodeType;
  final String author;
  final String summary;
  final bool explicit;
  final String subtitle;
  final List<String> keywords;
  final RssItunesImage image;
  final RssItunesCategory category;
  final bool block;

  RssItemItunes({
    this.title,
    this.episode,
    this.season,
    this.duration,
    this.episodeType,
    this.author,
    this.summary,
    this.explicit,
    this.subtitle,
    this.keywords,
    this.image,
    this.category,
    this.block,
  });

  factory RssItemItunes.parse(XmlElement element) {
    if (element == null) {
      return null;
    }
    //var episodeStr = findElementOrNull(element, "itunes:episode")?.text?.trim();
    //var seasonStr = findElementOrNull(element, "itunes:season")?.text?.trim();
    var durationStr =
        findElementOrNull(element, "itunes:duration")?.text?.trim();

    return RssItemItunes(
      title: findElementOrNull(element, "itunes:title")?.text?.trim(),
      //episode: episodeStr == null ? null : int.parse(episodeStr),
      //season: seasonStr == null ? null : int.parse(seasonStr),
      duration: durationStr == null ? null : parseDuration(durationStr),
      // episodeType: newRssItunesEpisodeType(findElementOrNull(element, "itunes:episodeType")),
      author: findElementOrNull(element, "itunes:author")?.text?.trim(),
      summary: findElementOrNull(element, "itunes:summary")?.text?.trim(),
      explicit: parseBoolLiteral(element, "itunes:explicit"),
      //subtitle: findElementOrNull(element, "itunes:subtitle")?.text?.trim(),
      // keywords: findElementOrNull(element, "itunes:keywords")?.text?.split(",")?.map((keyword) => keyword.trim())?.toList(),
      // image: RssItunesImage.parse(findElementOrNull(element, "itunes:image")),
      // category: RssItunesCategory.parse(
      //     findElementOrNull(element, "itunes:category")),
      // block: parseBoolLiteral(element, "itunes:block"),
    );
  }
}

Duration parseDuration(String s) {
  var hours = 0;
  var minutes = 0;
  var seconds = 0;
  var parts = s.split(':');
  if (parts.length > 2) {
    hours = int.parse(parts[parts.length - 3]);
  }
  if (parts.length > 1) {
    minutes = int.parse(parts[parts.length - 2]);
  }
  seconds = int.parse(parts[parts.length - 1]);
  return Duration(
    hours: hours,
    minutes: minutes,
    seconds: seconds,
  );
}
