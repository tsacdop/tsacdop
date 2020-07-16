import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:line_icons/line_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:auto_animated/auto_animated.dart';
import 'open_container.dart';

import '../state/audio_state.dart';
import '../state/download_state.dart';
import '../type/episodebrief.dart';
import '../episodes/episode_detail.dart';
import '../local_storage/sqflite_localpodcast.dart';
import '../local_storage/key_value_storage.dart';
import 'colorize.dart';
import 'context_extension.dart';
import 'custompaint.dart';

enum Layout { three, two, one }

// ignore: must_be_immutable
class EpisodeGrid extends StatelessWidget {
  final List<EpisodeBrief> episodes;
  final bool showFavorite;
  final bool showDownload;
  final bool showNumber;
  final int episodeCount;
  final Layout layout;
  final bool reverse;
  final int initNum;
  EpisodeGrid({
    Key key,
    @required this.episodes,
    this.initNum = 12,
    this.showDownload = false,
    this.showFavorite = false,
    this.showNumber = false,
    this.episodeCount = 0,
    this.layout = Layout.three,
    this.reverse,
  }) : super(key: key);
  String _dateToString(BuildContext context, {int pubDate}) {
    final s = context.s;
    DateTime date = DateTime.fromMillisecondsSinceEpoch(pubDate, isUtc: true);
    var difference = DateTime.now().toUtc().difference(date);
    if (difference.inHours < 24) {
      return s.hoursAgo(difference.inHours);
    } else if (difference.inDays < 7) {
      return s.daysAgo(difference.inDays);
    } else {
      return DateFormat.yMMMd().format(
          DateTime.fromMillisecondsSinceEpoch(pubDate, isUtc: true).toLocal());
    }
  }

  Future<int> _isListened(EpisodeBrief episode) async {
    DBHelper dbHelper = DBHelper();
    return await dbHelper.isListened(episode.enclosureUrl);
  }

  Future<Tuple5<int, bool, bool, bool, List<int>>> _initData(
      EpisodeBrief episode) async {
    List<int> menuList = await _getEpisodeMenu();
    bool tapToOpen = await _getTapToOpenPopupMenu();
    int listened = await _isListened(episode);
    bool liked = await _isLiked(episode);
    bool downloaded = await _isDownloaded(episode);
    return Tuple5(listened, liked, downloaded, tapToOpen, menuList);
  }

  Future<bool> _isLiked(EpisodeBrief episode) async {
    DBHelper dbHelper = DBHelper();
    return await dbHelper.isLiked(episode.enclosureUrl);
  }

  Future<List<int>> _getEpisodeMenu() async {
    KeyValueStorage popupMenuStorage = KeyValueStorage(episodePopupMenuKey);
    List<int> list = await popupMenuStorage.getMenu();
    return list;
  }

  Future<bool> _isDownloaded(EpisodeBrief episode) async {
    DBHelper dbHelper = DBHelper();
    return await dbHelper.isDownloaded(episode.enclosureUrl);
  }

  Future<bool> _getTapToOpenPopupMenu() async {
    KeyValueStorage tapToOpenPopupMenuStorage =
        KeyValueStorage(tapToOpenPopupMenuKey);
    bool boo = await tapToOpenPopupMenuStorage.getBool(defaultValue: false);
    return boo;
  }

  _markListened(EpisodeBrief episode) async {
    DBHelper dbHelper = DBHelper();
    bool marked = await dbHelper.checkMarked(episode);
    if (!marked) {
      final PlayHistory history =
          PlayHistory(episode.title, episode.enclosureUrl, 0, 1);
      await dbHelper.saveHistory(history);
    }
  }

  _saveLiked(String url) async {
    var dbHelper = DBHelper();
    await dbHelper.setLiked(url);
  }

  _setUnliked(String url) async {
    var dbHelper = DBHelper();
    await dbHelper.setUniked(url);
  }

  String _stringForSeconds(double seconds) {
    if (seconds == null) return null;
    return '${(seconds ~/ 60)}:${(seconds.truncate() % 60).toString().padLeft(2, '0')}';
  }

  Widget _title(EpisodeBrief episode) => Container(
        alignment:
            layout == Layout.one ? Alignment.centerLeft : Alignment.topLeft,
        padding: EdgeInsets.only(top: 2.0),
        child: Text(
          episode.title,
          maxLines: layout == Layout.one ? 1 : 4,
          overflow:
              layout == Layout.one ? TextOverflow.ellipsis : TextOverflow.fade,
        ),
      );

  Widget _circleImage(BuildContext context,
          {EpisodeBrief episode, Color color, bool boo}) =>
      Container(
        height: context.width / 16,
        width: context.width / 16,
        child: boo
            ? Center()
            : CircleAvatar(
                backgroundColor: color.withOpacity(0.5),
                backgroundImage: FileImage(File("${episode.imagePath}")),
              ),
      );

  Widget _downloadIndicater(BuildContext context,
          {EpisodeBrief episode, bool isDownloaded}) =>
      showDownload || layout != Layout.three
          ? isDownloaded
              ? Container(
                  height: 20,
                  width: 20,
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  padding: EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: context.accentColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.done_all,
                    size: 15,
                    color: Colors.white,
                  ),
                )
              : Center()
          : Center();

  Widget _isNewIndicator(EpisodeBrief episode) => episode.isNew == 1
      ? Container(
          padding: EdgeInsets.symmetric(horizontal: 2),
          child: Text('New',
              style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic)),
        )
      : Center();

  Widget _numberIndicater(BuildContext context, {int index, Color color}) =>
      showNumber
          ? Container(
              alignment: Alignment.topRight,
              child: Text(
                reverse
                    ? (index + 1).toString()
                    : (episodeCount - index).toString(),
                style: GoogleFonts.teko(
                  textStyle: TextStyle(
                    fontSize: context.width / 24,
                    color: color,
                  ),
                ),
              ),
            )
          : Center();

  Widget _pubDate(BuildContext context, {EpisodeBrief episode, Color color}) =>
      Text(
        _dateToString(context, pubDate: episode.pubDate),
        style: TextStyle(
            fontSize: context.width / 35,
            color: color,
            fontStyle: FontStyle.italic),
      );

  @override
  Widget build(BuildContext context) {
    double _width = context.width;
    var audio = Provider.of<AudioPlayerNotifier>(context, listen: false);
    var downloader = Provider.of<DownloadState>(context, listen: false);
    final options = LiveOptions(
      delay: Duration.zero,
      showItemInterval: Duration(milliseconds: 50),
      showItemDuration: Duration(milliseconds: 50),
    );
    final scrollController = ScrollController();
    final s = context.s;
    return SliverPadding(
      padding: const EdgeInsets.only(
          top: 10.0, bottom: 5.0, left: 15.0, right: 15.0),
      sliver: LiveSliverGrid.options(
        controller: scrollController,
        options: options,
        itemCount: episodes.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio:
              layout == Layout.three ? 1 : layout == Layout.two ? 1.5 : 4,
          crossAxisCount:
              layout == Layout.three ? 3 : layout == Layout.two ? 2 : 1,
          mainAxisSpacing: 6.0,
          crossAxisSpacing: 6.0,
        ),
        itemBuilder: (context, index, animation) {
          Color _c = (Theme.of(context).brightness == Brightness.light)
              ? episodes[index].primaryColor.colorizedark()
              : episodes[index].primaryColor.colorizeLight();
          scrollController.addListener(() {});

          return FadeTransition(
            opacity: Tween<double>(begin: index < initNum ? 0 : 1, end: 1)
                .animate(animation),
            child: Selector<AudioPlayerNotifier,
                Tuple3<EpisodeBrief, List<String>, bool>>(
              selector: (_, audio) => Tuple3(
                  audio?.episode,
                  audio.queue.playlist.map((e) => e.enclosureUrl).toList(),
                  audio.episodeState),
              builder: (_, data, __) => OpenContainerWrapper(
                episode: episodes[index],
                closedBuilder: (context, action, boo) => FutureBuilder<
                        Tuple5<int, bool, bool, bool, List<int>>>(
                    future: _initData(episodes[index]),
                    initialData: Tuple5(0, false, false, false, []),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      int isListened = snapshot.data.item1;
                      bool isLiked = snapshot.data.item2;
                      bool isDownloaded = snapshot.data.item3;
                      bool tapToOpen = snapshot.data.item4;
                      List<int> menuList = snapshot.data.item5;
                      return Container(
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
                            color: isListened > 0
                                ? context.brightness == Brightness.light
                                    ? Colors.grey[200]
                                    : Color.fromRGBO(40, 40, 40, 1)
                                : context.scaffoldBackgroundColor,
                            boxShadow: [
                              BoxShadow(
                                color: context.brightness == Brightness.light
                                    ? context.primaryColor
                                    : Color.fromRGBO(40, 40, 40, 1),
                                blurRadius: 0.5,
                                spreadRadius: 0.5,
                              ),
                            ]),
                        alignment: Alignment.center,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
                            border: Border.all(
                              color: context.brightness == Brightness.light
                                  ? context.primaryColor
                                  : context.scaffoldBackgroundColor,
                              width: 1.0,
                            ),
                          ),
                          child: FocusedMenuHolder(
                            blurSize: 0.0,
                            menuItemExtent: 45,
                            menuBoxDecoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15.0))),
                            duration: Duration(milliseconds: 100),
                            tapMode:
                                tapToOpen ? TapMode.onTap : TapMode.onLongPress,
                            animateMenuItems: false,
                            blurBackgroundColor:
                                context.brightness == Brightness.light
                                    ? Colors.white38
                                    : Colors.black38,
                            bottomOffsetHeight: 10,
                            menuOffset: 6,
                            menuItems: <FocusedMenuItem>[
                              FocusedMenuItem(
                                  backgroundColor:
                                      context.brightness == Brightness.light
                                          ? context.primaryColor
                                          : context.scaffoldBackgroundColor,
                                  title: Text(data.item1 != episodes[index]
                                      ? s.play
                                      : s.playing),
                                  trailingIcon: Icon(
                                    LineIcons.play_circle_solid,
                                    color: Theme.of(context).accentColor,
                                  ),
                                  onPressed: () {
                                    if (data.item1 != episodes[index])
                                      audio.episodeLoad(episodes[index]);
                                  }),
                              menuList.contains(1)
                                  ? FocusedMenuItem(
                                      backgroundColor:
                                          context.brightness == Brightness.light
                                              ? context.primaryColor
                                              : context.scaffoldBackgroundColor,
                                      title: data.item2.contains(
                                              episodes[index].enclosureUrl)
                                          ? Text(s.remove)
                                          : Text(s.later),
                                      trailingIcon: Icon(
                                        LineIcons.clock_solid,
                                        color: Colors.cyan,
                                      ),
                                      onPressed: () {
                                        if (!data.item2.contains(
                                            episodes[index].enclosureUrl)) {
                                          audio.addToPlaylist(episodes[index]);
                                          Fluttertoast.showToast(
                                            msg: s.toastAddPlaylist,
                                            gravity: ToastGravity.BOTTOM,
                                          );
                                        } else {
                                          audio
                                              .delFromPlaylist(episodes[index]);
                                          Fluttertoast.showToast(
                                            msg: s.toastRemovePlaylist,
                                            gravity: ToastGravity.BOTTOM,
                                          );
                                        }
                                      })
                                  : null,
                              menuList.contains(2)
                                  ? FocusedMenuItem(
                                      backgroundColor:
                                          context.brightness == Brightness.light
                                              ? context.primaryColor
                                              : context.scaffoldBackgroundColor,
                                      title: isLiked
                                          ? Text(s.unlike)
                                          : Text(s.like),
                                      trailingIcon: Icon(LineIcons.heart,
                                          color: Colors.red, size: 21),
                                      onPressed: () async {
                                        if (isLiked) {
                                          await _setUnliked(
                                              episodes[index].enclosureUrl);
                                          audio.setEpisodeState = true;
                                          Fluttertoast.showToast(
                                            msg: s.unliked,
                                            gravity: ToastGravity.BOTTOM,
                                          );
                                        } else {
                                          await _saveLiked(
                                              episodes[index].enclosureUrl);
                                          audio.setEpisodeState = true;
                                          Fluttertoast.showToast(
                                            msg: s.liked,
                                            gravity: ToastGravity.BOTTOM,
                                          );
                                        }
                                      })
                                  : null,
                              menuList.contains(3)
                                  ? FocusedMenuItem(
                                      backgroundColor:
                                          context.brightness == Brightness.light
                                              ? context.primaryColor
                                              : context.scaffoldBackgroundColor,
                                      title: isListened > 0
                                          ? Text(s.listened,
                                              style: TextStyle(
                                                  color: context.textColor
                                                      .withOpacity(0.5)))
                                          : Text(
                                              s.markListened,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                      trailingIcon: SizedBox(
                                        width: 23,
                                        height: 23,
                                        child: CustomPaint(
                                            painter: ListenedAllPainter(
                                                Colors.blue,
                                                stroke: 1.5)),
                                      ),
                                      onPressed: () async {
                                        if (isListened < 1) {
                                          await _markListened(episodes[index]);
                                          audio.setEpisodeState = true;
                                          Fluttertoast.showToast(
                                            msg: s.markListened,
                                            gravity: ToastGravity.BOTTOM,
                                          );
                                        }
                                      })
                                  : null,
                              menuList.contains(4)
                                  ? FocusedMenuItem(
                                      backgroundColor:
                                          context.brightness == Brightness.light
                                              ? context.primaryColor
                                              : context.scaffoldBackgroundColor,
                                      title: isDownloaded
                                          ? Text(s.downloaded,
                                              style: TextStyle(
                                                  color: context.textColor
                                                      .withOpacity(0.5)))
                                          : Text(s.download),
                                      trailingIcon: Icon(
                                          LineIcons.download_solid,
                                          color: Colors.green),
                                      onPressed: () {
                                        if (!isDownloaded)
                                          downloader.startTask(episodes[index]);
                                      })
                                  : null
                            ],
                            action: action,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    flex: layout == Layout.one ? 1 : 2,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        layout != Layout.one
                                            ? _circleImage(context,
                                                episode: episodes[index],
                                                color: _c,
                                                boo: boo)
                                            : _pubDate(context,
                                                episode: episodes[index],
                                                color: _c),
                                        Spacer(),
                                        //   _listenIndicater(context,
                                        //       episode: episodes[index],
                                        //       isListened: snapshot.data),
                                        _isNewIndicator(episodes[index]),
                                        _downloadIndicater(context,
                                            episode: episodes[index],
                                            isDownloaded: isDownloaded),
                                        _numberIndicater(context,
                                            index: index, color: _c)
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: layout == Layout.one ? 3 : 5,
                                    child: layout != Layout.one
                                        ? _title(episodes[index])
                                        : Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              _circleImage(context,
                                                  episode: episodes[index],
                                                  color: _c,
                                                  boo: boo),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Expanded(
                                                  child:
                                                      _title(episodes[index]))
                                            ],
                                          ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        if (layout != Layout.one)
                                          Align(
                                            alignment: Alignment.bottomLeft,
                                            child: _pubDate(context,
                                                episode: episodes[index],
                                                color: _c),
                                          ),
                                        Spacer(),
                                        layout != Layout.three &&
                                                episodes[index].duration != 0
                                            ? Container(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  _stringForSeconds(
                                                      episodes[index]
                                                          .duration
                                                          .toDouble()),
                                                  style: TextStyle(
                                                      fontSize: _width / 35),
                                                ),
                                              )
                                            : Center(),
                                        episodes[index].duration == 0 ||
                                                episodes[index]
                                                        .enclosureLength ==
                                                    null ||
                                                episodes[index]
                                                        .enclosureLength ==
                                                    0 ||
                                                layout == Layout.three
                                            ? Center()
                                            : Text(
                                                '|',
                                                style: TextStyle(
                                                  fontSize: _width / 35,
                                                  // color: _c,
                                                  // fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                        layout != Layout.three &&
                                                episodes[index]
                                                        .enclosureLength !=
                                                    null &&
                                                episodes[index]
                                                        .enclosureLength !=
                                                    0
                                            ? Container(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  ((episodes[index]
                                                                  .enclosureLength) ~/
                                                              1000000)
                                                          .toString() +
                                                      'MB',
                                                  style: TextStyle(
                                                      fontSize: _width / 35),
                                                ),
                                              )
                                            : Center(),
                                        Padding(
                                          padding: EdgeInsets.all(1),
                                        ),
                                        showFavorite || layout != Layout.three
                                            ? isLiked
                                                ? IconTheme(
                                                    data: IconThemeData(
                                                        size: _width / 35),
                                                    child: Icon(
                                                      Icons.favorite,
                                                      color: Colors.red,
                                                    ),
                                                  )
                                                : Center()
                                            : Center()
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            ),
          );
        },
      ),
    );
  }
}

class OpenContainerWrapper extends StatelessWidget {
  const OpenContainerWrapper({
    this.closedBuilder,
    this.episode,
    this.playerRunning,
  });

  final OpenContainerBuilder closedBuilder;
  final EpisodeBrief episode;
  final bool playerRunning;

  @override
  Widget build(BuildContext context) {
    return Selector<AudioPlayerNotifier, bool>(
      selector: (_, audio) => audio.playerRunning,
      builder: (_, data, __) => OpenContainer(
        playerRunning: data,
        flightWidget: CircleAvatar(
          backgroundImage: FileImage(File("${episode.imagePath}")),
        ),
        transitionDuration: Duration(milliseconds: 400),
        beginColor: Theme.of(context).primaryColor,
        endColor: Theme.of(context).primaryColor,
        closedColor: Theme.of(context).brightness == Brightness.light
            ? Theme.of(context).primaryColor
            : Theme.of(context).scaffoldBackgroundColor,
        openColor: Theme.of(context).scaffoldBackgroundColor,
        openElevation: 0,
        closedElevation: 0,
        openShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        closedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0))),
        transitionType: ContainerTransitionType.fadeThrough,
        openBuilder: (BuildContext context, VoidCallback _, bool boo) {
          return EpisodeDetail(
            episodeItem: episode,
            hide: boo,
          );
        },
        tappable: true,
        closedBuilder: closedBuilder,
      ),
    );
  }
}
