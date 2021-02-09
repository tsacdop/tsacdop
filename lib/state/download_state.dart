import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../local_storage/key_value_storage.dart';
import '../local_storage/sqflite_localpodcast.dart';
import '../type/episode_task.dart';
import '../type/episodebrief.dart';

void downloadCallback(String id, DownloadTaskStatus status, int progress) {
  developer.log('Homepage callback task in $id  status ($status) $progress');
  final send = IsolateNameServer.lookupPortByName('downloader_send_port');
  send.send([id, status, progress]);
}

void autoDownloadCallback(String id, DownloadTaskStatus status, int progress) {
  developer
      .log('Autodownload callback task in $id  status ($status) $progress');
  final send = IsolateNameServer.lookupPortByName('auto_downloader_send_port');
  send.send([id, status, progress]);
}

//For background auto downlaod
class AutoDownloader {
  final DBHelper _dbHelper = DBHelper();
  final List<EpisodeTask> _episodeTasks = [];
  final Completer _completer = Completer();
  AutoDownloader() {
    FlutterDownloader.registerCallback(autoDownloadCallback);
  }

  bindBackgroundIsolate() {
    var _port = ReceivePort();
    var isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'auto_downloader_send_port');
    if (!isSuccess) {
      IsolateNameServer.removePortNameMapping('auto_downloader_send_port');
      bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];

      for (var episodeTask in _episodeTasks) {
        if (episodeTask.taskId == id) {
          episodeTask.status = status;
          episodeTask.progress = progress;
          if (status == DownloadTaskStatus.complete) {
            _saveMediaId(episodeTask);
          } else if (status == DownloadTaskStatus.failed) {
            _episodeTasks.removeWhere((element) =>
                element.episode.enclosureUrl ==
                episodeTask.episode.enclosureUrl);
            if (_episodeTasks.length == 0) _unbindBackgroundIsolate();
          }
        }
      }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('auto_downloader_send_port');
    _completer?.complete();
  }

  Future<Directory> _getDownloadDirectory() async {
    final storage = KeyValueStorage(downloadPositionKey);
    final index = await storage.getInt();
    final externalDirs = await getExternalStorageDirectories();
    return externalDirs[index];
  }

  Future _saveMediaId(EpisodeTask episodeTask) async {
    final completeTask = await FlutterDownloader.loadTasksWithRawQuery(
        query: "SELECT * FROM task WHERE task_id = '${episodeTask.taskId}'");
    var filePath =
        'file://${path.join(completeTask.first.savedDir, Uri.encodeComponent(completeTask.first.filename))}';
    var fileStat = await File(
            path.join(completeTask.first.savedDir, completeTask.first.filename))
        .stat();
    await _dbHelper.saveMediaId(episodeTask.episode.enclosureUrl, filePath,
        episodeTask.taskId, fileStat.size);
    _episodeTasks.removeWhere((element) =>
        element.episode.enclosureUrl == episodeTask.episode.enclosureUrl);
    if (_episodeTasks.length == 0) _unbindBackgroundIsolate();
  }

  Future startTask(List<EpisodeBrief> episodes,
      {bool showNotification = false}) async {
    for (var episode in episodes) {
      final dir = await _getDownloadDirectory();
      var localPath = path.join(dir.path, episode.feedTitle);
      final saveDir = Directory(localPath);
      var hasExisted = await saveDir.exists();
      if (!hasExisted) {
        saveDir.create();
      }
      var now = DateTime.now();
      var datePlus = now.year.toString() +
          now.month.toString() +
          now.day.toString() +
          now.second.toString();
      var fileName =
          '${episode.title.replaceAll('/', '')}$datePlus.${episode.enclosureUrl.split('/').last.split('.').last}';
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
      _episodeTasks.add(EpisodeTask(episode, taskId));
      var dbHelper = DBHelper();
      await dbHelper.saveDownloaded(episode.enclosureUrl, taskId);
    }
    await _completer.future;
    return;
  }
}

//For download episode inside app
class DownloadState extends ChangeNotifier {
  final DBHelper _dbHelper = DBHelper();
  List<EpisodeTask> _episodeTasks = [];
  List<EpisodeTask> get episodeTasks => _episodeTasks;

  DownloadState() {
    _autoDelete();
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void addListener(VoidCallback listener) async {
    _loadTasks();
    super.addListener(listener);
  }

  Future<void> _loadTasks() async {
    _episodeTasks = [];
    var dbHelper = DBHelper();
    var tasks = await FlutterDownloader.loadTasks();
    if (tasks.isNotEmpty) {
      for (var task in tasks) {
        var episode = await dbHelper.getRssItemWithUrl(task.url);
        if (episode == null) {
          await FlutterDownloader.remove(
              taskId: task.taskId, shouldDeleteContent: true);
        } else {
          if (task.status == DownloadTaskStatus.complete) {
            var exist =
                await File(path.join(task.savedDir, task.filename)).exists();
            if (!exist) {
              await FlutterDownloader.remove(
                  taskId: task.taskId, shouldDeleteContent: true);
              await dbHelper.delDownloaded(episode.enclosureUrl);
            } else {
              if (episode.enclosureUrl == episode.mediaId) {
                var filePath =
                    'file://${path.join(task.savedDir, Uri.encodeComponent(task.filename))}';
                var fileStat =
                    await File(path.join(task.savedDir, task.filename)).stat();
                await dbHelper.saveMediaId(
                    episode.enclosureUrl, filePath, task.taskId, fileStat.size);
              }
              _episodeTasks.add(EpisodeTask(episode, task.taskId,
                  progress: task.progress, status: task.status));
            }
          } else {
            _episodeTasks.add(EpisodeTask(episode, task.taskId,
                progress: task.progress, status: task.status));
          }
        }
      }
    }
    notifyListeners();
  }

  Future<Directory> _getDownloadDirectory() async {
    final storage = KeyValueStorage(downloadPositionKey);
    final index = await storage.getInt();
    final externalDirs = await getExternalStorageDirectories();
    return externalDirs[index];
  }

  void _bindBackgroundIsolate() {
    var _port = ReceivePort();
    var isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }

    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];

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

  Future _saveMediaId(EpisodeTask episodeTask) async {
    episodeTask.status = DownloadTaskStatus.complete;
    final completeTask = await FlutterDownloader.loadTasksWithRawQuery(
        query: "SELECT * FROM task WHERE task_id = '${episodeTask.taskId}'");
    var filePath =
        'file://${path.join(completeTask.first.savedDir, Uri.encodeComponent(completeTask.first.filename))}';
    var fileStat = await File(
            path.join(completeTask.first.savedDir, completeTask.first.filename))
        .stat();
    _dbHelper.saveMediaId(episodeTask.episode.enclosureUrl, filePath,
        episodeTask.taskId, fileStat.size);
    var episode =
        await _dbHelper.getRssItemWithUrl(episodeTask.episode.enclosureUrl);
    _removeTask(episodeTask.episode);
    _episodeTasks.add(EpisodeTask(episode, episodeTask.taskId,
        progress: 100, status: DownloadTaskStatus.complete));
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  EpisodeTask episodeToTask(EpisodeBrief episode) {
    return _episodeTasks
        .firstWhere((task) => task.episode.enclosureUrl == episode.enclosureUrl,
            orElse: () {
      return EpisodeTask(
        episode,
        '',
      );
    });
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }

  Future startTask(EpisodeBrief episode, {bool showNotification = true}) async {
    var isDownloaded = await _dbHelper.isDownloaded(episode.enclosureUrl);
    if (!isDownloaded) {
      final dir = await _getDownloadDirectory();
      var localPath =
          path.join(dir.path, episode.feedTitle?.replaceAll('/', ''));
      final saveDir = Directory(localPath);
      var hasExisted = await saveDir.exists();
      if (!hasExisted) {
        await saveDir.create();
      }
      var now = DateTime.now();
      var datePlus = now.year.toString() +
          now.month.toString() +
          now.day.toString() +
          now.second.toString();
      var fileName =
          '${episode.title.replaceAll('/', '')}$datePlus.${episode.enclosureUrl.split('/').last.split('.').last}';
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
      _episodeTasks.add(EpisodeTask(episode, taskId));
      await _dbHelper.saveDownloaded(episode.enclosureUrl, taskId);
      notifyListeners();
    }
  }

  Future pauseTask(EpisodeBrief episode) async {
    var task = episodeToTask(episode);
    if (task.progress > 0) {
      await FlutterDownloader.pause(taskId: task.taskId);
    }
    notifyListeners();
  }

  Future resumeTask(EpisodeBrief episode) async {
    var task = episodeToTask(episode);
    var newTaskId = await FlutterDownloader.resume(taskId: task.taskId);
    await FlutterDownloader.remove(taskId: task.taskId);
    var index = _episodeTasks.indexOf(task);
    _episodeTasks[index] = task.copyWith(taskId: newTaskId);
    notifyListeners();
    await _dbHelper.saveDownloaded(episode.enclosureUrl, newTaskId);
  }

  Future retryTask(EpisodeBrief episode) async {
    var task = episodeToTask(episode);
    var newTaskId = await FlutterDownloader.retry(taskId: task.taskId);
    await FlutterDownloader.remove(taskId: task.taskId);
    var index = _episodeTasks.indexOf(task);
    _episodeTasks[index] = task.copyWith(taskId: newTaskId);
    notifyListeners();
    await _dbHelper.saveDownloaded(episode.enclosureUrl, newTaskId);
  }

  Future removeTask(EpisodeBrief episode) async {
    var task = episodeToTask(episode);
    await FlutterDownloader.remove(
        taskId: task.taskId, shouldDeleteContent: false);
  }

  Future<void> delTask(EpisodeBrief episode) async {
    var task = episodeToTask(episode);
    await FlutterDownloader.remove(
        taskId: task.taskId, shouldDeleteContent: true);
    await _dbHelper.delDownloaded(episode.enclosureUrl);

    for (var episodeTask in _episodeTasks) {
      if (episodeTask.taskId == task.taskId) {
        episodeTask.status = DownloadTaskStatus.undefined;
      }
      notifyListeners();
    }
    _removeTask(episode);
  }

  void _removeTask(EpisodeBrief episode) {
    _episodeTasks.removeWhere((element) => element.episode == episode);
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
      var episodes = await _dbHelper.getOutdatedEpisode(deadline,
          deletePlayed: deletePlayed);
      if (episodes.isNotEmpty) {
        for (var episode in episodes) {
          await delTask(episode);
        }
      }
      final tasks = await FlutterDownloader.loadTasksWithRawQuery(
          query:
              'SELECT * FROM task WHERE time_created < $deadline AND status = 3');
      for (var task in tasks) {
        FlutterDownloader.remove(
            taskId: task.taskId, shouldDeleteContent: true);
      }
    }
  }
}
