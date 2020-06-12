import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../local_storage/key_value_storage.dart';
import '../local_storage/sqflite_localpodcast.dart';
import '../type/episodebrief.dart';

class EpisodeTask {
  final String taskId;
  int progress;
  DownloadTaskStatus status;
  final EpisodeBrief episode;
  EpisodeTask(
    this.episode,
    this.taskId, {
    this.progress = 0,
    this.status = DownloadTaskStatus.undefined,
  });
}

void downloadCallback(String id, DownloadTaskStatus status, int progress) {
  print('Homepage callback task in $id  status ($status) $progress');
  final SendPort send =
      IsolateNameServer.lookupPortByName('downloader_send_port');
  send.send([id, status, progress]);
}

void autoDownloadCallback(String id, DownloadTaskStatus status, int progress) {
  print('Autodownload callback task in $id  status ($status) $progress');
  final SendPort send =
      IsolateNameServer.lookupPortByName('auto_downloader_send_port');
  send.send([id, status, progress]);
}

//For background auto downlaod
class AutoDownloader {
  DBHelper dbHelper = DBHelper();
  List<EpisodeTask> _episodeTasks = [];
  Completer _completer = Completer();
  AutoDownloader() {
    FlutterDownloader.registerCallback(autoDownloadCallback);
  }

  bindBackgroundIsolate() {
    print('start listen');
    ReceivePort _port = ReceivePort();
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'auto_downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      //bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      _episodeTasks.forEach((episodeTask) {
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
      });
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('auto_downloader_send_port');
    _completer?.complete();
  }

  Future _saveMediaId(EpisodeTask episodeTask) async {
    final completeTask = await FlutterDownloader.loadTasksWithRawQuery(
        query: "SELECT * FROM task WHERE task_id = '${episodeTask.taskId}'");
    String filePath = 'file://' +
        path.join(completeTask.first.savedDir,
            Uri.encodeComponent(completeTask.first.filename));
    await dbHelper.saveMediaId(
        episodeTask.episode.enclosureUrl, filePath, episodeTask.taskId);
    _episodeTasks.removeWhere((element) =>
        element.episode.enclosureUrl == episodeTask.episode.enclosureUrl);
    if (_episodeTasks.length == 0) _unbindBackgroundIsolate();
  }

  Future startTask(List<EpisodeBrief> episodes,
      {bool showNotification = true}) async {
    episodes.forEach((episode) async {
      final dir = await getExternalStorageDirectory();
      String localPath = path.join(dir.path, episode.feedTitle);
      final saveDir = Directory(localPath);
      bool hasExisted = await saveDir.exists();
      if (!hasExisted) {
        saveDir.create();
      }
      DateTime now = DateTime.now();
      String datePlus = now.year.toString() +
          now.month.toString() +
          now.day.toString() +
          now.second.toString();
      String fileName = episode.title +
          datePlus +
          '.' +
          episode.enclosureUrl.split('/').last.split('.').last;
      String taskId = await FlutterDownloader.enqueue(
        fileName: fileName,
        url: episode.enclosureUrl,
        savedDir: localPath,
        showNotification: showNotification,
        openFileFromNotification: false,
      );
      _episodeTasks.add(EpisodeTask(episode, taskId));
      var dbHelper = DBHelper();
      await dbHelper.saveDownloaded(episode.enclosureUrl, taskId);
    });
    await _completer.future;
    return;
  }
}

//For download episode inside app
class DownloadState extends ChangeNotifier {
  DBHelper dbHelper = DBHelper();
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

  _loadTasks() async {
    _episodeTasks = [];
    DBHelper dbHelper = DBHelper();
    var tasks = await FlutterDownloader.loadTasks();
    if (tasks.length != 0)
      await Future.forEach(tasks, (DownloadTask task) async {
        EpisodeBrief episode = await dbHelper.getRssItemWithUrl(task.url);
        _episodeTasks.add(EpisodeTask(episode, task.taskId,
            progress: task.progress, status: task.status));
      });
    notifyListeners();
  }

  void _bindBackgroundIsolate() {
    ReceivePort _port = ReceivePort();
    bool isSuccess = IsolateNameServer.registerPortWithName(
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
      _episodeTasks.forEach((episodeTask) {
        if (episodeTask.taskId == id) {
          episodeTask.status = status;
          episodeTask.progress = progress;
          if (status == DownloadTaskStatus.complete) {
            _saveMediaId(episodeTask).then((value) {
              notifyListeners();
            });
          } else
            notifyListeners();
        }
      });
    });
  }

  Future _saveMediaId(EpisodeTask episodeTask) async {
    episodeTask.status = DownloadTaskStatus.complete;
    final completeTask = await FlutterDownloader.loadTasksWithRawQuery(
        query: "SELECT * FROM task WHERE task_id = '${episodeTask.taskId}'");
    String filePath = 'file://' +
        path.join(completeTask.first.savedDir,
            Uri.encodeComponent(completeTask.first.filename));
    dbHelper.saveMediaId(
        episodeTask.episode.enclosureUrl, filePath, episodeTask.taskId);
    EpisodeBrief episode =
        await dbHelper.getRssItemWithUrl(episodeTask.episode.enclosureUrl);
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
    final dir = await getExternalStorageDirectory();
    String localPath = path.join(dir.path, episode.feedTitle);
    final saveDir = Directory(localPath);
    bool hasExisted = await saveDir.exists();
    if (!hasExisted) {
      saveDir.create();
    }
    DateTime now = DateTime.now();
    String datePlus = now.year.toString() +
        now.month.toString() +
        now.day.toString() +
        now.second.toString();
    String fileName = episode.title +
        datePlus +
        '.' +
        episode.enclosureUrl.split('/').last.split('.').last;
    String taskId = await FlutterDownloader.enqueue(
      fileName: fileName,
      url: episode.enclosureUrl,
      savedDir: localPath,
      showNotification: showNotification,
      openFileFromNotification: false,
    );
    _episodeTasks.add(EpisodeTask(episode, taskId));
    var dbHelper = DBHelper();
    await dbHelper.saveDownloaded(episode.enclosureUrl, taskId);
    notifyListeners();
  }

  Future pauseTask(EpisodeBrief episode) async {
    EpisodeTask task = episodeToTask(episode);
    await FlutterDownloader.pause(taskId: task.taskId);
  }

  Future resumeTask(EpisodeBrief episode) async {
    EpisodeTask task = episodeToTask(episode);
    String newTaskId = await FlutterDownloader.resume(taskId: task.taskId);
    int index = _episodeTasks.indexOf(task);
    _removeTask(episode);
    FlutterDownloader.remove(taskId: task.taskId);
    var dbHelper = DBHelper();
    _episodeTasks.insert(index, EpisodeTask(episode, newTaskId));
    await dbHelper.saveDownloaded(newTaskId, episode.enclosureUrl);
  }

  Future retryTask(EpisodeBrief episode) async {
    EpisodeTask task = episodeToTask(episode);
    String newTaskId = await FlutterDownloader.retry(taskId: task.taskId);
    await FlutterDownloader.remove(taskId: task.taskId);
    int index = _episodeTasks.indexOf(task);
    _removeTask(episode);
    var dbHelper = DBHelper();
    _episodeTasks.insert(index, EpisodeTask(episode, newTaskId));
    await dbHelper.saveDownloaded(newTaskId, episode.enclosureUrl);
  }

  Future removeTask(EpisodeBrief episode) async {
    EpisodeTask task = episodeToTask(episode);
    await FlutterDownloader.remove(
        taskId: task.taskId, shouldDeleteContent: false);
  }

  Future delTask(EpisodeBrief episode) async {
    EpisodeTask task = episodeToTask(episode);
    await FlutterDownloader.remove(
        taskId: task.taskId, shouldDeleteContent: true);
    await dbHelper.delDownloaded(episode.enclosureUrl);
    _episodeTasks.forEach((episodeTask) {
      if (episodeTask.taskId == task.taskId)
        episodeTask.status = DownloadTaskStatus.undefined;
      notifyListeners();
    });
    _removeTask(episode);
  }

  _removeTask(EpisodeBrief episode) {
    _episodeTasks.removeWhere(
        (element) => element.episode.enclosureUrl == episode.enclosureUrl);
  }

  _autoDelete() async {
    print('Start auto delete outdated episodes');
    KeyValueStorage autoDeleteStorage = KeyValueStorage(autoDeleteKey);
    int autoDelete = await autoDeleteStorage.getInt();
    if (autoDelete == 0)
      await autoDeleteStorage.saveInt(30);
    else if (autoDelete > 0) {
      List<EpisodeBrief> episodes =
          await dbHelper.getOutdatedEpisode(autoDelete);
      if (episodes.length > 0) {
        await Future.forEach(episodes, (episode) => delTask(episode));
      }
    }
  }
}
