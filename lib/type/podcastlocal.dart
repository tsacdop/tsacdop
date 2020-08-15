import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../util/extension_helper.dart';

class PodcastLocal extends Equatable {
  final String title;
  final String imageUrl;
  final String rssUrl;
  final String author;

  final String primaryColor;
  final String id;
  final String imagePath;
  final String provider;
  final String link;

  final String description;

  int _upateCount;
  int get updateCount => _upateCount;
  set updateCount(i) => _upateCount = i;

  int _episodeCount;
  int get episodeCount => _episodeCount;
  set episodeCount(i) => _episodeCount = i;

  PodcastLocal(this.title, this.imageUrl, this.rssUrl, this.primaryColor,
      this.author, this.id, this.imagePath, this.provider, this.link,
      {this.description = '', int upateCount, int episodeCount})
      : assert(rssUrl != null),
        _episodeCount = episodeCount ?? 0,
        _upateCount = upateCount ?? 0;

  ImageProvider get avatarImage {
    return File(imagePath).existsSync()
        ? FileImage(File(imagePath))
        : const AssetImage('assets/avatar_backup.png');
  }

  Color backgroudColor(BuildContext context) {
    return context.brightness == Brightness.light
        ? primaryColor.colorizedark()
        : primaryColor.colorizeLight();
  }

  @override
  List<Object> get props => [id, rssUrl];
}
