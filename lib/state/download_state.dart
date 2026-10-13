import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../local_storage/key_value_storage.dart';
import '../local_storage/sqflite_localpodcast.dart';
import '../type/episode_task.dart';
import '../type/episodebrief.dart';

@pragma('vm:entry-point')
void downloadCallback(String id, int rawStatus, int progress) {
  final status = DownloadTaskStatus.fromInt(rawStatus);
  developer.log('Homepage callback task in $id  status ($status) $progress');
  final send = IsolateNameServer.lookupPortByName('downloader_send_port');
  send?.send([id, status, progress]);
}

@pragma('vm:entry-point')
void autoDownloadCallback(String id, int rawStatus, int progress) {
  final status = DownloadTaskStatus.fromInt(rawStatus);
  developer.log(
    'Autodownload callback task in $id  status ($status) $progress',
  );
  final send = IsolateNameServer.lookupPortByName('auto_downloader_send_port');
  send?.send([id, status, progress]);
}

//For background auto downlaod
class AutoDownloader {
  final DBHelper _dbHelper;
  final List<EpisodeTask> _episodeTasks = [];
  final Completer _completer = Completer();
  final Completer<void> _enqueueReady = Completer<void>();
  ReceivePort? _port;
  bool _enqueuing = false;
  AutoDownloader({DBHelper? dbHelper}) : _dbHelper = dbHelper ?? DBHelper() {
    FlutterDownloader.registerCallback(autoDownloadCallback);
  }

  void bindBackgroundIsolate() {
    var port = ReceivePort();
    _port = port;
    var isSuccess = IsolateNameServer.registerPortWithName(
      port.sendPort,
      'auto_downloader_send_port',
    );
    if (!isSuccess) {
      port.close();
      IsolateNameServer.removePortNameMapping('auto_downloader_send_port');
      bindBackgroundIsolate();
      return;
    }
    port.listen((dynamic data) {
      String? id = data[0];
      DownloadTaskStatus? status = data[1];
      int? progress = data[2];

      for (var episodeTask in _episodeTasks.toList()) {
        if (episodeTask.taskId == id) {
          episodeTask.status = status;
          episodeTask.progress = progress;
          if (status == DownloadTaskStatus.complete) {
            _saveMediaId(episodeTask);
          } else if (status == DownloadTaskStatus.failed ||
              status == DownloadTaskStatus.canceled) {
            _episodeTasks.removeWhere(
              (element) =>
                  element.episode!.enclosureUrl ==
                  episodeTask.episode!.enclosureUrl,
            );
            _finishIfIdle();
          }
        }
      }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('auto_downloader_send_port');
    _port?.close();
    _port = null;
    if (!_completer.isCompleted) _completer.complete();
  }

  void _finishIfIdle() {
    if (!_enqueuing && _episodeTasks.isEmpty) _unbindBackgroundIsolate();
  }

  Future<Directory> _getDownloadDirectory() async {
    final storage = KeyValueStorage(downloadPositionKey);
    final index = await storage.getInt();
    final externalDirs = await getExternalStorageDirectories();
    return externalDirs![index];
  }

  Future _saveMediaId(EpisodeTask episodeTask) async {
    // A very small file can finish before enqueue has saved its task ID.
    await _enqueueReady.future;
    final completeTask = await FlutterDownloader.loadTasksWithRawQuery(
      query: "SELECT * FROM task WHERE task_id = '${episodeTask.taskId}'",
    );
    if (completeTask == null || completeTask.isEmpty) {
      _episodeTasks.remove(episodeTask);
      _finishIfIdle();
      return;
    }
    var filePath =
        'file://${path.join(completeTask.first.savedDir, Uri.encodeComponent(completeTask.first.filename!))}';
    var fileStat = await File(
      path.join(completeTask.first.savedDir, completeTask.first.filename),
    ).stat();
    await _dbHelper.saveMediaId(
      episodeTask.episode!.enclosureUrl,
      filePath,
      episodeTask.taskId,
      fileStat.size,
    );
    _episodeTasks.removeWhere(
      (element) =>
          element.episode!.enclosureUrl == episodeTask.episode!.enclosureUrl,
    );
    _finishIfIdle();
  }

  Future startTask(
    List<EpisodeBrief> episodes, {
    bool showNotification = false,
  }) async {
    final tasks = await FlutterDownloader.loadTasks();
    if (tasks == null) throw StateError('Could not load download tasks');
    final queuedUrls = tasks.map((task) => task.url).toSet();
    _enqueuing = true;
    try {
      for (var episode in episodes) {
        if (queuedUrls.contains(episode.enclosureUrl) ||
            await _dbHelper.isDownloaded(episode.enclosureUrl)) {
          continue;
        }
        final dir = await _getDownloadDirectory();
        var localPath = path.join(dir.path, episode.feedTitle);
        final saveDir = Directory(localPath);
        var hasExisted = await saveDir.exists();
        if (!hasExisted) {
          await saveDir.create();
        }
        var datePlus = DateTime.now().microsecondsSinceEpoch.toString();
        var fileName =
            '${episode.title!.replaceAll('/', '')}$datePlus.${episode.enclosureUrl.split('/').last.split('.').last}';
        if (fileName.length > 100) {
          fileName = fileName.substring(fileName.length - 100);
        }
        var taskId = await FlutterDownloader.enqueue(
          fileName: fileName,
          url: episode.enclosureUrl,
          savedDir: localPath,
          showNotification: showNotification,
          openFileFromNotification: false,
        );
        if (taskId == null) continue;
        queuedUrls.add(episode.enclosureUrl);
        _episodeTasks.add(EpisodeTask(episode, taskId));
        await _dbHelper.saveDownloaded(episode.enclosureUrl, taskId);
      }
    } finally {
      _enqueuing = false;
      _enqueueReady.complete();
      _finishIfIdle();
    }
    await _completer.future;
    return;
  }
}

//For download episode inside app
class DownloadState extends ChangeNotifier {
  final DBHelper _dbHelper;
  Future<void> _operations = Future<void>.value();
  ReceivePort? _port;
  List<EpisodeTask> _episodeTasks = [];
  List<EpisodeTask> get episodeTasks => _episodeTasks;

  DownloadState({DBHelper? dbHelper}) : _dbHelper = dbHelper ?? DBHelper() {
    _autoDelete();
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);
  }

  // Loading and completion must finish before deletion clears the same episode.
  Future<T> _serialize<T>(Future<T> Function() operation) {
    final result = _operations.then((_) => operation());
    _operations = result.then<void>((_) {}, onError: (Object error) {});
    return result;
  }

  @override
  void addListener(VoidCallback listener) async {
    _loadTasks();
    super.addListener(listener);
  }

  Future<void> _loadTasks() => _serialize(() async {
    _episodeTasks = [];
    var dbHelper = _dbHelper;
    var tasks = await FlutterDownloader.loadTasks();
    if (tasks != null && tasks.isNotEmpty) {
      for (var task in tasks) {
        var episode = await dbHelper.getRssItemWithUrl(task.url);
        if (episode == null) {
          await FlutterDownloader.remove(
            taskId: task.taskId,
            shouldDeleteContent: true,
          );
        } else {
          if (task.status == DownloadTaskStatus.complete) {
            var exist = await File(path.join(task.savedDir, task.filename))
                .exists();
            if (!exist) {
              await FlutterDownloader.remove(
                taskId: task.taskId,
                shouldDeleteContent: true,
              );
              if (episode.downloaded == task.taskId) {
                await dbHelper.delDownloaded(episode.enclosureUrl);
              }
            } else {
              if (episode.enclosureUrl == episode.mediaId) {
                var filePath =
                    'file://${path.join(task.savedDir, Uri.encodeComponent(task.filename!))}';
                var fileStat = await File(
                  path.join(task.savedDir, task.filename),
                ).stat();
                final saved = await dbHelper.saveMediaId(
                  episode.enclosureUrl,
                  filePath,
                  task.taskId,
                  fileStat.size,
                );
                if (saved == 0) continue;
                episode = await dbHelper.getRssItemWithUrl(task.url);
              }
              _episodeTasks.add(
                EpisodeTask(
                  episode,
                  task.taskId,
                  progress: task.progress,
                  status: task.status,
                ),
              );
            }
          } else {
            _episodeTasks.add(
              EpisodeTask(
                episode,
                task.taskId,
                progress: task.progress,
                status: task.status,
              ),
            );
          }
        }
      }
    }
    notifyListeners();
  });

  Future<Directory> _getDownloadDirectory() async {
    final storage = KeyValueStorage(downloadPositionKey);
    final index = await storage.getInt();
    final externalDirs = await getExternalStorageDirectories();
    return externalDirs![index];
  }

  void _bindBackgroundIsolate() {
    final port = ReceivePort();
    _port = port;
    final isSuccess = IsolateNameServer.registerPortWithName(
      port.sendPort,
      'downloader_send_port',
    );
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }

    port.listen((dynamic data) {
      String? id = data[0];
      DownloadTaskStatus? status = data[1];
      int? progress = data[2];

      for (var episodeTask in _episodeTasks) {
        if (episodeTask.taskId == id) {
          episodeTask.status = status;
          episodeTask.progress = progress;
          if (status == DownloadTaskStatus.complete) {
            _saveMediaId(episodeTask).then((value) {
              notifyListeners();
            });
          } else {
            notifyListeners();
          }
        }
      }
    });
  }

  Future<void> _saveMediaId(EpisodeTask episodeTask) => _serialize(() async {
    if (!_episodeTasks.any((task) => task.taskId == episodeTask.taskId)) return;
    final completeTask = await FlutterDownloader.loadTasksWithRawQuery(
      query: "SELECT * FROM task WHERE task_id = '${episodeTask.taskId}'",
    );
    if (completeTask == null || completeTask.isEmpty) return;
    final filePath =
        'file://${path.join(completeTask.first.savedDir, Uri.encodeComponent(completeTask.first.filename!))}';
    final fileStat = await File(
      path.join(completeTask.first.savedDir, completeTask.first.filename),
    ).stat();
    final saved = await _dbHelper.saveMediaId(
      episodeTask.episode!.enclosureUrl,
      filePath,
      episodeTask.taskId,
      fileStat.size,
    );
    if (saved == 0) return;
    final episode = await _dbHelper.getRssItemWithUrl(
      episodeTask.episode!.enclosureUrl,
    );
    _removeTask(episodeTask.episode);
    _episodeTasks.add(
      EpisodeTask(
        episode,
        episodeTask.taskId,
        progress: 100,
        status: DownloadTaskStatus.complete,
      ),
    );
  });

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    _port?.close();
    _port = null;
  }

  EpisodeTask episodeToTask(EpisodeBrief? episode) {
    return _episodeTasks.firstWhere(
      (task) => task.episode!.enclosureUrl == episode!.enclosureUrl,
      orElse: () {
        return EpisodeTask(episode, '');
      },
    );
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }

  Future<void> startTask(
    EpisodeBrief episode, {
    bool showNotification = true,
  }) => _serialize(() async {
    final tasks = await FlutterDownloader.loadTasks();
    if (tasks == null) throw StateError('Could not load download tasks');
    if (tasks.any((task) => task.url == episode.enclosureUrl)) return;
    var isDownloaded = await _dbHelper.isDownloaded(episode.enclosureUrl);
    if (!isDownloaded) {
      final dir = await _getDownloadDirectory();
      var localPath = path.join(
        dir.path,
        episode.feedTitle?.replaceAll('/', ''),
      );
      final saveDir = Directory(localPath);
      var hasExisted = await saveDir.exists();
      if (!hasExisted) {
        await saveDir.create();
      }
      var datePlus = DateTime.now().microsecondsSinceEpoch.toString();
      var fileName =
          '${episode.title!.replaceAll('/', '')}$datePlus.${episode.enclosureUrl.split('/').last.split('.').last}';
      if (fileName.length > 100) {
        fileName = fileName.substring(fileName.length - 100);
      }
      var taskId = await FlutterDownloader.enqueue(
        fileName: fileName,
        url: episode.enclosureUrl,
        savedDir: localPath,
        showNotification: showNotification,
        openFileFromNotification: false,
      );
      if (taskId == null) return;
      _episodeTasks.add(EpisodeTask(episode, taskId));
      await _dbHelper.saveDownloaded(episode.enclosureUrl, taskId);
      notifyListeners();
    }
  });

  Future<void> pauseTask(EpisodeBrief? episode) => _serialize(() async {
    var task = episodeToTask(episode);
    if (task.taskId == '') return;
    if (task.progress! > 0) {
      await FlutterDownloader.pause(taskId: task.taskId!);
    }
    notifyListeners();
  });

  Future<void> resumeTask(EpisodeBrief episode) => _serialize(() async {
    var task = episodeToTask(episode);
    if (task.taskId == '') return;
    var newTaskId = await FlutterDownloader.resume(taskId: task.taskId!);
    if (newTaskId == null) return;
    await FlutterDownloader.remove(taskId: task.taskId!);
    var index = _episodeTasks.indexOf(task);
    _episodeTasks[index] = task.copyWith(taskId: newTaskId);
    notifyListeners();
    await _dbHelper.saveDownloaded(episode.enclosureUrl, newTaskId);
  });

  Future<void> retryTask(EpisodeBrief episode) => _serialize(() async {
    var task = episodeToTask(episode);
    if (task.taskId == '') return;
    var newTaskId = await FlutterDownloader.retry(taskId: task.taskId!);
    if (newTaskId == null) return;
    await FlutterDownloader.remove(taskId: task.taskId!);
    var index = _episodeTasks.indexOf(task);
    _episodeTasks[index] = task.copyWith(taskId: newTaskId);
    notifyListeners();
    await _dbHelper.saveDownloaded(episode.enclosureUrl, newTaskId);
  });

  Future removeTask(EpisodeBrief episode) async {
    var task = episodeToTask(episode);
    await FlutterDownloader.remove(
      taskId: task.taskId!,
      shouldDeleteContent: false,
    );
  }

  Future<void> delTask(EpisodeBrief episode) => _serialize(() async {
    final tasks = await FlutterDownloader.loadTasks();
    if (tasks == null) throw StateError('Could not load download tasks');
    final matching = tasks.where((task) => task.url == episode.enclosureUrl);
    final files = <String>{};
    final stored = await _dbHelper.getRssItemWithUrl(episode.enclosureUrl);
    final mediaUri = Uri.tryParse(stored?.mediaId ?? '');
    if (mediaUri != null && mediaUri.scheme == 'file') {
      files.add(File.fromUri(mediaUri).path);
    }
    for (final task in matching) {
      if (task.filename != null) {
        files.add(path.join(task.savedDir, task.filename));
      }
      await FlutterDownloader.remove(
        taskId: task.taskId,
        shouldDeleteContent: true,
      );
    }
    // The plugin swallows platform errors. Check its database before reporting
    // success, and remove any file it failed to delete from app storage.
    final remaining = await FlutterDownloader.loadTasks();
    if (remaining == null ||
        remaining.any((task) => task.url == episode.enclosureUrl)) {
      throw StateError('Could not remove download tasks');
    }
    for (final filePath in files) {
      final file = File(filePath);
      if (await file.exists()) await file.delete();
    }
    await _dbHelper.delDownloaded(episode.enclosureUrl);
    _removeTask(episode);
  });

  void _removeTask(EpisodeBrief? episode) {
    _episodeTasks.removeWhere(
      (element) => element.episode?.enclosureUrl == episode?.enclosureUrl,
    );
    notifyListeners();
  }

  Future<void> _autoDelete() async {
    developer.log('Start auto delete outdated episodes');
    final autoDeleteStorage = KeyValueStorage(autoDeleteKey);
    final deletePlayedStorage = KeyValueStorage(deleteAfterPlayedKey);
    final autoDelete = await autoDeleteStorage.getInt();
    final deletePlayed = await deletePlayedStorage.getBool(defaultValue: false);
    if (autoDelete == 0) {
      await autoDeleteStorage.saveInt(30);
    } else if (autoDelete > 0) {
      var deadline = DateTime.now()
          .subtract(Duration(days: autoDelete))
          .millisecondsSinceEpoch;
      var episodes = await _dbHelper.getOutdatedEpisode(
        deadline,
        deletePlayed: deletePlayed,
      );
      if (episodes.isNotEmpty) {
        for (var episode in episodes) {
          await delTask(episode);
        }
      }
      final tasks = await FlutterDownloader.loadTasksWithRawQuery(
        query:
            'SELECT * FROM task WHERE time_created < $deadline AND status = 3',
      );
      for (var task in tasks ?? []) {
        await FlutterDownloader.remove(
          taskId: task.taskId,
          shouldDeleteContent: true,
        );
      }
    }
  }
}
