import 'dart:async';
import 'dart:math' as math;

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../local_storage/key_value_storage.dart';
import '../state/audio_state.dart';
import '../state/download_state.dart';
import '../type/episode_task.dart';
import '../type/episodebrief.dart';
import '../util/extension_helper.dart';
import '../widgets/custom_widget.dart';
import '../widgets/general_dialog.dart';

class DownloadButton extends StatefulWidget {
  final EpisodeBrief? episode;
  DownloadButton({this.episode, Key? key}) : super(key: key);
  @override
  _DownloadButtonState createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  Future<void> _requestDownload(EpisodeBrief? episode) async {
    final downloadUsingData = await KeyValueStorage(downloadUsingDataKey)
        .getBool(defaultValue: true, reverse: true);
    final permissionReady = await _checkPermmison();
    final result = await Connectivity().checkConnectivity();
    final usingData = result == ConnectivityResult.mobile;
    var dataConfirm = true;
    if (permissionReady) {
      if (downloadUsingData && usingData) {
        dataConfirm = await _useDataConfirm();
      }
      if (dataConfirm) {
        Provider.of<DownloadState>(context, listen: false).startTask(episode!);
      }
    }
  }

  void _deleteDownload(EpisodeBrief episode) async {
    Provider.of<DownloadState>(context, listen: false).delTask(episode);
    Fluttertoast.showToast(
      msg: context.s!.downloadRemovedToast,
      gravity: ToastGravity.BOTTOM,
    );
  }

  Future<void> _pauseDownload(EpisodeBrief? episode) async {
    Provider.of<DownloadState>(context, listen: false).pauseTask(episode);
  }

  Future<void> _resumeDownload(EpisodeBrief episode) async {
    Provider.of<DownloadState>(context, listen: false).resumeTask(episode);
  }

  Future<void> _retryDownload(EpisodeBrief episode) async {
    Provider.of<DownloadState>(context, listen: false).retryTask(episode);
  }

  Future<bool> _checkPermmison() async {
    var permission = await Permission.storage.status;
    if (permission != PermissionStatus.granted) {
      var permissions = await [Permission.storage].request();
      if (permissions[Permission.storage] == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  Future<bool> _useDataConfirm() async {
    var ifUseData = false;
    final s = context.s!;
    await generalDialog(
      context,
      title: Text(s.cellularConfirm),
      content: Text(s.cellularConfirmDes),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            s.cancel,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        FlatButton(
          onPressed: () {
            ifUseData = true;
            Navigator.of(context).pop();
          },
          child: Text(
            s.confirm,
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
      var _task = Provider.of<DownloadState>(context, listen: false)
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
                child: Text('${math.max<int>(_task.progress!, 0)}%',
                    style: TextStyle(color: Colors.white)),
              )),
        ],
      );
    });
  }

  Widget _downloadButton(EpisodeTask task, BuildContext context) {
    switch (task.status!.value) {
      case 0:
        return _buttonOnMenu(
            Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CustomPaint(
                  painter: DownloadPainter(
                    color: Colors.grey[700],
                    fraction: 0,
                    progressColor: context.accentColor,
                  ),
                ),
              ),
            ),
            () => _requestDownload(task.episode));
      case 2:
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (task.progress! > 0) _pauseDownload(task.episode);
            },
            child: Container(
              height: 50.0,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: TweenAnimationBuilder(
                duration: Duration(milliseconds: 1000),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, dynamic fraction, child) => SizedBox(
                  height: 20,
                  width: 20,
                  child: CustomPaint(
                    painter: DownloadPainter(
                        color: context.accentColor,
                        fraction: fraction,
                        progressColor: context.accentColor,
                        progress: task.progress! / 100),
                  ),
                ),
              ),
            ),
          ),
        );
      case 6:
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              _resumeDownload(task.episode!);
            },
            child: Container(
              height: 50.0,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: TweenAnimationBuilder(
                duration: Duration(milliseconds: 500),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, dynamic fraction, child) => SizedBox(
                  height: 20,
                  width: 20,
                  child: CustomPaint(
                    painter: DownloadPainter(
                        color: context.accentColor,
                        fraction: 1,
                        progressColor: context.accentColor,
                        progress: task.progress! / 100,
                        pauseProgress: fraction),
                  ),
                ),
              ),
            ),
          ),
        );
        break;
      case 3:
        Provider.of<AudioPlayerNotifier>(context, listen: false)
            .updateMediaItem(task.episode!);
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              _deleteDownload(task.episode!);
            },
            child: Container(
              height: 50.0,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CustomPaint(
                  painter: DownloadPainter(
                    color: context.accentColor,
                    fraction: 1,
                    progressColor: context.accentColor,
                    progress: 1,
                  ),
                ),
              ),
            ),
          ),
        );
        break;
      case 4:
        return _buttonOnMenu(Icon(Icons.refresh, color: Colors.red),
            () => _retryDownload(task.episode!));
        break;
      default:
        return Center();
    }
  }
}
