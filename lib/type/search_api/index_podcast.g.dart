// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'index_podcast.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PodcastIndexSearchResult<P> _$PodcastIndexSearchResultFromJson<P>(
    Map<String, dynamic> json) {
  return PodcastIndexSearchResult<P>(
    feeds: (json['feeds'] as List?)?.map(_ConvertP<P>().fromJson).toList(),
    status: json['status'] as String?,
    count: json['count'] as int?,
  );
}

Map<String, dynamic> _$PodcastIndexSearchResultToJson<P>(
        PodcastIndexSearchResult<P> instance) =>
    <String, dynamic>{
      'feeds': instance.feeds?.map(_ConvertP<P>().toJson).toList(),
      'status': instance.status,
      'count': instance.count,
    };

IndexPodcast _$IndexPodcastFromJson(Map<String, dynamic> json) {
  return IndexPodcast(
    id: json['id'] as int?,
    title: json['title'] as String?,
    url: json['url'] as String?,
    link: json['link'] as String?,
    description: json['description'] as String?,
    author: json['author'] as String?,
    image: json['image'] as String?,
    lastUpdateTime: json['lastUpdateTime'] as int?,
    itunesId: json['itunesId'] as int?,
  );
}

Map<String, dynamic> _$IndexPodcastToJson(IndexPodcast instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'url': instance.url,
      'link': instance.link,
      'description': instance.description,
      'author': instance.author,
      'image': instance.image,
      'lastUpdateTime': instance.lastUpdateTime,
      'itunesId': instance.itunesId,
    };
