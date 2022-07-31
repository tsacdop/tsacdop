// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_top_podcast.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchTopPodcast<T> _$SearchTopPodcastFromJson<T>(Map<String, dynamic> json) {
  return SearchTopPodcast<T>(
    podcasts:
        (json['podcasts'] as List?)?.map(_ConvertT<T>().fromJson).toList(),
    id: json['id'] as int?,
    total: json['total'] as int?,
    hasNext: json['has_next'] as bool?,
    page: json['page'] as int?,
  );
}

Map<String, dynamic> _$SearchTopPodcastToJson<T>(
        SearchTopPodcast<T> instance) =>
    <String, dynamic>{
      'podcasts': instance.podcasts?.map(_ConvertT<T>().toJson).toList(),
      'id': instance.id,
      'page': instance.page,
      'total': instance.total,
      'has_next': instance.hasNext,
    };

OnlineTopPodcast _$OnlineTopPodcastFromJson(Map<String, dynamic> json) {
  return OnlineTopPodcast(
    earliestPubDate: json['earliest_pub_date_ms'] as int?,
    title: json['title'] as String?,
    count: json['total_episodes'] as int?,
    description: json['description'] as String?,
    image: json['image'] as String?,
    latestPubDate: json['latest_pub_date_ms'] as int?,
    rss: json['rss'] as String?,
    publisher: json['publisher'] as String?,
    id: json['id'] as String?,
  );
}

Map<String, dynamic> _$OnlineTopPodcastToJson(OnlineTopPodcast instance) =>
    <String, dynamic>{
      'earliest_pub_date_ms': instance.earliestPubDate,
      'title': instance.title,
      'rss': instance.rss,
      'latest_pub_date_ms': instance.latestPubDate,
      'description': instance.description,
      'total_episodes': instance.count,
      'image': instance.image,
      'publisher': instance.publisher,
      'id': instance.id,
    };
