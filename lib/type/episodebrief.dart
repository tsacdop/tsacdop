import 'dart:ui';

import 'package:audio_service/audio_service.dart';

class EpisodeBrief {
  final String title;
  final String description;
  final int pubDate;
  final int enclosureLength;
  final String enclosureUrl;
  final String feedTitle;
  final String primaryColor;
  final int liked;
  final String downloaded;
  final int duration;
  final int explicit;
  final String imagePath;
  final String mediaId;
  final int isNew;
  final int skipSeconds;
  final int downloadDate;
  EpisodeBrief(
      this.title,
      this.enclosureUrl,
      this.enclosureLength,
      this.pubDate,
      this.feedTitle,
      this.primaryColor,
      this.duration,
      this.explicit,
      this.imagePath,
      {this.mediaId,
      this.liked,
      this.downloaded,
      this.isNew,
      this.skipSeconds,
      this.description = '',
      this.downloadDate = 0})
      : assert(enclosureUrl != null);

  MediaItem toMediaItem() {
    return MediaItem(
        id: mediaId,
        title: title,
        artist: feedTitle,
        album: feedTitle,
        duration: Duration.zero,
        artUri: 'file://$imagePath',
        extras: {'skip': skipSeconds});
  }

  @override
  bool operator ==(Object episode) =>
      episode is EpisodeBrief &&
      episode.title == title &&
      episode.enclosureUrl == enclosureUrl;

  @override
  int get hashCode => hashValues(enclosureUrl, title);
}
