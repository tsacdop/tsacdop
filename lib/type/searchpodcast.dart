import 'dart:ui';

import 'package:json_annotation/json_annotation.dart';
part 'searchpodcast.g.dart';

@JsonSerializable()
class SearchPodcast<P> {
  @_ConvertP()
  final List<P> results;
  @JsonKey(name: 'next_offset')
  final int nextOffset;
  final int total;
  final int count;
  SearchPodcast({this.results, this.nextOffset, this.total, this.count});
  factory SearchPodcast.fromJson(Map<String, dynamic> json) =>
      _$SearchPodcastFromJson<P>(json);
  Map<String, dynamic> toJson() => _$SearchPodcastToJson(this);
}

class _ConvertP<P> implements JsonConverter<P, Object> {
  const _ConvertP();
  @override
  P fromJson(Object json) {
    return OnlinePodcast.fromJson(json) as P;
  }

  @override
  Object toJson(P object) {
    return object;
  }
}

@JsonSerializable()
class OnlinePodcast {
  @JsonKey(name: 'earliest_pub_date_ms')
  final int earliestPubDate;
  @JsonKey(name: 'title_original')
  final String title;
  final String rss;
  @JsonKey(name: 'latest_pub_date_ms')
  final int latestPubDate;
  @JsonKey(name: 'description_original')
  final String description;
  @JsonKey(name: 'total_episodes')
  final int count;
  final String image;
  @JsonKey(name: 'publisher_original')
  final String publisher;
  final String id;
  OnlinePodcast(
      {this.earliestPubDate,
      this.title,
      this.count,
      this.description,
      this.image,
      this.latestPubDate,
      this.rss,
      this.publisher,
      this.id});
  factory OnlinePodcast.fromJson(Map<String, dynamic> json) =>
      _$OnlinePodcastFromJson(json);
  Map<String, dynamic> toJson() => _$OnlinePodcastToJson(this);

  @override
  bool operator ==(Object onlinePodcast) =>
      onlinePodcast is OnlinePodcast && onlinePodcast.id == id;

  @override
  int get hashCode => hashValues(id, title);

  int get interval {
    if (count < 1) {
      // ignore: avoid_returning_null
      return null;
    }
    return (latestPubDate - earliestPubDate) ~/ count;
  }
}
