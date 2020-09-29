import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

import 'searchpodcast.dart';

part 'itunes_podcast.g.dart';

@JsonSerializable()
class ItunesSearchResult<P> {
  @_ConvertP()
  final List<P> results;
  final int resultCount;
  ItunesSearchResult({this.resultCount, this.results});

  factory ItunesSearchResult.fromJson(Map<String, dynamic> json) =>
      _$ItunesSearchResultFromJson<P>(json);
  Map<String, dynamic> toJson() => _$ItunesSearchResultToJson(this);
}

class _ConvertP<P> implements JsonConverter<P, Object> {
  const _ConvertP();
  @override
  P fromJson(Object json) {
    return ItunesPodcast.fromJson(json) as P;
  }

  @override
  Object toJson(P object) {
    return object;
  }
}

@JsonSerializable()
class ItunesPodcast {
  final String artistName;
  final String collectionName;
  final String feedUrl;
  final String artworkUrl600;
  final String releaseDate;
  final int collectionId;

  ItunesPodcast(
      {this.artistName,
      this.collectionName,
      this.feedUrl,
      this.artworkUrl600,
      this.releaseDate,
      this.collectionId});

  factory ItunesPodcast.fromJson(Map<String, dynamic> json) =>
      _$ItunesPodcastFromJson(json);
  Map<String, dynamic> toJson() => _$ItunesPodcastToJson(this);

  int get latestPubDate => DateFormat('yyyy-MM-DDTHH:MM:SSZ', 'en_US')
      .parse(releaseDate)
      .millisecondsSinceEpoch;
  OnlinePodcast get toOnlinePodcast => OnlinePodcast(
      earliestPubDate: 0,
      title: collectionName,
      count: 0,
      description: '',
      image: artworkUrl600,
      latestPubDate: latestPubDate,
      rss: feedUrl,
      publisher: artistName,
      id: collectionId.toString());
}
