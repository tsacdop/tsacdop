import 'dart:isolate';
import 'dart:ui';
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tsacdop/class/episodebrief.dart';
import 'package:tsacdop/local_storage/sqflite_localpodcast.dart';

class DownloadButton extends StatefulWidget {
  final EpisodeBrief episodeBrief;
  DownloadButton({this.episodeBrief, Key key}) : super(key: key);
  @override
  _DownloadButtonState createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  _TaskInfo _task;
  bool _isLoading;
  bool _permissionReady;
  String _localPath;
  ReceivePort _port = ReceivePort();

  Future<String> _getPath() async {
    final dir = await getExternalStorageDirectory();
    return dir.path;
  }

  @override
  void initState() {
    super.initState();

    _bindBackgroundIsolate();

    FlutterDownloader.registerCallback(downloadCallback);

    _isLoading = true;
    _permissionReady = false;

    _prepare();
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }

    _port.listen((dynamic data) {
      print('UI isolate callback: $data');
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      if (_task.taskId == id) {
        print(_task.progress);
        setState(() {
          _task.status = status;
          _task.progress = progress;
        });
      }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    print('Background callback task in $id  status ($status) $progress');
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  void _requestDownload(_TaskInfo task) async {
    _permissionReady = await _checkPermmison();
    if (_permissionReady)
      task.taskId = await FlutterDownloader.enqueue(
        url: task.link,
        savedDir: _localPath,
        showNotification: true,
        openFileFromNotification: false,
      );
    var dbHelper = DBHelper();
    await dbHelper.saveDownloaded(task.link, task.taskId);
    Fluttertoast.showToast(
      msg: 'Downloading',
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _deleteDownload(_TaskInfo task) async {
    await FlutterDownloader.remove(
        taskId: task.taskId, shouldDeleteContent: true);
    var dbHelper = DBHelper();
    await dbHelper.delDownloaded(task.link);
    await _prepare();
    setState(() {});
    Fluttertoast.showToast(
      msg: 'Download removed',
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _pauseDownload(_TaskInfo task) async {
    await FlutterDownloader.pause(taskId: task.taskId);
    Fluttertoast.showToast(
      msg: 'Download paused',
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _resumeDownload(_TaskInfo task) async {
    String newTaskId = await FlutterDownloader.resume(taskId: task.taskId);
    task.taskId = newTaskId;
    var dbHelper = DBHelper();
    await dbHelper.saveDownloaded(task.taskId, task.link);
    Fluttertoast.showToast(
      msg: 'Download resumed',
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _retryDownload(_TaskInfo task) async {
    String newTaskId = await FlutterDownloader.retry(taskId: task.taskId);
    task.taskId = newTaskId;
    var dbHelper = DBHelper();
    await dbHelper.saveDownloaded(task.taskId, task.link);
    Fluttertoast.showToast(
      msg: 'Download again',
      gravity: ToastGravity.BOTTOM,
    );
  }

  Future<Null> _prepare() async {
    final tasks = await FlutterDownloader.loadTasks();

    _task = _TaskInfo(
      name: widget.episodeBrief.title,
      link: widget.episodeBrief.enclosureUrl,
    );
    tasks?.forEach((task) {
      if (_task.link == task.url) {
        _task.taskId = task.taskId;
        _task.status = task.status;
        _task.progress = task.progress;
      }
    });

    _localPath = (await _getPath()) + '/' + widget.episodeBrief.feedTitle;
    print(_localPath);
    final saveDir = Directory(_localPath);
    bool hasExisted = await saveDir.exists();
    if (!hasExisted) {
      saveDir.create();
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<bool> _checkPermmison() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    if (permission != PermissionStatus.granted) {
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.storage]);
      if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  Widget _buttonOnMenu(Widget widget, Function() onTap) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
              height: 50.0,
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: widget),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center()
        : Row(
            children: <Widget>[
              _downloadButton(_task),
              AnimatedContainer(
                  duration: Duration(seconds: 1),
                  decoration: BoxDecoration(
                      color: Colors.cyan[300],
                      borderRadius: BorderRadius.all(Radius.circular(15.0))),
                  height: 20.0,
                  width:
                      (_task.status == DownloadTaskStatus.running) ? 50.0 : 0,
                  alignment: Alignment.center,
                  child: Text('${_task.progress}%',
                      style: TextStyle(color: Colors.white))),
            ],
          );
  }

  Widget _downloadButton(_TaskInfo task) {
    if (task.status == DownloadTaskStatus.undefined) {
      return _buttonOnMenu(
          Icon(
            Icons.arrow_downward,
            color: Colors.grey[700],
          ),
          () => _requestDownload(task));
    } else if (task.status == DownloadTaskStatus.running) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if(task.progress > 0) _pauseDownload(task);
          },
          child: Container(
            height: 50.0,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 18.0),
            child: SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                backgroundColor: Colors.grey[500],
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan[300]),
                value: task.progress / 100,
              ),
            ),
          ),
        ),
      );
    } else if (task.status == DownloadTaskStatus.paused) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _resumeDownload(task);
          },
          child: Container(
            height: 50.0,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                backgroundColor: Colors.grey[500],
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                value: task.progress / 100,
              ),
            ),
          ),
        ),
      );
    } else if (task.status == DownloadTaskStatus.complete) {
      return _buttonOnMenu(
          Icon(
            Icons.done_all,
            color: Colors.blue,
          ),
          () => _deleteDownload(task));
    } else if (task.status == DownloadTaskStatus.failed) {
      return _buttonOnMenu(
          Icon(Icons.refresh, color: Colors.red), () => _retryDownload(task));
    }
    return Center();
  }
}

class _TaskInfo {
  final String name;
  final String link;

  String taskId;
  int progress = 0;
  DownloadTaskStatus status = DownloadTaskStatus.undefined;

  _TaskInfo({this.name, this.link});
}
