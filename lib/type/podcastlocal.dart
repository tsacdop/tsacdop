import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../util/extension_helper.dart';

class PodcastLocal extends Equatable {
  final String? title;
  final String? imageUrl;
  final String rssUrl;
  final String? author;

  final String? primaryColor;
  final String? id;
  final String? imagePath;
  final String? provider;
  final String? link;

  final String? description;

  final int? updateCount;
  final int? episodeCount;

  final List<String> funding;

  //set setUpdateCount(i) => updateCount = i;

  //set setEpisodeCount(i) => episodeCount = i;

  PodcastLocal(
    this.title,
    this.imageUrl,
    this.rssUrl,
    this.primaryColor,
    this.author,
    this.id,
    this.imagePath,
    this.provider,
    this.link,
    this.funding, {
    this.description = '',
    this.updateCount = 0,
    this.episodeCount = 0,
  });

  ImageProvider get avatarImage {
    return (File(imagePath!).existsSync()
            ? FileImage(File(imagePath!))
            : const AssetImage('assets/avatar_backup.png'))
        as ImageProvider<Object>;
  }

  Color backgroudColor(BuildContext context) {
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

  PodcastLocal copyWith({int? updateCount, int? episodeCount}) {
    return PodcastLocal(
      title,
      imageUrl,
      rssUrl,
      primaryColor,
      author,
      id,
      imagePath,
      provider,
      link,
      funding,
      description: description,
      updateCount: updateCount ?? 0,
      episodeCount: episodeCount ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, rssUrl];
}
