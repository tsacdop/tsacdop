import 'dart:ui';

import 'package:auto_animated/auto_animated.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../episodes/episode_detail.dart';
import '../home/audioplayer.dart';
import '../local_storage/key_value_storage.dart';
import '../local_storage/sqflite_localpodcast.dart';
import '../state/audio_state.dart';
import '../state/download_state.dart';
import '../type/episodebrief.dart';
import '../type/play_histroy.dart';
import 'custom_widget.dart';
import 'extension_helper.dart';
import 'open_container.dart';

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

  /// Count of animation items.
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

  Future<int> _isListened(EpisodeBrief episode) async {
    var dbHelper = DBHelper();
    return await dbHelper.isListened(episode.enclosureUrl);
  }

  Future<Tuple5<int, bool, bool, bool, List<int>>> _initData(
      EpisodeBrief episode) async {
    var menuList = await _getEpisodeMenu();
    var tapToOpen = await _getTapToOpenPopupMenu();
    var listened = await _isListened(episode);
    var liked = await _isLiked(episode);
    var downloaded = await _isDownloaded(episode);
    return Tuple5(listened, liked, downloaded, tapToOpen, menuList);
  }

  Future<bool> _isLiked(EpisodeBrief episode) async {
    var dbHelper = DBHelper();
    return await dbHelper.isLiked(episode.enclosureUrl);
  }

  Future<List<int>> _getEpisodeMenu() async {
    var popupMenuStorage = KeyValueStorage(episodePopupMenuKey);
    var list = await popupMenuStorage.getMenu();
    return list;
  }

  Future<bool> _isDownloaded(EpisodeBrief episode) async {
    var dbHelper = DBHelper();
    return await dbHelper.isDownloaded(episode.enclosureUrl);
  }

  Future<bool> _getTapToOpenPopupMenu() async {
    var tapToOpenPopupMenuStorage = KeyValueStorage(tapToOpenPopupMenuKey);
    var boo = await tapToOpenPopupMenuStorage.getBool(defaultValue: false);
    return boo;
  }

  Future<void> _markListened(EpisodeBrief episode) async {
    var dbHelper = DBHelper();
    final history = PlayHistory(episode.title, episode.enclosureUrl, 0, 1);
    await dbHelper.saveHistory(history);
  }

  Future<void> _markNotListened(String url) async {
    var dbHelper = DBHelper();
    await dbHelper.markNotListened(url);
  }

  Future<void> _saveLiked(String url) async {
    var dbHelper = DBHelper();
    await dbHelper.setLiked(url);
  }

  Future<void> _setUnliked(String url) async {
    var dbHelper = DBHelper();
    await dbHelper.setUniked(url);
  }

  /// Episode title widget.
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

  /// Circel avatar widget.
  Widget _circleImage(BuildContext context,
          {EpisodeBrief episode, Color color, bool boo}) =>
      Container(
        height: context.width / 16,
        width: context.width / 16,
        child: boo
            ? Center()
            : CircleAvatar(
                backgroundColor: color.withOpacity(0.5),
                backgroundImage: episode.avatarImage),
      );

  Widget _downloadIndicater(BuildContext context,
          {EpisodeBrief episode, bool isDownloaded}) =>
      showDownload || layout != Layout.three
          ? isDownloaded
              ? Container(
                  height: 20,
                  width: 20,
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  padding: EdgeInsets.fromLTRB(2, 2, 2, 3),
                  decoration: BoxDecoration(
                    color: context.accentColor,
                    shape: BoxShape.circle,
                  ),
                  child: CustomPaint(
                    size: Size(12, 12),
                    painter: DownloadPainter(
                      stroke: 1.0,
                      color: context.accentColor,
                      fraction: 1,
                      progressColor: Colors.white,
                      progress: 1,
                    ),
                  ),
                )
              : Center()
          : Center();

  /// New indicator widget.
  Widget _isNewIndicator(EpisodeBrief episode) => episode.isNew == 1
      ? Container(
          padding: EdgeInsets.symmetric(horizontal: 2),
          child: Text('New',
              style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic)),
        )
      : Center();

  /// Count indicator widget.
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

  /// Pubdate widget
  Widget _pubDate(BuildContext context, {EpisodeBrief episode, Color color}) =>
      Text(
        episode.pubDate.toDate(context),
        overflow: TextOverflow.visible,
        style: TextStyle(
            fontSize: context.width / 35,
            color: color,
            fontStyle: FontStyle.italic),
      );

  @override
  Widget build(BuildContext context) {
    var _width = context.width;
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
          final c = episodes[index].backgroudColor(context);
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
                    builder: (context, snapshot) {
                      var isListened = snapshot.data.item1;
                      var isLiked = snapshot.data.item2;
                      var isDownloaded = snapshot.data.item3;
                      var tapToOpen = snapshot.data.item4;
                      var menuList = snapshot.data.item5;
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
                                          : context.dialogBackgroundColor,
                                  title: Text(data.item1 != episodes[index]
                                      ? s.play
                                      : s.playing),
                                  trailingIcon: Icon(
                                    LineIcons.play_circle_solid,
                                    color: Theme.of(context).accentColor,
                                  ),
                                  onPressed: () {
                                    if (data.item1 != episodes[index]) {
                                      audio.episodeLoad(episodes[index]);
                                    }
                                  }),
                              menuList.contains(1)
                                  ? FocusedMenuItem(
                                      backgroundColor:
                                          context.brightness == Brightness.light
                                              ? context.primaryColor
                                              : context.dialogBackgroundColor,
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
                                              : context.dialogBackgroundColor,
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
                                              : context.dialogBackgroundColor,
                                      title: isListened > 0
                                          ? Text(s.markNotListened,
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
                                        } else {
                                          await _markNotListened(
                                              episodes[index].enclosureUrl);
                                          audio.setEpisodeState = true;
                                          Fluttertoast.showToast(
                                            msg: s.markNotListened,
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
                                              : context.dialogBackgroundColor,
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
                                        if (!isDownloaded) {
                                          downloader.startTask(episodes[index]);
                                        }
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        layout != Layout.one
                                            ? _circleImage(context,
                                                episode: episodes[index],
                                                color: c,
                                                boo: boo)
                                            : _pubDate(context,
                                                episode: episodes[index],
                                                color: c),
                                        Spacer(),

                                        ///   _listenIndicater(context,
                                        //       episode: episodes[index],
                                        //       isListened: snapshot.data),
                                        _isNewIndicator(episodes[index]),
                                        _downloadIndicater(context,
                                            episode: episodes[index],
                                            isDownloaded: isDownloaded),
                                        _numberIndicater(context,
                                            index: index, color: c)
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
                                                  color: c,
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
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        if (layout != Layout.one)
                                          _pubDate(context,
                                              episode: episodes[index],
                                              color: c),
                                        Spacer(),
                                        if (layout != Layout.three &&
                                            episodes[index].duration != 0)
                                          Container(
                                            alignment: Alignment.center,
                                            child: Text(
                                              episodes[index].duration.toTime,
                                              style: TextStyle(
                                                  fontSize: _width / 35),
                                            ),
                                          ),
                                        if (episodes[index].duration != 0 &&
                                            episodes[index].enclosureLength !=
                                                null &&
                                            episodes[index].enclosureLength !=
                                                0 &&
                                            layout != Layout.three)
                                          Text(
                                            '|',
                                            style: TextStyle(
                                              fontSize: _width / 35,
                                              // color: _c,
                                              // fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        if (layout != Layout.three &&
                                            episodes[index].enclosureLength !=
                                                null &&
                                            episodes[index].enclosureLength !=
                                                0)
                                          Container(
                                            alignment: Alignment.center,
                                            child: Text(
                                              '${(episodes[index].enclosureLength) ~/ 1000000}MB',
                                              style: TextStyle(
                                                  fontSize: _width / 35),
                                            ),
                                          ),
                                        Padding(
                                          padding: EdgeInsets.all(1),
                                        ),
                                        if ((showFavorite ||
                                                layout != Layout.three) &&
                                            isLiked)
                                          Icon(
                                            Icons.favorite,
                                            color: Colors.red,
                                            size: _width / 35,
                                          )
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
    return Selector<AudioPlayerNotifier, Tuple2<bool, PlayerHeight>>(
      selector: (_, audio) => Tuple2(audio.playerRunning, audio.playerHeight),
      builder: (_, data, __) => OpenContainer(
        playerRunning: data.item1,
        playerHeight: kMinPlayerHeight[data.item2.index],
        flightWidget: CircleAvatar(backgroundImage: episode.avatarImage),
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
        openBuilder: (context, _, boo) {
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
