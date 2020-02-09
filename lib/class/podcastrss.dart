import 'package:json_annotation/json_annotation.dart';
part 'podcastrss.g.dart';

@JsonSerializable()
class Podcastrss<R>{
  @_ConvertR()
  final R rss;
  Podcastrss({this.rss});
  factory Podcastrss.fromJson(Map<String, dynamic> json) =>
    _$PodcastrssFromJson(json);
  Map<String, dynamic> toJson() => _$PodcastrssToJson(this);
}

class _ConvertR<R> implements JsonConverter<R, Object>{
  const _ConvertR();
  @override
  R fromJson(Object json){
    return Rss.fromJson(json) as R;
  }
  @override
  Object toJson(R object){
    return object;
  }
}
@JsonSerializable()
class Rss<C>{
  @_ConvertC()
  final C channel;
  Rss({this.channel});
  factory Rss.fromJson(Map<String, dynamic> json) =>
    _$RssFromJson(json);
  Map<String, dynamic> toJson() => _$RssToJson(this);
}

class _ConvertC<C> implements JsonConverter<C, Object>{
  const _ConvertC();
  @override
  C fromJson(Object json){
    return Channel.fromJson(json) as C;
  }
  @override
  Object toJson(C object){
    return object;
  }
}

@JsonSerializable()
class Channel<E> {
  final String title;
  final String link;
  final String description;
  @_ConvertE()
  final List<E> item;
  Channel({this.title, this.link, this.description, this.item});
  factory Channel.fromJson(Map<String, dynamic> json) =>
    _$ChannelFromJson(json);
  Map<String, dynamic> toJson() => _$ChannelToJson(this);
}

class _ConvertE<E> implements JsonConverter<E, Object>{
  const _ConvertE();
  @override
  E fromJson(Object json){
    return EpisodeItem.fromJson(json) as E;
  }
  @override
  Object toJson(E object){
    return object;
  }
}

@JsonSerializable()
class EpisodeItem{
  final String title;
  final String link;
  final String pubDate;
  final String description;
  EpisodeItem({this.title, this.link, this.pubDate, this.description}
  );
  factory EpisodeItem.fromJson(Map<String, dynamic> json) => 
    _$EpisodeItemFromJson(json);
  Map<String, dynamic> toJson() => _$EpisodeItemToJson(this);
}