import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../local_storage/key_value_storage.dart';
import '../local_storage/sqflite_localpodcast.dart';
import '../state/audio_state.dart';
import '../state/download_state.dart';
import '../type/episodebrief.dart';
import '../type/play_histroy.dart';
import '../util/extension_helper.dart';
import 'custom_widget.dart';
import 'general_dialog.dart';

class MultiSelectMenuBar extends StatefulWidget {
  MultiSelectMenuBar(
      {this.selectedList,
      this.selectAll,
      this.onSelectAll,
      this.onClose,
      this.onSelectAfter,
      this.onSelectBefore,
      this.hideFavorite = false,
      Key key})
      : assert(onClose != null),
        super(key: key);
  final List<EpisodeBrief> selectedList;
  final bool selectAll;
  final ValueChanged<bool> onSelectAll;
  final ValueChanged<bool> onClose;
  final ValueChanged<bool> onSelectBefore;
  final ValueChanged<bool> onSelectAfter;
  final bool hideFavorite;

  @override
  _MultiSelectMenuBarState createState() => _MultiSelectMenuBarState();
}

///Multi select menu bar.
class _MultiSelectMenuBarState extends State<MultiSelectMenuBar> {
  bool _liked;
  bool _marked;
  bool _inPlaylist;
  bool _downloaded;
  final _dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _liked = false;
    _marked = false;
    _downloaded = false;
    _inPlaylist = false;
  }

  @override
  void didUpdateWidget(MultiSelectMenuBar oldWidget) {
    if (oldWidget.selectedList != widget.selectedList) {
      setState(() {
        _liked = false;
        _marked = false;
        _downloaded = false;
        _inPlaylist = false;
      });
      super.didUpdateWidget(oldWidget);
    }
  }

  Future<void> _saveLiked() async {
    for (var episode in widget.selectedList) {
      await _dbHelper.setLiked(episode.enclosureUrl);
    }
    if (mounted) {
      setState(() => _liked = true);
      widget.onClose(false);
    }
  }

  Future<void> _setUnliked() async {
    for (var episode in widget.selectedList) {
      await _dbHelper.setUniked(episode.enclosureUrl);
    }
    if (mounted) {
      setState(() => _liked = false);
      widget.onClose(false);
    }
  }

  Future<void> _markListened() async {
    for (var episode in widget.selectedList) {
      final history = PlayHistory(episode.title, episode.enclosureUrl, 0, 1);
      await _dbHelper.saveHistory(history);
    }
    if (mounted) {
      setState(() => _marked = true);
      widget.onClose(false);
    }
  }

  Future<void> _markNotListened() async {
    for (var episode in widget.selectedList) {
      await _dbHelper.markNotListened(episode.enclosureUrl);
    }
    if (mounted) {
      setState(() => _marked = false);
      widget.onClose(false);
    }
  }

  Future<void> _requestDownload() async {
    final permissionReady = await _checkPermmison();
    final downloadUsingData = await KeyValueStorage(downloadUsingDataKey)
        .getBool(defaultValue: true, reverse: true);
    var dataConfirm = true;
    final result = await Connectivity().checkConnectivity();
    final usingData = result == ConnectivityResult.mobile;
    if (permissionReady) {
      if (downloadUsingData && usingData) {
        dataConfirm = await _useDataConfirm();
      }
      if (dataConfirm) {
        for (var episode in widget.selectedList) {
          Provider.of<DownloadState>(context, listen: false).startTask(episode);
        }
        if (mounted) {
          setState(() {
            _downloaded = true;
          });
        }
      }
    }
  }

  Future<bool> _useDataConfirm() async {
    var ifUseData = false;
    final s = context.s;
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

  Widget _buttonOnMenu({Widget child, VoidCallback onTap}) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 40,
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0), child: child),
          ),
        ),
      );
  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject();
    var offset = renderBox.localToGlobal(Offset.zero);
    return OverlayEntry(
      builder: (constext) => Positioned(
        left: offset.dx + 50,
        top: offset.dy - 60,
        child: Container(
            width: 70,
            height: 100,
            //color: Colors.grey[200],
            child: HeartOpen(width: 50, height: 80)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    var audio = context.watch<AudioPlayerNotifier>();
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 500),
      builder: (context, value, child) => Container(
        height: widget.selectAll == null ? 40 : 90.0 * value,
        decoration: BoxDecoration(color: context.primaryColor),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.selectAll != null)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 40,
                      child: Center(
                        child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text(
                                '${widget.selectedList.length} selected',
                                style: context.textTheme.headline6
                                    .copyWith(color: context.accentColor))),
                      ),
                    ),
                    Spacer(),
                    if (widget.selectedList.length == 1)
                      SizedBox(
                        height: 25,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: context.accentColor),
                                  primary: context.textColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(100)))),
                              onPressed: () {
                                widget.onSelectBefore(true);
                              },
                              child: Text('Before')),
                        ),
                      ),
                    if (widget.selectedList.length == 1)
                      SizedBox(
                        height: 25,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: context.accentColor),
                                  primary: context.textColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(100)))),
                              onPressed: () {
                                widget.onSelectAfter(true);
                              },
                              child: Text('After')),
                        ),
                      ),
                    SizedBox(
                      height: 25,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                                side: BorderSide(color: context.accentColor),
                                backgroundColor: widget.selectAll
                                    ? context.accentColor
                                    : null,
                                primary: widget.selectAll
                                    ? Colors.white
                                    : context.textColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(100)))),
                            onPressed: () {
                              widget.onSelectAll(!widget.selectAll);
                            },
                            child: Text('All')),
                      ),
                    )
                  ],
                ),
              Row(
                children: [
                  if (!widget.hideFavorite)
                    _buttonOnMenu(
                        child: _liked
                            ? Icon(Icons.favorite, color: Colors.red)
                            : Icon(
                                Icons.favorite_border,
                                color: Colors.grey[700],
                              ),
                        onTap: () async {
                          if (widget.selectedList.isNotEmpty) {
                            if (!_liked) {
                              await _saveLiked();
                              Fluttertoast.showToast(
                                msg: s.liked,
                                gravity: ToastGravity.BOTTOM,
                              );
                            } else {
                              await _setUnliked();
                              Fluttertoast.showToast(
                                msg: s.unliked,
                                gravity: ToastGravity.BOTTOM,
                              );
                            }
                            audio.setEpisodeState = true;
                          }
                          //  OverlayEntry _overlayEntry;
                          //  _overlayEntry = _createOverlayEntry();
                          //  Overlay.of(context).insert(_overlayEntry);
                          //  await Future.delayed(Duration(seconds: 2));
                          //  _overlayEntry?.remove();
                        }),
                  _buttonOnMenu(
                    child: _downloaded
                        ? Center(
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CustomPaint(
                                painter: DownloadPainter(
                                    color: context.accentColor,
                                    fraction: 1,
                                    progressColor: context.accentColor,
                                    progress: 1),
                              ),
                            ),
                          )
                        : Center(
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
                    onTap: () {
                      if (widget.selectedList.isNotEmpty) {
                        if (!_downloaded) _requestDownload();
                      }
                    },
                  ),
                  _buttonOnMenu(
                      child: _inPlaylist
                          ? Icon(Icons.playlist_add_check,
                              color: context.accentColor)
                          : Icon(
                              Icons.playlist_add,
                              color: Colors.grey[700],
                            ),
                      onTap: () async {
                        if (widget.selectedList.isNotEmpty) {
                          if (!_inPlaylist) {
                            for (var episode in widget.selectedList) {
                              audio.addToPlaylist(episode);
                              Fluttertoast.showToast(
                                msg: s.toastAddPlaylist,
                                gravity: ToastGravity.BOTTOM,
                              );
                            }
                            setState(() => _inPlaylist = true);
                          } else {
                            for (var episode in widget.selectedList) {
                              audio.delFromPlaylist(episode);
                              Fluttertoast.showToast(
                                msg: s.toastRemovePlaylist,
                                gravity: ToastGravity.BOTTOM,
                              );
                            }
                            setState(() => _inPlaylist = false);
                          }
                        }
                      }),
                  _buttonOnMenu(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: CustomPaint(
                          size: Size(25, 25),
                          painter: ListenedAllPainter(
                              _marked ? context.accentColor : Colors.grey[700],
                              stroke: 2.0),
                        ),
                      ),
                      onTap: () async {
                        if (widget.selectedList.isNotEmpty) {
                          if (!_marked) {
                            await _markListened();
                            Fluttertoast.showToast(
                              msg: s.markListened,
                              gravity: ToastGravity.BOTTOM,
                            );
                          } else {
                            await _markNotListened();
                            Fluttertoast.showToast(
                              msg: s.markNotListened,
                              gravity: ToastGravity.BOTTOM,
                            );
                          }
                        }
                      }),
                  Spacer(),
                  if (widget.selectAll == null)
                    SizedBox(
                      height: 40,
                      child: Center(
                        child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(
                                '${widget.selectedList.length} selected',
                                style: context.textTheme.headline6
                                    .copyWith(color: context.accentColor))),
                      ),
                    ),
                  _buttonOnMenu(
                      child: Icon(Icons.close),
                      onTap: () => widget.onClose(true))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
