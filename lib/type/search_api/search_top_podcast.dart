import 'package:json_annotation/json_annotation.dart';
import 'searchpodcast.dart';
part 'search_top_podcast.g.dart';

@JsonSerializable()
class SearchTopPodcast<T> {
  @_ConvertT()
  final List<T> podcasts;
  final int id;
  final int page;
  final int total;
  @JsonKey(name: 'has_next')
  final bool hasNext;
  SearchTopPodcast(
      {this.podcasts, this.id, this.total, this.hasNext, this.page});

  factory SearchTopPodcast.fromJson(Map<String, dynamic> json) =>
      _$SearchTopPodcastFromJson<T>(json);
  Map<String, dynamic> toJson() => _$SearchTopPodcastToJson(this);
}

class _ConvertT<T> implements JsonConverter<T, Object> {
  const _ConvertT();
  @override
  T fromJson(Object json) {
    return OnlineTopPodcast.fromJson(json) as T;
  }

  @override
  Object toJson(T object) {
    return object;
  }
}

@JsonSerializable()
class OnlineTopPodcast {
  @JsonKey(name: 'earliest_pub_date_ms')
  final int earliestPubDate;
  @JsonKey(name: 'title')
  final String title;
  final String rss;
  @JsonKey(name: 'latest_pub_date_ms')
  final int latestPubDate;
  @JsonKey(name: 'description')
  final String description;
  @JsonKey(name: 'total_episodes')
  final int count;
  final String image;
  @JsonKey(name: 'publisher')
  final String publisher;
  final String id;
  OnlineTopPodcast(
      {this.earliestPubDate,
      this.title,
      this.count,
      this.description,
      this.image,
      this.latestPubDate,
      this.rss,
      this.publisher,
      this.id});
  factory OnlineTopPodcast.fromJson(Map<String, dynamic> json) =>
      _$OnlineTopPodcastFromJson(json);
  Map<String, dynamic> toJson() => _$OnlineTopPodcastToJson(this);

  OnlinePodcast get toOnlinePodcast => OnlinePodcast(
      earliestPubDate: earliestPubDate,
      title: title,
      count: count,
      description: description,
      image: image,
      latestPubDate: latestPubDate,
      rss: rss,
      publisher: publisher,
      id: id);
}
