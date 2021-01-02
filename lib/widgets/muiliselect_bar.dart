import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../local_storage/key_value_storage.dart';
import '../local_storage/sqflite_localpodcast.dart';
import '../state/audio_state.dart';
import '../state/download_state.dart';
import '../type/episodebrief.dart';
import '../type/play_histroy.dart';
import '../type/playlist.dart';
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
  bool _showPlaylists;
  final _dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _liked = false;
    _marked = false;
    _downloaded = false;
    _inPlaylist = false;
    _showPlaylists = false;
  }

  @override
  void didUpdateWidget(MultiSelectMenuBar oldWidget) {
    if (oldWidget.selectedList != widget.selectedList) {
      setState(() {
        _liked = false;
        _marked = false;
        _downloaded = false;
        _inPlaylist = false;
        _showPlaylists = false;
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

  Future<EpisodeBrief> _getEpisode(String url) async {
    var dbHelper = DBHelper();
    return await dbHelper.getRssItemWithUrl(url);
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

  Widget _playlistList() => SizedBox(
      height: 50,
      child: Selector<AudioPlayerNotifier, List<Playlist>>(
        selector: (_, audio) => audio.playlists,
        builder: (_, data, child) {
          return Align(
            alignment: Alignment.centerLeft,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  for (var p in data)
                    if (p.name == 'Queue')
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: InkWell(
                          onTap: () {
                            setState(() => _showPlaylists = false);
                            showGeneralDialog(
                                context: context,
                                barrierDismissible: true,
                                barrierLabel: MaterialLocalizations.of(context)
                                    .modalBarrierDismissLabel,
                                barrierColor: Colors.black54,
                                transitionDuration:
                                    const Duration(milliseconds: 200),
                                pageBuilder:
                                    (context, animaiton, secondaryAnimation) =>
                                        _NewPlaylist(widget.selectedList));
                          },
                          child: Container(
                            height: 30,
                            child: Row(
                              children: [
                                Container(
                                  height: 30,
                                  width: 30,
                                  color: context.primaryColorDark,
                                  child: Center(child: Icon(Icons.add)),
                                ),
                                SizedBox(width: 10),
                                Text('New')
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: InkWell(
                          onTap: () {
                            context
                                .read<AudioPlayerNotifier>()
                                .addEpisodesToPlaylist(p,
                                    episodes: widget.selectedList);
                            setState(() {
                              _showPlaylists = false;
                            });
                          },
                          child: Container(
                            height: 30,
                            child: Row(
                              children: [
                                Container(
                                  height: 30,
                                  width: 30,
                                  color: context.primaryColorDark,
                                  child: p.episodeList.isEmpty
                                      ? Center()
                                      : FutureBuilder<EpisodeBrief>(
                                          future:
                                              _getEpisode(p.episodeList.first),
                                          builder: (_, snapshot) {
                                            if (snapshot.data != null) {
                                              return SizedBox(
                                                  height: 30,
                                                  width: 30,
                                                  child: Image(
                                                      image: snapshot
                                                          .data.avatarImage));
                                            }
                                            return Center();
                                          }),
                                ),
                                SizedBox(width: 10),
                                Text(p.name),
                              ],
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          );
        },
      ));

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    var audio = context.watch<AudioPlayerNotifier>();
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 500),
      builder: (context, value, child) => Container(
        height: widget.selectAll == null
            ? _showPlaylists
                ? 90
                : 40
            : _showPlaylists
                ? 140
                : 90.0 * value,
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
              if (_showPlaylists) _playlistList(),
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
                  _buttonOnMenu(
                      child: Icon(
                        Icons.add_box_outlined,
                        color: Colors.grey[700],
                      ),
                      onTap: () {
                        if (widget.selectedList.isNotEmpty) {
                          setState(() {
                            _showPlaylists = !_showPlaylists;
                          });
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

class _NewPlaylist extends StatefulWidget {
  final List<EpisodeBrief> episodes;
  _NewPlaylist(this.episodes, {Key key}) : super(key: key);

  @override
  __NewPlaylistState createState() => __NewPlaylistState();
}

class __NewPlaylistState extends State<_NewPlaylist> {
  String _playlistName;
  int _error;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor:
            Theme.of(context).brightness == Brightness.light
                ? Color.fromRGBO(113, 113, 113, 1)
                : Color.fromRGBO(5, 5, 5, 1),
      ),
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 1,
        contentPadding: EdgeInsets.symmetric(horizontal: 20),
        titlePadding: EdgeInsets.all(20),
        actionsPadding: EdgeInsets.zero,
        actions: <Widget>[
          FlatButton(
            splashColor: context.accentColor.withAlpha(70),
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              s.cancel,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          FlatButton(
            splashColor: context.accentColor.withAlpha(70),
            onPressed: () async {
              if (context
                  .read<AudioPlayerNotifier>()
                  .playlistExisted(_playlistName)) {
                setState(() => _error = 1);
              } else {
                final episodesList =
                    widget.episodes.map((e) => e.enclosureUrl).toList();
                final playlist = Playlist(_playlistName,
                    episodeList: episodesList, episodes: widget.episodes);
                context.read<AudioPlayerNotifier>().addPlaylist(playlist);
                Navigator.of(context).pop();
              }
            },
            child:
                Text(s.confirm, style: TextStyle(color: context.accentColor)),
          )
        ],
        title:
            SizedBox(width: context.width - 160, child: Text('New playlist')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                hintText: 'New playlist',
                hintStyle: TextStyle(fontSize: 18),
                filled: true,
                focusedBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: context.accentColor, width: 2.0),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: context.accentColor, width: 2.0),
                ),
              ),
              cursorRadius: Radius.circular(2),
              autofocus: true,
              maxLines: 1,
              onChanged: (value) {
                _playlistName = value;
              },
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: (_error == 1)
                  ? Text(
                      'Playlist existed',
                      style: TextStyle(color: Colors.red[400]),
                    )
                  : Center(),
            ),
          ],
        ),
      ),
    );
  }
}
