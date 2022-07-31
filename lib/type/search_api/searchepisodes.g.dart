// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'searchepisodes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchEpisodes<E> _$SearchEpisodesFromJson<E>(Map<String, dynamic> json) {
  return SearchEpisodes<E>(
    episodes:
        (json['episodes'] as List?)?.map(_ConvertE<E>().fromJson).toList(),
    nextEpisodeDate: json['next_episode_pub_date'] as int?,
  );
}

Map<String, dynamic> _$SearchEpisodesToJson<E>(SearchEpisodes<E> instance) =>
    <String, dynamic>{
      'episodes': instance.episodes?.map(_ConvertE<E>().toJson).toList(),
      'next_episode_pub_date': instance.nextEpisodeDate,
    };

OnlineEpisode _$OnlineEpisodeFromJson(Map<String, dynamic> json) {
  return OnlineEpisode(
    title: json['title'] as String?,
    pubDate: json['pub_date_ms'] as int?,
    length: json['audio_length_sec'] as int?,
    audio: json['audio'] as String?,
    thumbnail: json['thumbnail'] as String?,
  );
}

Map<String, dynamic> _$OnlineEpisodeToJson(OnlineEpisode instance) =>
    <String, dynamic>{
      'title': instance.title,
      'pub_date_ms': instance.pubDate,
      'audio_length_sec': instance.length,
      'audio': instance.audio,
      'thumbnail': instance.thumbnail,
    };
