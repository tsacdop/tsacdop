import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:equatable/equatable.dart';

import 'episodebrief.dart';

class EpisodeTask extends Equatable {
  final String taskId;
  final EpisodeBrief episode;
  final int progress;
  final DownloadTaskStatus status;
  EpisodeTask(
    this.episode,
    this.taskId, {
    this.progress = 0,
    this.status = DownloadTaskStatus.undefined,
  });

  EpisodeTask copyWith({String taskId, int progress, DownloadTaskStatus status}) {
    return EpisodeTask(episode, taskId ?? this.taskId,
        progress: progress ?? this.progress, status: status ?? this.status);
  }

  @override
  List<Object> get props => [taskId];
}
