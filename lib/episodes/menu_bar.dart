import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tsacdop/local_storage/sqflite_localpodcast.dart';
import 'package:tsacdop/type/play_histroy.dart';
import 'package:tuple/tuple.dart';
import 'package:provider/provider.dart';
import 'package:tsacdop/episodes/episode_download.dart';
import 'package:tsacdop/state/audio_state.dart';
import 'package:tsacdop/type/episodebrief.dart';
import 'package:tsacdop/util/extension_helper.dart';
import 'package:tsacdop/widgets/custom_widget.dart';

class MenuBar extends StatefulWidget {
  final EpisodeBrief? episodeItem;
  final String? heroTag;
  final bool? hide;
  MenuBar({this.episodeItem, this.heroTag, this.hide, Key? key})
      : super(key: key);
  @override
  MenuBarState createState() => MenuBarState();
}

class MenuBarState extends State<MenuBar> {
  @override
  Widget build(BuildContext context) {
    final audio = Provider.of<AudioPlayerNotifier>(context, listen: false);
    final s = context.s;
    return Container(
      height: 50.0,
      decoration: BoxDecoration(
        color: widget.episodeItem!.cardColor(context),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Hero(
                    tag: widget.episodeItem!.enclosureUrl + widget.heroTag!,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Container(
                        height: 30.0,
                        width: 30.0,
                        child: widget.hide!
                            ? Center()
                            : CircleAvatar(
                                radius: 15,
                                backgroundImage:
                                    widget.episodeItem!.avatarImage),
                      ),
                    ),
                  ),
                  FutureBuilder<bool>(
                    future: _isLiked(widget.episodeItem!),
                    initialData: false,
                    builder: (context, snapshot) {
                      return (!snapshot.data!)
                          ? _buttonOnMenu(
                              child: Icon(
                                Icons.favorite_border,
                                color: Colors.grey[700],
                              ),
                              onTap: () async {
                                await _saveLiked(
                                    widget.episodeItem!.enclosureUrl);
                                OverlayEntry _overlayEntry;
                                _overlayEntry = _createOverlayEntry();
                                Overlay.of(context)!.insert(_overlayEntry);
                                await Future.delayed(Duration(seconds: 2));
                                _overlayEntry.remove();
                              })
                          : _buttonOnMenu(
                              child: Icon(
                                Icons.favorite,
                                color: Colors.red,
                              ),
                              onTap: () => _setUnliked(
                                  widget.episodeItem!.enclosureUrl));
                    },
                  ),
                  DownloadButton(episode: widget.episodeItem),
                  Selector<AudioPlayerNotifier, List<EpisodeBrief?>>(
                    selector: (_, audio) => audio.queue.episodes,
                    builder: (_, data, __) {
                      final inPlaylist = data.contains(widget.episodeItem);
                      return inPlaylist
                          ? _buttonOnMenu(
                              child: Icon(Icons.playlist_add_check,
                                  color: context.accentColor),
                              onTap: () {
                                audio.delFromPlaylist(widget.episodeItem!);
                                Fluttertoast.showToast(
                                  msg: s.toastRemovePlaylist,
                                  gravity: ToastGravity.BOTTOM,
                                );
                              })
                          : _buttonOnMenu(
                              child: Icon(Icons.playlist_add,
                                  color: Colors.grey[700]),
                              onTap: () {
                                audio.addToPlaylist(widget.episodeItem!);
                                Fluttertoast.showToast(
                                  msg: s.toastAddPlaylist,
                                  gravity: ToastGravity.BOTTOM,
                                );
                              });
                    },
                  ),
                  FutureBuilder<int>(
                    future: _isListened(widget.episodeItem!),
                    initialData: 0,
                    builder: (context, snapshot) {
                      return snapshot.data == 0
                          ? _buttonOnMenu(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: CustomPaint(
                                  size: Size(25, 20),
                                  painter: ListenedAllPainter(Colors.grey[700],
                                      stroke: 2.0),
                                ),
                              ),
                              onTap: () {
                                _markListened(widget.episodeItem!);
                                Fluttertoast.showToast(
                                  msg: s.markListened,
                                  gravity: ToastGravity.BOTTOM,
                                );
                              })
                          : _buttonOnMenu(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: CustomPaint(
                                  size: Size(25, 20),
                                  painter: ListenedAllPainter(
                                      context.accentColor,
                                      stroke: 2.0),
                                ),
                              ),
                              onTap: () {
                                _markNotListened(
                                    widget.episodeItem!.enclosureUrl);
                                Fluttertoast.showToast(
                                  msg: s.markNotListened,
                                  gravity: ToastGravity.BOTTOM,
                                );
                              },
                            );
                    },
                  ),
                ],
              ),
            ),
          ),
          Selector<AudioPlayerNotifier, Tuple2<EpisodeBrief?, bool>>(
            selector: (_, audio) => Tuple2(audio.episode, audio.playerRunning),
            builder: (_, data, __) {
              return (widget.episodeItem == data.item1 && data.item2)
                  ? Padding(
                      padding: EdgeInsets.only(right: 30),
                      child: SizedBox(
                          width: 20,
                          height: 15,
                          child: WaveLoader(color: context.accentColor)))
                  : Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          audio.episodeLoad(widget.episodeItem);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 50.0,
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            children: <Widget>[
                              Text(
                                s.play.toUpperCase(),
                                style: TextStyle(
                                  color: context.accentColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(
                                Icons.play_arrow,
                                color: context.accentColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
            },
          ),
        ],
      ),
    );
  }

  Future<int> _isListened(EpisodeBrief episode) async {
    final dbHelper = DBHelper();
    return await dbHelper.isListened(episode.enclosureUrl);
  }

  Future<void> _saveLiked(String url) async {
    final dbHelper = DBHelper();
    await dbHelper.setLiked(url);
    if (mounted) setState(() {});
  }

  Future<void> _setUnliked(String url) async {
    final dbHelper = DBHelper();
    await dbHelper.setUniked(url);
    if (mounted) setState(() {});
  }

  Future<void> _markListened(EpisodeBrief episode) async {
    final dbHelper = DBHelper();
    final history = PlayHistory(episode.title, episode.enclosureUrl, 0, 1);
    await dbHelper.saveHistory(history);
    if (mounted) setState(() {});
  }

  Future<void> _markNotListened(String url) async {
    final dbHelper = DBHelper();
    await dbHelper.markNotListened(url);
    if (mounted) setState(() {});
  }

  Future<bool> _isLiked(EpisodeBrief episode) async {
    final dbHelper = DBHelper();
    return await dbHelper.isLiked(episode.enclosureUrl);
  }

  Widget _buttonOnMenu({Widget? child, VoidCallback? onTap}) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 50,
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.0), child: child),
          ),
        ),
      );

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
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
}
