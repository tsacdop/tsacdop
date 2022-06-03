// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'index_episode.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IndexEpisodeResult<P> _$IndexEpisodeResultFromJson<P>(
    Map<String, dynamic> json) {
  return IndexEpisodeResult<P>(
    items: (json['items'] as List?)?.map(_ConvertP<P>().fromJson).toList(),
    status: json['status'] as String?,
    count: json['count'] as int?,
  );
}

Map<String, dynamic> _$IndexEpisodeResultToJson<P>(
        IndexEpisodeResult<P> instance) =>
    <String, dynamic>{
      'items': instance.items?.map(_ConvertP<P>().toJson).toList(),
      'status': instance.status,
      'count': instance.count,
    };

IndexEpisode _$IndexEpisodeFromJson(Map<String, dynamic> json) {
  return IndexEpisode(
    title: json['title'] as String?,
    description: json['description'] as String?,
    datePublished: json['datePublished'] as int?,
    enclosureLength: json['enclosureLength'] as int?,
    enclosureUrl: json['enclosureUrl'] as String?,
    duration: json['duration'] as int?,
    feedImage: json['feedImage'] as String?,
  );
}

Map<String, dynamic> _$IndexEpisodeToJson(IndexEpisode instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'datePublished': instance.datePublished,
      'enclosureUrl': instance.enclosureUrl,
      'enclosureLength': instance.enclosureLength,
      'duration': instance.duration,
      'feedImage': instance.feedImage,
    };
