import 'package:webfeed/domain/dublin_core/dublin_core.dart';
import 'package:webfeed/domain/media/media.dart';
import 'package:webfeed/domain/podcast_chapters.dart';
import 'package:webfeed/domain/podcast_location.dart';
import 'package:webfeed/domain/podcast_person.dart';
import 'package:webfeed/domain/podcast_soundbite.dart';
import 'package:webfeed/domain/podcast_transcript.dart';
import 'package:webfeed/domain/rss_category.dart';
import 'package:webfeed/domain/rss_content.dart';
import 'package:webfeed/domain/rss_enclosure.dart';
import 'package:webfeed/domain/rss_source.dart';
import 'package:webfeed/util/helpers.dart';
import 'package:xml/xml.dart';

import 'rss_item_itunes.dart';

class RssItem {
  final String? title;
  final String? description;
  final String? link;

  final List<RssCategory>? categories;
  final String? guid;
  final String? pubDate;
  final String? author;
  final String? comments;
  final RssSource? source;
  final RssContent? content;
  final Media? media;
  final RssEnclosure? enclosure;
  final DublinCore? dc;
  final RssItemItunes? itunes;
  final PodcastChapters? podcastChapters;
  final List<PodcastSoundbite?>? podcastSoundbite;
  final List<PodcastTranscript?>? podcastTranscript;
  final List<PodcastPerson?>? podcastPerson;
  final PodcastLocation? podcastLocation;

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
    this.podcastChapters,
    this.podcastSoundbite,
    this.podcastTranscript,
    this.podcastPerson,
    this.podcastLocation,
  });

  factory RssItem.parse(XmlElement element) {
    return RssItem(
      title: findElementOrNull(element, "title")?.innerText,
      description: findElementOrNull(element, "description")?.innerText,
      link: findElementOrNull(element, "link")?.innerText,
      //  categories: element.findElements("category").map((element) {
      //    return RssCategory.parse(element);
      //  }).toList(),
      //  guid: findElementOrNull(element, "guid")?.innerText,
      pubDate: findElementOrNull(element, "pubDate")?.innerText,
      author: findElementOrNull(element, "author")?.innerText,
      // comments: findElementOrNull(element, "comments")?.innerText,
      // source: RssSource.parse(findElementOrNull(element, "source")),
      content: RssContent.parse(findElementOrNull(element, "content:encoded")),
      //  media: Media.parse(element),
      enclosure: RssEnclosure.parse(findElementOrNull(element, "enclosure")),
      // dc: DublinCore.parse(element),
      itunes: RssItemItunes.parse(element),
      podcastChapters: PodcastChapters.parse(
        findElementOrNull(element, "podcast:chapters"),
      ),
      podcastSoundbite: findAllDirectElementsOrNull(
        element,
        "podcast:soundbite",
      )!.map((element) => PodcastSoundbite.parse(element)).toList(),
      podcastTranscript: findAllDirectElementsOrNull(
        element,
        "podcast:transcript",
      )!.map((element) => PodcastTranscript.parse(element)).toList(),
      podcastPerson: findAllDirectElementsOrNull(
        element,
        "podcast:person",
      )!.map((element) => PodcastPerson.parse(element)).toList(),
      podcastLocation: PodcastLocation.parse(
        findElementOrNull(element, "podcast:location"),
      ),
    );
  }
}
