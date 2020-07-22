import 'package:json_annotation/json_annotation.dart';
part 'searchepisodes.g.dart';

@JsonSerializable()
class SearchEpisodes<E> {
  @_ConvertE()
  final List<E> episodes;
  @JsonKey(name: 'next_episode_pub_date')
  final int nextEpisodeDate;
  SearchEpisodes({this.episodes, this.nextEpisodeDate});
  factory SearchEpisodes.fromJson(Map<String, dynamic> json) =>
      _$SearchEpisodesFromJson<E>(json);
  Map<String, dynamic> toJson() => _$SearchEpisodesToJson(this);
}

class _ConvertE<E> implements JsonConverter<E, Object> {
  const _ConvertE();
  @override
  E fromJson(Object json) {
    return OnlineEpisode.fromJson(json) as E;
  }

  @override
  Object toJson(E object) {
    return object;
  }
}

@JsonSerializable()
class OnlineEpisode {
  final String title;
  @JsonKey(name: 'pub_date_ms')
  final int pubDate;
  @JsonKey(name: 'audio_length_sec')
  final int length;
  OnlineEpisode({this.title, this.pubDate, this.length});
  factory OnlineEpisode.fromJson(Map<String, dynamic> json) =>
      _$OnlineEpisodeFromJson(json);
  Map<String, dynamic> toJson() => _$OnlineEpisodeToJson(this);
}
