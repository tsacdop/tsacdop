import 'package:flutter_downloader/flutter_downloader.dart';

import 'episodebrief.dart';

class EpisodeTask {
  final String? taskId;
  final EpisodeBrief? episode;
  int? progress;
  DownloadTaskStatus? status;
  EpisodeTask(this.episode, this.taskId,
      {this.progress = 0, this.status = DownloadTaskStatus.undefined});

  EpisodeTask copyWith(
      {String? taskId, int? progress, DownloadTaskStatus? status}) {
    return EpisodeTask(episode, taskId ?? this.taskId,
        progress: progress ?? this.progress, status: status ?? this.status);
  }
}
