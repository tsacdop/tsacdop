import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:equatable/equatable.dart';

import 'episodebrief.dart';

class EpisodeTask extends Equatable {
  final String taskId;
  final EpisodeBrief episode;
  int progress;
  DownloadTaskStatus status;
  EpisodeTask(
    this.episode,
    this.taskId, {
    this.progress = 0,
    this.status = DownloadTaskStatus.undefined,
  });

  EpisodeTask copyWith({String taskId}) {
    return EpisodeTask(episode, taskId ?? this.taskId,
        progress: progress, status: status);
  }

  @override
  List<Object> get props => [taskId];
}
