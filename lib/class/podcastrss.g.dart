// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcastrss.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Podcastrss<R> _$PodcastrssFromJson<R>(Map<String, dynamic> json) {
  return Podcastrss<R>(
      rss: json['rss'] == null ? null : _ConvertR<R>().fromJson(json['rss']));
}

Map<String, dynamic> _$PodcastrssToJson<R>(Podcastrss<R> instance) =>
    <String, dynamic>{
      'rss': instance.rss == null ? null : _ConvertR<R>().toJson(instance.rss)
    };

Rss<C> _$RssFromJson<C>(Map<String, dynamic> json) {
  return Rss<C>(
      channel: json['channel'] == null
          ? null
          : _ConvertC<C>().fromJson(json['channel']));
}

Map<String, dynamic> _$RssToJson<C>(Rss<C> instance) => <String, dynamic>{
      'channel': instance.channel == null
          ? null
          : _ConvertC<C>().toJson(instance.channel)
    };

Channel<E> _$ChannelFromJson<E>(Map<String, dynamic> json) {
  return Channel<E>(
      title: json['title'] as String,
      link: json['link'] as String,
      description: json['description'] as String,
      item: (json['item'] as List)
          ?.map((e) => e == null ? null : _ConvertE<E>().fromJson(e))
          ?.toList());
}

Map<String, dynamic> _$ChannelToJson<E>(Channel<E> instance) =>
    <String, dynamic>{
      'title': instance.title,
      'link': instance.link,
      'description': instance.description,
      'item': instance.item
          ?.map((e) => e == null ? null : _ConvertE<E>().toJson(e))
          ?.toList()
    };

EpisodeItem _$EpisodeItemFromJson(Map<String, dynamic> json) {
  return EpisodeItem(
      title: json['title'] as String,
      link: json['link'] as String,
      pubDate: json['pubDate'] as String,
      description: json['description'] as String);
}

Map<String, dynamic> _$EpisodeItemToJson(EpisodeItem instance) =>
    <String, dynamic>{
      'title': instance.title,
      'link': instance.link,
      'pubDate': instance.pubDate,
      'description': instance.description
    };
