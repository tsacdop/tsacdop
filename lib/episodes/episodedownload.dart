import 'dart:ui';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:connectivity/connectivity.dart';

import '../state/download_state.dart';
import '../state/audiostate.dart';
import '../state/settingstate.dart';
import '../type/episodebrief.dart';
import '../util/general_dialog.dart';

class DownloadButton extends StatefulWidget {
  final EpisodeBrief episode;
  DownloadButton({this.episode, Key key}) : super(key: key);
  @override
  _DownloadButtonState createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  bool _permissionReady;
  bool _usingData;
  StreamSubscription _connectivity;

  @override
  void initState() {
    super.initState();
    _permissionReady = false;
    _connectivity = Connectivity().onConnectivityChanged.listen((result) {
      _usingData = result == ConnectivityResult.mobile;
    });
  }

  @override
  void dispose() {
    _connectivity.cancel();
    super.dispose();
  }

  void _requestDownload(EpisodeBrief episode, bool downloadUsingData) async {
    _permissionReady = await _checkPermmison();
    bool _dataConfirm = true;
    if (_permissionReady) {
      if (downloadUsingData && _usingData) {
        _dataConfirm = await _useDataConfirem();
      }
      if (_dataConfirm) {
        Provider.of<DownloadState>(context, listen: false).startTask(episode);
        Fluttertoast.showToast(
          msg: 'Downloading',
          gravity: ToastGravity.BOTTOM,
        );
      }
    }
  }

  void _deleteDownload(EpisodeBrief episode) async {
    Provider.of<DownloadState>(context, listen: false).delTask(episode);
    Fluttertoast.showToast(
      msg: 'Download removed',
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _pauseDownload(EpisodeBrief episode) async {
    Provider.of<DownloadState>(context, listen: false).pauseTask(episode);
    Fluttertoast.showToast(
      msg: 'Download paused',
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _resumeDownload(EpisodeBrief episode) async {
    Provider.of<DownloadState>(context, listen: false).resumeTask(episode);
    Fluttertoast.showToast(
      msg: 'Download resumed',
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _retryDownload(EpisodeBrief episode) async {
    Provider.of<DownloadState>(context, listen: false).retryTask(episode);
    Fluttertoast.showToast(
      msg: 'Download again',
      gravity: ToastGravity.BOTTOM,
    );
  }

  Future<bool> _checkPermmison() async {
    PermissionStatus permission = await Permission.storage.status;
    if (permission != PermissionStatus.granted) {
      Map<Permission, PermissionStatus> permissions =
          await [Permission.storage].request();
      if (permissions[Permission.storage] == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  Future<bool> _useDataConfirem() async {
    bool ifUseData = false;
    await generalDialog(
      context,
      title: Text('Cellular data warn'),
      content: Text('Are you sure you want to use cellular data to download?'),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'CANCEL',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        FlatButton(
          onPressed: () {
            ifUseData = true;
            Navigator.of(context).pop();
          },
          child: Text(
            'CONFIRM',
            style: TextStyle(color: Colors.red),
          ),
        )
      ],
    );
    return ifUseData;
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
    return Consumer<DownloadState>(builder: (_, downloader, __) {
      EpisodeTask _task = Provider.of<DownloadState>(context, listen: false)
          .episodeToTask(widget.episode);
      return Row(
        children: <Widget>[
          _downloadButton(_task, context),
          AnimatedContainer(
              duration: Duration(seconds: 1),
              decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
                  borderRadius: BorderRadius.all(Radius.circular(15.0))),
              height: 20.0,
              width: (_task.status == DownloadTaskStatus.running) ? 50.0 : 0,
              alignment: Alignment.center,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text('${_task.progress}%',
                    style: TextStyle(color: Colors.white)),
              )),
        ],
      );
    });
  }

  Widget _downloadButton(EpisodeTask task, BuildContext context) {
    switch (task.status.value) {
      case 0:
        return Selector<SettingState, bool>(
          selector: (_, settings) => settings.downloadUsingData,
          builder: (_, data, __) => _buttonOnMenu(
              Icon(
                Icons.arrow_downward,
                color: Colors.grey[700],
              ),
              () => _requestDownload(task.episode, data)),
        );
        break;
      case 2:
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (task.progress > 0) _pauseDownload(task.episode);
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
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).accentColor),
                  value: task.progress / 100,
                ),
              ),
            ),
          ),
        );
        break;
      case 6:
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              _resumeDownload(task.episode);
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
        break;
      case 3:
        Provider.of<AudioPlayerNotifier>(context, listen: false)
            .updateMediaItem(task.episode);
        return _buttonOnMenu(
            Icon(
              Icons.done_all,
              color: Theme.of(context).accentColor,
            ), () {
          _deleteDownload(task.episode);
        });
        break;
      case 4:
        return _buttonOnMenu(Icon(Icons.refresh, color: Colors.red),
            () => _retryDownload(task.episode));
        break;
      default:
        return Center();
    }
  }
}
