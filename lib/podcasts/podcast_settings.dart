import 'dart:developer' as developer;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:webfeed/webfeed.dart';

import '../local_storage/sqflite_localpodcast.dart';
import '../state/podcast_group.dart';
import '../type/play_histroy.dart';
import '../type/podcastlocal.dart';
import '../util/extension_helper.dart';
import '../widgets/custom_widget.dart';
import '../widgets/duraiton_picker.dart';

enum MarkStatus { start, complete, none }
enum RefreshCoverStatus { start, complete, error, none }

class PodcastSetting extends StatefulWidget {
  const PodcastSetting({this.podcastLocal, Key key}) : super(key: key);
  final PodcastLocal podcastLocal;

  @override
  _PodcastSettingState createState() => _PodcastSettingState();
}

class _PodcastSettingState extends State<PodcastSetting> {
  final _dbHelper = DBHelper();
  MarkStatus _markStatus = MarkStatus.none;
  RefreshCoverStatus _coverStatus = RefreshCoverStatus.none;
  int _secondsStart;
  int _secondsEnd;
  bool _markConfirm;
  bool _removeConfirm;
  bool _showStartTimePicker;
  bool _showEndTimePicker;

  @override
  void initState() {
    super.initState();
    _secondsStart = 0;
    _secondsEnd = 0;
    _markConfirm = false;
    _removeConfirm = false;
    _showStartTimePicker = false;
    _showEndTimePicker = false;
  }

  Future<void> _setAutoDownload(bool boo) async {
    var permission = await _checkPermmison();
    if (permission) {
      await _dbHelper.saveAutoDownload(widget.podcastLocal.id, boo: boo);
    }
    if (mounted) setState(() {});
  }

  Future<void> _setNeverUpdate(bool boo) async {
    await _dbHelper.saveNeverUpdate(widget.podcastLocal.id, boo: boo);
    if (mounted) setState(() {});
  }

  Future<void> _saveSkipSecondsStart(int seconds) async {
    await _dbHelper.saveSkipSecondsStart(widget.podcastLocal.id, seconds);
  }

  Future<void> _saveSkipSecondsEnd(int seconds) async {
    await _dbHelper.saveSkipSecondsEnd(widget.podcastLocal.id, seconds);
  }

  Future<bool> _getAutoDownload(String id) async {
    return await _dbHelper.getAutoDownload(id);
  }

  Future<bool> _getNeverUpdate(String id) async {
    return await _dbHelper.getNeverUpdate(id);
  }

  Future<int> _getSkipSecondStart(String id) async {
    return await _dbHelper.getSkipSecondsStart(id);
  }

  Future<int> _getSkipSecondEnd(String id) async {
    return await _dbHelper.getSkipSecondsEnd(id);
  }

  Future<void> _markListened(String podcastId) async {
    setState(() {
      _markStatus = MarkStatus.start;
    });
    final episodes = await _dbHelper.getRssItem(podcastId, -1,
        reverse: true, hideListened: true);
    for (var episode in episodes) {
      final history = PlayHistory(episode.title, episode.enclosureUrl, 0, 1);
      await _dbHelper.saveHistory(history);
    }
    if (mounted) {
      setState(() {
        _markStatus = MarkStatus.complete;
      });
    }
  }

  Future<void> _refreshArtWork() async {
    setState(() => _coverStatus = RefreshCoverStatus.start);
    var options = BaseOptions(
      connectTimeout: 30000,
      receiveTimeout: 90000,
    );

    var dio = Dio(options);
    String imageUrl;

    try {
      var response = await dio.get(widget.podcastLocal.rssUrl);
      try {
        var p = RssFeed.parse(response.data);
        imageUrl = p.itunes.image.href ?? p.image.url;
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
        (imageUrl != widget.podcastLocal.imageUrl ||
            !File(widget.podcastLocal.imageUrl).existsSync())) {
      try {
        img.Image thumbnail;
        var imageResponse = await dio.get<List<int>>(imageUrl,
            options: Options(
              responseType: ResponseType.bytes,
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
        developer.log(e.toString());
        if (mounted) setState(() => _coverStatus = RefreshCoverStatus.error);
      }
    } else if (_coverStatus == RefreshCoverStatus.start && mounted) {
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

  Widget _getRefreshStatusIcon(RefreshCoverStatus status) {
    switch (status) {
      case RefreshCoverStatus.none:
        return Center();
        break;
      case RefreshCoverStatus.start:
        return CircularProgressIndicator(strokeWidth: 2);
        break;
      case RefreshCoverStatus.complete:
        return Icon(Icons.done);
        break;
      case RefreshCoverStatus.error:
        return Icon(Icons.refresh, color: Colors.red);
        break;
      default:
        return Center();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final groupList = context.watch<GroupList>();
    final textStyle = context.textTheme.bodyText2;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        FutureBuilder<bool>(
            future: _getAutoDownload(widget.podcastLocal.id),
            initialData: false,
            builder: (context, snapshot) {
              return ListTile(
                onTap: () => _setAutoDownload(!snapshot.data),
                dense: true,
                title: Row(
                  children: [
                    SizedBox(
                      height: 18,
                      width: 18,
                      child: CustomPaint(
                        painter: DownloadPainter(
                          color: context.textColor,
                          fraction: 0,
                          progressColor: context.accentColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Text(s.autoDownload, style: textStyle),
                  ],
                ),
                trailing: Transform.scale(
                  scale: 0.8,
                  child:
                      Switch(value: snapshot.data, onChanged: _setAutoDownload),
                ),
              );
            }),
        FutureBuilder<bool>(
            future: _getNeverUpdate(widget.podcastLocal.id),
            initialData: false,
            builder: (context, snapshot) {
              return ListTile(
                dense: true,
                onTap: () => _setNeverUpdate(!snapshot.data),
                title: Row(
                  children: [
                    Icon(Icons.lock, size: 18),
                    SizedBox(width: 20),
                    Text(s.neverAutoUpdate, style: textStyle),
                  ],
                ),
                trailing: Transform.scale(
                  scale: 0.8,
                  child:
                      Switch(value: snapshot.data, onChanged: _setNeverUpdate),
                ),
              );
            }),
        FutureBuilder<int>(
          future: _getSkipSecondStart(widget.podcastLocal.id),
          initialData: 0,
          builder: (context, snapshot) => ListTile(
            onTap: () {
              _secondsStart = 0;
              setState(() {
                _removeConfirm = false;
                _markConfirm = false;
                _showEndTimePicker = false;
                _showStartTimePicker = !_showStartTimePicker;
              });
            },
            dense: true,
            title: Row(
              children: [
                Icon(Icons.fast_forward, size: 18),
                SizedBox(width: 20),
                Text(s.skipSecondsAtStart, style: textStyle),
              ],
            ),
            trailing: Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Text(snapshot.data.toTime),
            ),
          ),
        ),
        if (_showStartTimePicker)
          _TimePicker(
              onCancel: () {
                _secondsStart = 0;
                setState(() => _showStartTimePicker = false);
              },
              onConfirm: () async {
                await _saveSkipSecondsStart(_secondsStart);
                if (mounted) setState(() => _showStartTimePicker = false);
              },
              onChange: (value) => _secondsStart = value.inSeconds),
        ListTile(
            onTap: () {
              if (_coverStatus != RefreshCoverStatus.start) {
                _refreshArtWork();
              }
            },
            dense: true,
            title: Row(
              children: [
                Icon(Icons.refresh, size: 18),
                SizedBox(width: 20),
                Text(s.refreshArtwork, style: textStyle),
              ],
            ),
            trailing: Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: SizedBox(
                    height: 20,
                    width: 20,
                    child: _getRefreshStatusIcon(_coverStatus)))),
        Divider(height: 1),
        ListTile(
            onTap: () {
              setState(() {
                _removeConfirm = false;
                _showStartTimePicker = false;
                _showEndTimePicker = false;
                _markConfirm = !_markConfirm;
              });
            },
            dense: true,
            title: Row(
              children: [
                SizedBox(
                  height: 18,
                  width: 18,
                  child: CustomPaint(
                    painter: ListenedAllPainter(
                        context.accentColor,
                        stroke: 2),
                  ),
                ),
                SizedBox(width: 20),
                Text(s.menuMarkAllListened,
                    style: textStyle.copyWith(
                        color: context.accentColor,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            trailing: Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: SizedBox(
                  height: 20,
                  width: 20,
                  child: _markStatus == MarkStatus.none
                      ? Center()
                      : _markStatus == MarkStatus.start
                          ? CircularProgressIndicator(strokeWidth: 2)
                          : Icon(Icons.done)),
            )),
        if (_markConfirm)
          Container(
            width: double.infinity,
            color: context.primaryColorDark,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FlatButton(
                    onPressed: () => setState(() {
                          _markConfirm = false;
                        }),
                    child: Text(
                      s.cancel,
                      style: TextStyle(color: Colors.grey[600]),
                    )),
                FlatButton(
                    onPressed: () {
                      if (_markStatus != MarkStatus.start) {
                        _markListened(widget.podcastLocal.id);
                      }
                      setState(() {
                        _markConfirm = false;
                      });
                    },
                    child: Text(s.confirm,
                        style: TextStyle(color: context.accentColor))),
              ],
            ),
          ),
        ListTile(
          onTap: () {
            setState(() {
              _markConfirm = false;
              _showStartTimePicker = false;
              _showEndTimePicker = false;
              _removeConfirm = !_removeConfirm;
            });
          },
          dense: true,
          title: Row(
            children: [
              Icon(Icons.delete, color: Colors.red, size: 18),
              SizedBox(width: 20),
              Text(s.remove,
                  style: textStyle.copyWith(
                      color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        if (_removeConfirm)
          Container(
            width: double.infinity,
            color: context.primaryColorDark,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FlatButton(
                  onPressed: () => setState(() {
                    _removeConfirm = false;
                  }),
                  child:
                      Text(s.cancel, style: TextStyle(color: Colors.grey[600])),
                ),
                FlatButton(
                    splashColor: Colors.red.withAlpha(70),
                    onPressed: () async {
                      await groupList.removePodcast(widget.podcastLocal);
                      Navigator.of(context).pop();
                    },
                    child:
                        Text(s.confirm, style: TextStyle(color: Colors.red))),
              ],
            ),
          ),
      ],
    );
  }
}

class _TimePicker extends StatelessWidget {
  const _TimePicker({this.onConfirm, this.onCancel, this.onChange, Key key})
      : super(key: key);
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final ValueChanged<Duration> onChange;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Container(
      color: context.primaryColorDark,
      child: Column(
        children: [
          SizedBox(height: 10),
          DurationPicker(
            onChange: onChange,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              FlatButton(
                onPressed: onCancel,
                child: Text(
                  s.cancel,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              FlatButton(
                splashColor: context.accentColor.withAlpha(70),
                onPressed: onConfirm,
                child: Text(
                  s.confirm,
                  style: TextStyle(color: context.accentColor),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
