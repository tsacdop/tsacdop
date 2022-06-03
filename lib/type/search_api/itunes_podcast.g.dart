// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itunes_podcast.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItunesSearchResult<P> _$ItunesSearchResultFromJson<P>(
    Map<String, dynamic> json) {
  return ItunesSearchResult<P>(
    resultCount: json['resultCount'] as int?,
    results: (json['results'] as List?)?.map(_ConvertP<P>().fromJson).toList(),
  );
}

Map<String, dynamic> _$ItunesSearchResultToJson<P>(
        ItunesSearchResult<P> instance) =>
    <String, dynamic>{
      'results': instance.results?.map(_ConvertP<P>().toJson).toList(),
      'resultCount': instance.resultCount,
    };

ItunesPodcast _$ItunesPodcastFromJson(Map<String, dynamic> json) {
  return ItunesPodcast(
    artistName: json['artistName'] as String?,
    collectionName: json['collectionName'] as String?,
    feedUrl: json['feedUrl'] as String?,
    artworkUrl600: json['artworkUrl600'] as String?,
    releaseDate: json['releaseDate'] as String?,
    collectionId: json['collectionId'] as int?,
  );
}

Map<String, dynamic> _$ItunesPodcastToJson(ItunesPodcast instance) =>
    <String, dynamic>{
      'artistName': instance.artistName,
      'collectionName': instance.collectionName,
      'feedUrl': instance.feedUrl,
      'artworkUrl600': instance.artworkUrl600,
      'releaseDate': instance.releaseDate,
      'collectionId': instance.collectionId,
    };
