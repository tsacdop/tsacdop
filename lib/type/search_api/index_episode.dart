import 'package:json_annotation/json_annotation.dart';
import 'searchepisodes.dart';

part 'index_episode.g.dart';

@JsonSerializable()
class IndexEpisodeResult<P> {
  @_ConvertP()
  final List<P> items;
  final String status;
  final int count;
  IndexEpisodeResult({this.items, this.status, this.count});
  factory IndexEpisodeResult.fromJson(Map<String, dynamic> json) =>
      _$IndexEpisodeResultFromJson<P>(json);
  Map<String, dynamic> toJson() => _$IndexEpisodeResultToJson(this);
}

class _ConvertP<P> implements JsonConverter<P, Object> {
  const _ConvertP();
  @override
  P fromJson(Object json) {
    return IndexEpisode.fromJson(json) as P;
  }

  @override
  Object toJson(P object) {
    return object;
  }
}

@JsonSerializable()
class IndexEpisode {
  final String title;
  final String description;
  final int datePublished;
  final String enclosureUrl;
  final int enclosureLength;
  IndexEpisode(
      {this.title,
      this.description,
      this.datePublished,
      this.enclosureLength,
      this.enclosureUrl});

  factory IndexEpisode.fromJson(Map<String, dynamic> json) =>
      _$IndexEpisodeFromJson(json);
  Map<String, dynamic> toJson() => _$IndexEpisodeToJson(this);

  OnlineEpisode get toOnlineWEpisode =>
      OnlineEpisode(title: title, pubDate: datePublished * 1000, length: 0);
}
