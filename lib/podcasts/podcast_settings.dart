import 'dart:developer' as developer;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;
import 'package:webfeed/webfeed.dart';

import '../local_storage/sqflite_localpodcast.dart';
import '../type/play_histroy.dart';
import '../type/podcastlocal.dart';
import '../util/custom_widget.dart';
import '../util/duraiton_picker.dart';
import '../util/extension_helper.dart';
import '../util/general_dialog.dart';

enum MarkStatus { start, complete, none }
enum RefreshCoverStatus { start, complete, error, none }

class PodcastSetting extends StatefulWidget {
  const PodcastSetting({this.podcastLocal, Key key}) : super(key: key);
  final PodcastLocal podcastLocal;

  @override
  _PodcastSettingState createState() => _PodcastSettingState();
}

class _PodcastSettingState extends State<PodcastSetting> {
  MarkStatus _markStatus = MarkStatus.none;
  RefreshCoverStatus _coverStatus = RefreshCoverStatus.none;
  int _seconds = 0;

  Future<void> _setAutoDownload(bool boo) async {
    var permission = await _checkPermmison();
    if (permission) {
      var dbHelper = DBHelper();
      await dbHelper.saveAutoDownload(widget.podcastLocal.id, boo: boo);
    }
    if (mounted) setState(() {});
  }

  Future<void> _saveSkipSeconds(int seconds) async {
    var dbHelper = DBHelper();
    await dbHelper.saveSkipSeconds(widget.podcastLocal.id, seconds);
  }

  Future<void> _markListened(String podcastId) async {
    setState(() {
      _markStatus = MarkStatus.start;
    });
    var dbHelper = DBHelper();
    var episodes = await dbHelper.getRssItem(podcastId, -1, reverse: true);
    for (var episode in episodes) {
      var marked = await dbHelper.checkMarked(episode);
      if (!marked) {
        final history = PlayHistory(episode.title, episode.enclosureUrl, 0, 1);
        await dbHelper.saveHistory(history);
        if (mounted) {
          setState(() {
            _markStatus = MarkStatus.complete;
          });
        }
      }
    }
  }

  void _confirmMarkListened(BuildContext context) => generalDialog(
        context,
        title: Text(context.s.markConfirm),
        content: Text(context.s.markConfirmContent),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              context.s.cancel,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          FlatButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _markListened(widget.podcastLocal.id);
            },
            child: Text(
              context.s.confirm,
              style: TextStyle(color: context.accentColor),
            ),
          )
        ],
      );

  Future<void> _refreshArtWork() async {
    setState(() => _coverStatus = RefreshCoverStatus.start);
    var options = BaseOptions(
      connectTimeout: 20000,
      receiveTimeout: 20000,
    );
    String imageUrl;

    try {
      var response = await Dio(options).get(widget.podcastLocal.rssUrl);
      try {
        RssFeed p;
        p = RssFeed.parse(response.data);
        imageUrl == p.itunes.image.href;
      } catch (e) {
        developer.log(e.toString());
        if (mounted) setState(() => _coverStatus = RefreshCoverStatus.error);
      }
    } catch (e) {
      developer.log(e.toString());
      if (mounted) setState(() => _coverStatus = RefreshCoverStatus.error);
    }
    if (imageUrl != null &&
        imageUrl.contains('http') &&
        imageUrl != widget.podcastLocal.imageUrl) {
      try {
        img.Image thumbnail;
        var imageResponse = await Dio().get<List<int>>(imageUrl,
            options: Options(
              responseType: ResponseType.bytes,
              receiveTimeout: 90000,
            ));
        var image = img.decodeImage(imageResponse.data);
        thumbnail = img.copyResize(image, width: 300);
        if (thumbnail != null) {
          var dir = await getApplicationDocumentsDirectory();
          File("${dir.path}/${widget.podcastLocal.id}.png")
            ..writeAsBytesSync(img.encodePng(thumbnail));
          if (mounted) {
            setState(() => _coverStatus = RefreshCoverStatus.complete);
          }
        }
      } catch (e) {
        if (mounted) setState(() => _coverStatus = RefreshCoverStatus.error);
      }
    }
    if (mounted) {
      setState(() => _coverStatus = RefreshCoverStatus.complete);
    }
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

  Future<bool> _getAutoDownload(String id) async {
    var dbHelper = DBHelper();
    return await dbHelper.getAutoDownload(id);
  }

  Future<int> _getSkipSecond(String id) async {
    var dbHelper = DBHelper();
    var seconds = await dbHelper.getSkipSeconds(id);
    return seconds;
  }

  Widget _getRefreshStatusIcon(RefreshCoverStatus status) {
    switch (status) {
      case RefreshCoverStatus.none:
        return Icon(Icons.refresh);
        break;
      case RefreshCoverStatus.start:
        return CircularProgressIndicator(strokeWidth: 2);
        break;
      case RefreshCoverStatus.complete:
        return Icon(Icons.refresh);
        break;
      case RefreshCoverStatus.complete:
        return Icon(Icons.refresh, color: Colors.red);
        break;
      default:
        return Center();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Theme.of(context).accentColorBrightness,
        systemNavigationBarColor: Theme.of(context).primaryColor,
        systemNavigationBarIconBrightness:
            Theme.of(context).accentColorBrightness,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.settings),
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: Container(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  FutureBuilder<bool>(
                      future: _getAutoDownload(widget.podcastLocal.id),
                      initialData: false,
                      builder: (context, snapshot) {
                        return ListTile(
                          onTap: () => _setAutoDownload(!snapshot.data),
                          contentPadding: EdgeInsets.fromLTRB(70.0, 10, 20, 10),
                          title: Text(s.autoDownload),
                          trailing: Transform.scale(
                            scale: 0.9,
                            child: Switch(
                                value: snapshot.data,
                                onChanged: _setAutoDownload),
                          ),
                        );
                      }),
                  Divider(height: 2),
                  FutureBuilder<int>(
                    future: _getSkipSecond(widget.podcastLocal.id),
                    initialData: 0,
                    builder: (context, snapshot) => ListTile(
                      onTap: () => generalDialog(
                        context,
                        title: Text(s.skipSecondsAtStart, maxLines: 2),
                        content: DurationPicker(
                          duration: Duration(seconds: snapshot.data),
                          onChange: (value) => _seconds = value.inSeconds,
                        ),
                        actions: <Widget>[
                          FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _seconds = 0;
                            },
                            child: Text(
                              s.cancel,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                          FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _saveSkipSeconds(_seconds);
                            },
                            child: Text(
                              s.confirm,
                              style: TextStyle(color: context.accentColor),
                            ),
                          )
                        ],
                      ),
                      contentPadding: EdgeInsets.fromLTRB(70.0, 10, 40, 10),
                      title: Text(s.skipSecondsAtStart),
                      trailing: Text(snapshot.data.toTime),
                    ),
                  ),
                  Divider(height: 2),
                  ListTile(
                      onTap: () {
                        if (_markStatus != MarkStatus.start) {
                          _confirmMarkListened(context);
                        }
                      },
                      contentPadding: EdgeInsets.fromLTRB(70.0, 10, 40, 10),
                      title: Text(s.menuMarkAllListened),
                      // subtitle: Text(s.settingsAutoPlayDes),
                      trailing: SizedBox(
                          height: 20,
                          width: 20,
                          child: _markStatus == MarkStatus.none
                              ? CustomPaint(
                                  painter: ListenedAllPainter(context.textColor,
                                      stroke: 2),
                                )
                              : _markStatus == MarkStatus.start
                                  ? CircularProgressIndicator(strokeWidth: 2)
                                  : Icon(Icons.done))),
                  Divider(height: 2),
                  ListTile(
                      onTap: () {
                        if (_coverStatus != RefreshCoverStatus.start) {
                          _refreshArtWork();
                        }
                      },
                      contentPadding: EdgeInsets.fromLTRB(70.0, 10, 40, 10),
                      title: Text(s.refreshArtwork),
                      trailing: SizedBox(
                          height: 20,
                          width: 20,
                          child: _getRefreshStatusIcon(_coverStatus))),
                  Divider(height: 2),
                ]),
          ),
        ),
      ),
    );
  }
}
