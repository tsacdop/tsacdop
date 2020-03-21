import '../domain/dublin_core/dublin_core.dart';
import '../domain/media/media.dart';
import '../domain/rss_category.dart';
import '../domain/rss_content.dart';
import '../domain/rss_enclosure.dart';
import '../domain/rss_source.dart';
import '../util/helpers.dart';
import 'package:xml/xml.dart';

import 'rss_item_itunes.dart';

class RssItem {
  final String title;
  final String description;
  final String link;

  final List<RssCategory> categories;
  final String guid;
  final String pubDate;
  final String author;
  final String comments;
  final RssSource source;
  final RssContent content;
  final Media media;
  final RssEnclosure enclosure;
  final DublinCore dc;
  final RssItemItunes itunes;

  RssItem({
    this.title,
    this.description,
    this.link,
    this.categories,
    this.guid,
    this.pubDate,
    this.author,
    this.comments,
    this.source,
    this.content,
    this.media,
    this.enclosure,
    this.dc,
    this.itunes,
  });

  factory RssItem.parse(XmlElement element) {
    if (RssEnclosure.parse(findElementOrNull(element, "enclosure")) == null) {
      return null;
    }
    return RssItem(
      title: findElementOrNull(element, "title")?.text,
      description: findElementOrNull(element, "description")?.text?.trim(),
      link: findElementOrNull(element, "link")?.text?.trim(),
      categories: element.findElements("category").map((element) {
        return RssCategory.parse(element);
      }).toList(),
      //guid: findElementOrNull(element, "guid")?.text,
      pubDate: findElementOrNull(element, "pubDate")?.text?.trim(),
      author: findElementOrNull(element, "author")?.text?.trim(),
      // comments: findElementOrNull(element, "comments")?.text,
      // source: RssSource.parse(findElementOrNull(element, "source")),
      content: RssContent.parse(findElementOrNull(element, "content:encoded")),
      // media: Media.parse(element),
      enclosure: RssEnclosure.parse(findElementOrNull(element, "enclosure")),
      //dc: DublinCore.parse(element),
      itunes: RssItemItunes.parse(element),
    );
  }
}
