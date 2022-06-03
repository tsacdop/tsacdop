// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'searchpodcast.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchPodcast<P> _$SearchPodcastFromJson<P>(Map<String, dynamic> json) {
  return SearchPodcast<P>(
    results: (json['results'] as List?)?.map(_ConvertP<P>().fromJson).toList(),
    nextOffset: json['next_offset'] as int?,
    total: json['total'] as int?,
    count: json['count'] as int?,
  );
}

Map<String, dynamic> _$SearchPodcastToJson<P>(SearchPodcast<P> instance) =>
    <String, dynamic>{
      'results': instance.results?.map(_ConvertP<P>().toJson).toList(),
      'next_offset': instance.nextOffset,
      'total': instance.total,
      'count': instance.count,
    };

OnlinePodcast _$OnlinePodcastFromJson(Map<String, dynamic> json) {
  return OnlinePodcast(
    earliestPubDate: json['earliest_pub_date_ms'] as int?,
    title: json['title_original'] as String?,
    count: json['total_episodes'] as int?,
    description: json['description_original'] as String?,
    image: json['image'] as String?,
    latestPubDate: json['latest_pub_date_ms'] as int?,
    rss: json['rss'] as String?,
    publisher: json['publisher_original'] as String?,
    id: json['id'] as String?,
  );
}

Map<String, dynamic> _$OnlinePodcastToJson(OnlinePodcast instance) =>
    <String, dynamic>{
      'earliest_pub_date_ms': instance.earliestPubDate,
      'title_original': instance.title,
      'rss': instance.rss,
      'latest_pub_date_ms': instance.latestPubDate,
      'description_original': instance.description,
      'total_episodes': instance.count,
      'image': instance.image,
      'publisher_original': instance.publisher,
      'id': instance.id,
    };
