import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:equatable/equatable.dart';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import '../util/extension_helper.dart';

class EpisodeBrief extends Equatable {
  final String? title;
  final String description;
  final int? pubDate;
  final int? enclosureLength;
  final String enclosureUrl;
  final String? feedTitle;
  final String? primaryColor;
  final int? liked;
  final String? downloaded;
  final int? duration;
  final int? explicit;
  final String? imagePath;
  final String? mediaId;
  final int? isNew;
  final int? skipSecondsStart;
  final int? skipSecondsEnd;
  final int? downloadDate;
  final String? episodeImage;
  final String? chapterLink;
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
      this.isNew,
      {this.mediaId,
      this.liked,
      this.downloaded,
      this.skipSecondsStart,
      this.skipSecondsEnd,
      this.description = '',
      this.downloadDate = 0,
      this.chapterLink = '',
      this.episodeImage = ''})
      : assert(enclosureUrl != null);

  MediaItem toMediaItem() {
    return MediaItem(
        id: mediaId!,
        title: title!,
        artist: feedTitle,
        album: feedTitle,
        duration: Duration.zero,
        artUri: Uri.parse(imagePath == '' ? episodeImage! : 'file://$imagePath'),
        extras: {
          'skipSecondsStart': skipSecondsStart,
          'skipSecondsEnd': skipSecondsEnd
        });
  }

  ImageProvider get avatarImage {
    return File(imagePath!).existsSync()
        ? FileImage(File(imagePath!))
        : File(episodeImage!).existsSync()
            ? FileImage(File(episodeImage!))
            : ((episodeImage != '')
                ? CachedNetworkImageProvider(episodeImage!)
                : AssetImage('assets/avatar_backup.png')) as ImageProvider<Object>;
  }

  Color backgroudColor(BuildContext context) {
    if (primaryColor == '') return context.accentColor;
    return context.brightness == Brightness.light
        ? primaryColor!.colorizedark()
        : primaryColor!.colorizeLight();
  }
  
  Color cardColor(BuildContext context) {
    final schema = ColorScheme.fromSeed(
      seedColor: primaryColor!.colorizedark(),
      brightness: context.brightness,
    );
    return schema.primaryContainer;
  }

  EpisodeBrief copyWith({
    String? mediaId,
  }) =>
      EpisodeBrief(title, enclosureUrl, enclosureLength, pubDate, feedTitle,
          primaryColor, duration, explicit, imagePath, isNew,
          mediaId: mediaId ?? this.mediaId,
          downloaded: downloaded,
          skipSecondsStart: skipSecondsStart,
          skipSecondsEnd: skipSecondsEnd,
          description: description,
          downloadDate: downloadDate);

  @override
  List<Object?> get props => [enclosureUrl, title];
}
