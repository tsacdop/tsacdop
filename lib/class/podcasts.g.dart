// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcasts.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Podcast<E, F> _$PodcastFromJson<E, F>(Map<String, dynamic> json) {
  return Podcast<E, F>(
      version: json['version'] as String,
      title: json['title'] as String,
      homepageUrl: json['homepage_url'] as String,
      feedUrl: json['feed_url'] as String,
      description: json['description'] as String,
      fireSide: json['_fireside'] == null
          ? null
          : _ConvertF<F>().fromJson(json['_fireside']),
      items: (json['items'] as List)
          ?.map((e) => e == null ? null : _ConvertE<E>().fromJson(e))
          ?.toList());
}

Map<String, dynamic> _$PodcastToJson<E, F>(Podcast<E, F> instance) =>
    <String, dynamic>{
      'version': instance.version,
      'title': instance.title,
      'homepage_url': instance.homepageUrl,
      'feed_url': instance.feedUrl,
      'description': instance.description,
      '_fireside': instance.fireSide == null
          ? null
          : _ConvertF<F>().toJson(instance.fireSide),
      'items': instance.items
          ?.map((e) => e == null ? null : _ConvertE<E>().toJson(e))
          ?.toList()
    };

FireSide _$FireSideFromJson(Map<String, dynamic> json) {
  return FireSide(
      pubdate: json['pubdate'] as String,
      explicit: json['explicit'] as bool,
      copyright: json['copyright'] as String,
      owner: json['owner'] as String,
      image: json['image'] as String);
}

Map<String, dynamic> _$FireSideToJson(FireSide instance) => <String, dynamic>{
      'pubdate': instance.pubdate,
      'explicit': instance.explicit,
      'copyright': instance.copyright,
      'owner': instance.owner,
      'image': instance.image
    };

EpisodeItem<A> _$EpisodeItemFromJson<A>(Map<String, dynamic> json) {
  return EpisodeItem<A>(
      id: json['id'] as String,
      title: json['title'] as String,
      url: json['url'] as String,
      contentText: json['content_text'] as String,
      contentHtml: json['content_html'] as String,
      summary: json['summary'] as String,
      datePublished: json['date_published'] as String,
      attachments: (json['attachments'] as List)
          ?.map((e) => e == null ? null : _ConvertA<A>().fromJson(e))
          ?.toList());
}

Map<String, dynamic> _$EpisodeItemToJson<A>(EpisodeItem<A> instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'url': instance.url,
      'content_text': instance.contentText,
      'content_html': instance.contentHtml,
      'summary': instance.summary,
      'date_published': instance.datePublished,
      'attachments': instance.attachments
          ?.map((e) => e == null ? null : _ConvertA<A>().toJson(e))
          ?.toList()
    };

Attachment _$AttachmentFromJson(Map<String, dynamic> json) {
  return Attachment(
      url: json['url'] as String,
      mimeType: json['mime_type'] as String,
      sizeInBytes: json['size_in_bytes'] as int,
      durationInSeconds: json['duration_in_seconds'] as int);
}

Map<String, dynamic> _$AttachmentToJson(Attachment instance) =>
    <String, dynamic>{
      'url': instance.url,
      'mime_type': instance.mimeType,
      'size_in_bytes': instance.sizeInBytes,
      'duration_in_seconds': instance.durationInSeconds
    };
