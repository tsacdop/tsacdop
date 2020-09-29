import 'package:json_annotation/json_annotation.dart';

import 'searchpodcast.dart';

part 'index_podcast.g.dart';

@JsonSerializable()
class PodcastIndexSearchResult<P> {
  @_ConvertP()
  final List<P> feeds;
  final String status;
  final int count;
  PodcastIndexSearchResult({this.feeds, this.status, this.count});

  factory PodcastIndexSearchResult.fromJson(Map<String, dynamic> json) =>
      _$PodcastIndexSearchResultFromJson<P>(json);
  Map<String, dynamic> toJson() => _$PodcastIndexSearchResultToJson(this);
}

class _ConvertP<P> implements JsonConverter<P, Object> {
  const _ConvertP();
  @override
  P fromJson(Object json) {
    return IndexPodcast.fromJson(json) as P;
  }

  @override
  Object toJson(P object) {
    return object;
  }
}

@JsonSerializable()
class IndexPodcast {
  final int id;
  final String title;
  final String url;
  final String link;
  final String description;
  final String author;
  final String image;
  final int lastUpdateTime;
  final int itunesId;
  IndexPodcast(
      {this.id,
      this.title,
      this.url,
      this.link,
      this.description,
      this.author,
      this.image,
      this.lastUpdateTime,
      this.itunesId});
  factory IndexPodcast.fromJson(Map<String, dynamic> json) =>
      _$IndexPodcastFromJson(json);
  Map<String, dynamic> toJson() => _$IndexPodcastToJson(this);

  OnlinePodcast get toOnlinePodcast => OnlinePodcast(
      earliestPubDate: 0,
      title: title,
      count: 0,
      description: description,
      image: image,
      latestPubDate: lastUpdateTime * 1000,
      rss: url,
      publisher: author,
      id: itunesId.toString());
}
