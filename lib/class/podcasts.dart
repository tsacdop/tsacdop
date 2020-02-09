import 'package:json_annotation/json_annotation.dart';
part 'podcasts.g.dart';

@JsonSerializable()
class Podcast<E, F>{
  final String version;
  final String title;
  @JsonKey(name: 'homepage_url')
  final String homepageUrl;
  @JsonKey(name: 'feed_url')
  final String feedUrl;
  final String description;
  @JsonKey(name: '_fireside')
  @_ConvertF()
  final F fireSide;
  @JsonKey(name: 'items')
  @_ConvertE()
  final List<E> items;
  Podcast(
    {this.version, this.title, this.homepageUrl, this.feedUrl, this.description, this.fireSide, this.items}
  );
  factory Podcast.fromJson(Map<String, dynamic> json) => 
    _$PodcastFromJson<E, F>(json);
  Map<String, dynamic> toJson() => _$PodcastToJson(this);
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
class _ConvertF<F> implements JsonConverter<F, Object>{
  const _ConvertF();
  @override
  F fromJson(Object json){
    return FireSide.fromJson(json) as F;
  }
  @override
  Object toJson(F object){
    return object;
  }
}

@JsonSerializable()

class FireSide{
  final String pubdate;
  final bool explicit;
  final String copyright;
  final String owner;
  final String image;
  FireSide({this.pubdate, this.explicit, this.copyright, this.owner, this.image});
  factory FireSide.fromJson(Map<String, dynamic> json) =>
    _$FireSideFromJson(json);
  Map<String, dynamic> toJson() => _$FireSideToJson(this);
}

@JsonSerializable()
class EpisodeItem<A>{
  final String id;
  final String title;
  final String url;
  @JsonKey(name: 'content_text')
  final String contentText;
  @JsonKey(name: 'content_html')
  final String contentHtml;
  final String summary;
  @JsonKey(name: 'date_published')
  final String datePublished;
  @_ConvertA()
  final List<A> attachments;
  EpisodeItem({this.id, this.title, this.url, this.contentText, this.contentHtml, this.summary, this.datePublished, this.attachments}
  );
  factory EpisodeItem.fromJson(Map<String, dynamic> json) => 
    _$EpisodeItemFromJson<A>(json);
  Map<String, dynamic> toJson() => _$EpisodeItemToJson(this);
}

class _ConvertA<A> implements JsonConverter<A, Object> {
  const _ConvertA();
  @override
  A fromJson(Object json){
    return Attachment.fromJson(json) as A;
  }
  @override
  Object toJson(A object){
    return object;
  }
}

@JsonSerializable()
class Attachment{
  final String url;
  @JsonKey(name: 'mime_type')
  final String mimeType;
  @JsonKey(name: 'size_in_bytes')
  final int sizeInBytes;
  @JsonKey(name: 'duration_in_seconds')
  final int durationInSeconds;
  Attachment(
    {this.url, this.mimeType, this.sizeInBytes, this.durationInSeconds}
  );
  factory Attachment.fromJson(Map<String, dynamic> json) =>
    _$AttachmentFromJson(json);
  Map<String, dynamic> toJson() => _$AttachmentToJson(this);
}