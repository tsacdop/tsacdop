import 'dart:ui';

import 'package:auto_animated/auto_animated.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../episodes/episode_detail.dart';
import '../home/audioplayer.dart';
import '../local_storage/key_value_storage.dart';
import '../local_storage/sqflite_localpodcast.dart';
import '../podcasts/podcast_detail.dart';
import '../state/audio_state.dart';
import '../state/download_state.dart';
import '../type/episodebrief.dart';
import '../type/play_histroy.dart';
import '../type/podcastlocal.dart';
import '../util/extension_helper.dart';
import '../util/open_container.dart';
import '../util/pageroute.dart';
import 'custom_widget.dart';
import 'general_dialog.dart';

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
  final bool multiSelect;
  final ValueChanged<List<EpisodeBrief>> onSelect;
  final bool openPodcast;
  final List<EpisodeBrief> selectedList;

  /// Count of animation items.
  final int initNum;

  EpisodeGrid(
      {Key key,
      @required this.episodes,
      this.initNum = 12,
      this.showDownload = false,
      this.showFavorite = false,
      this.showNumber = false,
      this.episodeCount = 0,
      this.layout = Layout.three,
      this.reverse,
      this.openPodcast = false,
      this.multiSelect = false,
      this.onSelect,
      this.selectedList})
      : super(key: key);

  List<EpisodeBrief> _selectedList = [];
  final _dbHelper = DBHelper();

  Future<int> _isListened(EpisodeBrief episode) async {
    return await _dbHelper.isListened(episode.enclosureUrl);
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
    return await _dbHelper.isLiked(episode.enclosureUrl);
  }

  Future<List<int>> _getEpisodeMenu() async {
    var popupMenuStorage = KeyValueStorage(episodePopupMenuKey);
    var list = await popupMenuStorage.getMenu();
    return list;
  }

  Future<bool> _isDownloaded(EpisodeBrief episode) async {
    return await _dbHelper.isDownloaded(episode.enclosureUrl);
  }

  Future<bool> _getTapToOpenPopupMenu() async {
    var tapToOpenPopupMenuStorage = KeyValueStorage(tapToOpenPopupMenuKey);
    var boo = await tapToOpenPopupMenuStorage.getBool(defaultValue: false);
    return boo;
  }

  Future<void> _markListened(EpisodeBrief episode) async {
    final history = PlayHistory(episode.title, episode.enclosureUrl, 0, 1);
    await _dbHelper.saveHistory(history);
  }

  Future<void> _markNotListened(String url) async {
    await _dbHelper.markNotListened(url);
  }

  Future<void> _saveLiked(String url) async {
    await _dbHelper.setLiked(url);
  }

  Future<void> _setUnliked(String url) async {
    await _dbHelper.setUniked(url);
  }

  Future<void> _requestDownload(BuildContext context,
      {EpisodeBrief episode}) async {
    final permissionReady = await _checkPermmison();
    final downloadUsingData = await KeyValueStorage(downloadUsingDataKey)
        .getBool(defaultValue: true, reverse: true);
    final result = await Connectivity().checkConnectivity();
    final usingData = result == ConnectivityResult.mobile;
    var dataConfirm = true;
    if (permissionReady) {
      if (downloadUsingData && usingData) {
        dataConfirm = await _useDataConfirm(context);
      }
      if (dataConfirm) {
        context.read<DownloadState>().startTask(episode);
        Fluttertoast.showToast(
          msg: context.s.downloadStart,
          gravity: ToastGravity.BOTTOM,
        );
      }
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

  Future<bool> _useDataConfirm(BuildContext context) async {
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

  Future<PodcastLocal> _getPodcast(String url) async {
    var podcasts = await _dbHelper.getPodcastWithUrl(url);
    return podcasts;
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
          {EpisodeBrief episode, Color color, bool boo, double radius}) =>
      InkWell(
        onTap: () async {
          if (openPodcast) {
            final podcast = await _getPodcast(episode.enclosureUrl);
            Navigator.push(
              context,
              SlideLeftRoute(
                  page: PodcastDetail(
                podcastLocal: podcast,
              )),
            );
          }
        },
        child: Container(
          height: radius ?? context.width / 16,
          width: radius ?? context.width / 16,
          child: boo
              ? Center()
              : CircleAvatar(
                  backgroundColor: color.withOpacity(0.5),
                  backgroundImage: episode.avatarImage),
        ),
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
        textAlign: TextAlign.center,
        style: TextStyle(
            height: 1,
            fontSize: context.width / 35,
            color: color,
            fontStyle: FontStyle.italic),
      );
  Widget _episodeCard(BuildContext context,
      {int index, Color color, bool isLiked, bool isDownloaded, bool boo}) {
    var width = context.width;
    if (layout == Layout.one) {
      return _layoutOneCard(context,
          index: index,
          color: color,
          isLiked: isLiked,
          isDownloaded: isDownloaded,
          boo: boo);
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: layout == Layout.one ? 1 : 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                layout != Layout.one
                    ? _circleImage(context,
                        episode: episodes[index], color: color, boo: boo)
                    : _pubDate(context, episode: episodes[index], color: color),
                Spacer(),
                _isNewIndicator(episodes[index]),
                _downloadIndicater(context,
                    episode: episodes[index], isDownloaded: isDownloaded),
                _numberIndicater(context, index: index, color: color)
              ],
            ),
          ),
          Expanded(
            flex: layout == Layout.one ? 3 : 5,
            child: layout != Layout.one
                ? _title(episodes[index])
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _circleImage(context,
                          episode: episodes[index], color: color, boo: boo),
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(child: _title(episodes[index]))
                    ],
                  ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                if (layout != Layout.one)
                  _pubDate(context, episode: episodes[index], color: color),
                Spacer(),
                if (layout != Layout.three && episodes[index].duration != 0)
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      episodes[index].duration.toTime,
                      style: TextStyle(fontSize: width / 35),
                    ),
                  ),
                if (episodes[index].duration != 0 &&
                    episodes[index].enclosureLength != null &&
                    episodes[index].enclosureLength != 0 &&
                    layout != Layout.three)
                  Text(
                    '|',
                    style: TextStyle(
                      fontSize: width / 35,
                    ),
                  ),
                if (layout != Layout.three &&
                    episodes[index].enclosureLength != null &&
                    episodes[index].enclosureLength != 0)
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      '${(episodes[index].enclosureLength) ~/ 1000000}MB',
                      style: TextStyle(fontSize: width / 35),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.all(1),
                ),
                if ((showFavorite || layout != Layout.three) && isLiked)
                  Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: width / 35,
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _layoutOneCard(BuildContext context,
      {int index, Color color, bool isLiked, bool isDownloaded, bool boo}) {
    var width = context.width;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: Center(
              child: _circleImage(context,
                  episode: episodes[index],
                  color: color,
                  boo: boo,
                  radius: context.width / 8),
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Text(episodes[index].feedTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: color)),
                      ),
                      _isNewIndicator(episodes[index]),
                      _downloadIndicater(context,
                          episode: episodes[index], isDownloaded: isDownloaded),
                      _numberIndicater(context, index: index, color: color)
                    ],
                  ),
                ),
                Expanded(
                    flex: 2,
                    child: Align(
                        alignment: Alignment.topLeft,
                        child: _title(episodes[index]))),
                Expanded(
                  flex: 1,
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        if (episodes[index].duration != 0)
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              episodes[index].duration.toTime,
                              style: TextStyle(fontSize: width / 35),
                            ),
                          ),
                        if (episodes[index].duration != 0 &&
                            episodes[index].enclosureLength != null &&
                            episodes[index].enclosureLength != 0 &&
                            layout != Layout.three)
                          Text(
                            '|',
                            style: TextStyle(
                              fontSize: width / 35,
                            ),
                          ),
                        if (episodes[index].enclosureLength != null &&
                            episodes[index].enclosureLength != 0)
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              '${(episodes[index].enclosureLength) ~/ 1000000}MB',
                              style: TextStyle(fontSize: width / 35),
                            ),
                          ),
                        SizedBox(width: 4),
                        if (isLiked)
                          Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: width / 35,
                          ),
                        Spacer(),
                        _pubDate(context,
                            episode: episodes[index], color: color),
                      ]),
                )
              ],
            ),
          ),
          SizedBox(width: 8)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var audio = Provider.of<AudioPlayerNotifier>(context, listen: false);
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
          childAspectRatio: layout == Layout.three
              ? 1
              : layout == Layout.two
                  ? 1.5
                  : 4,
          crossAxisCount: layout == Layout.three
              ? 3
              : layout == Layout.two
                  ? 2
                  : 1,
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
                Tuple4<EpisodeBrief, List<String>, bool, bool>>(
              selector: (_, audio) => Tuple4(
                  audio?.episode,
                  audio.queue.episodes.map((e) => e.enclosureUrl).toList(),
                  audio.episodeState,
                  audio.playerRunning),
              builder: (_, data, __) => OpenContainerWrapper(
                avatarSize: layout == Layout.one
                    ? context.width / 8
                    : context.width / 16,
                episode: episodes[index],
                closedBuilder: (context, action, boo) =>
                    FutureBuilder<Tuple5<int, bool, bool, bool, List<int>>>(
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
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          color: isListened > 0
                              ? context.brightness == Brightness.light
                                  ? Colors.grey[200]
                                  : Color.fromRGBO(50, 50, 50, 1)
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
                      child: multiSelect
                          ? Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  if (!selectedList.contains(episodes[index])) {
                                    _selectedList = selectedList;
                                    _selectedList.add(episodes[index]);
                                  } else {
                                    _selectedList = selectedList;
                                    _selectedList.remove(episodes[index]);
                                  }
                                  onSelect(_selectedList);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    border: Border.all(
                                      color: selectedList
                                              .contains(episodes[index])
                                          ? context.accentColor
                                          : context.brightness ==
                                                  Brightness.light
                                              ? context.primaryColor
                                              : context.scaffoldBackgroundColor,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: _episodeCard(context,
                                      index: index,
                                      isLiked: isLiked,
                                      isDownloaded: isDownloaded,
                                      color: c,
                                      boo: boo),
                                ),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
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
                                    borderRadius: BorderRadius.circular(15.0)),
                                duration: Duration(milliseconds: 100),
                                tapMode: tapToOpen
                                    ? TapMode.onTap
                                    : TapMode.onLongPress,
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
                                      title: Text(
                                          data.item1 != episodes[index] ||
                                                  !data.item4
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
                                  if (menuList.contains(1))
                                    FocusedMenuItem(
                                        backgroundColor: context.brightness ==
                                                Brightness.light
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
                                            audio
                                                .addToPlaylist(episodes[index]);
                                            Fluttertoast.showToast(
                                              msg: s.toastAddPlaylist,
                                              gravity: ToastGravity.BOTTOM,
                                            );
                                          } else {
                                            audio.delFromPlaylist(
                                                episodes[index]);
                                            Fluttertoast.showToast(
                                              msg: s.toastRemovePlaylist,
                                              gravity: ToastGravity.BOTTOM,
                                            );
                                          }
                                        }),
                                  if (menuList.contains(2))
                                    FocusedMenuItem(
                                        backgroundColor: context.brightness ==
                                                Brightness.light
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
                                        }),
                                  if (menuList.contains(3))
                                    FocusedMenuItem(
                                        backgroundColor: context.brightness ==
                                                Brightness.light
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
                                            await _markListened(
                                                episodes[index]);
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
                                        }),
                                  if (menuList.contains(4))
                                    FocusedMenuItem(
                                        backgroundColor: context.brightness ==
                                                Brightness.light
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
                                        onPressed: () async {
                                          if (!isDownloaded) {
                                            await _requestDownload(context,
                                                episode: episodes[index]);
                                          }
                                        }),
                                  if (menuList.contains(5))
                                    FocusedMenuItem(
                                        backgroundColor: context.brightness ==
                                                Brightness.light
                                            ? context.primaryColor
                                            : context.dialogBackgroundColor,
                                        title: Text(s.playNext),
                                        trailingIcon: Icon(
                                          LineIcons.bolt_solid,
                                          color: Colors.amber,
                                        ),
                                        onPressed: () {
                                          audio.moveToTop(episodes[index]);
                                          Fluttertoast.showToast(
                                            msg: s.playNextDes,
                                            gravity: ToastGravity.BOTTOM,
                                          );
                                        }),
                                ],
                                action: action,
                                child: _episodeCard(context,
                                    index: index,
                                    isLiked: isLiked,
                                    isDownloaded: isDownloaded,
                                    color: c,
                                    boo: boo),
                              ),
                            ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class OpenContainerWrapper extends StatelessWidget {
  const OpenContainerWrapper(
      {this.closedBuilder, this.episode, this.playerRunning, this.avatarSize});

  final OpenContainerBuilder closedBuilder;
  final EpisodeBrief episode;
  final bool playerRunning;
  final double avatarSize;

  @override
  Widget build(BuildContext context) {
    return Selector<AudioPlayerNotifier, Tuple2<bool, PlayerHeight>>(
      selector: (_, audio) => Tuple2(audio.playerRunning, audio.playerHeight),
      builder: (_, data, __) => OpenContainer(
        playerRunning: data.item1,
        playerHeight: kMinPlayerHeight[data.item2.index],
        flightWidget: CircleAvatar(backgroundImage: episode.avatarImage),
        flightWidgetSize: avatarSize,
        transitionDuration: Duration(milliseconds: 400),
        beginColor: Theme.of(context).primaryColor,
        endColor: Theme.of(context).primaryColor,
        closedColor: Theme.of(context).brightness == Brightness.light
            ? Theme.of(context).primaryColor
            : Theme.of(context).scaffoldBackgroundColor,
        openColor: Theme.of(context).scaffoldBackgroundColor,
        openElevation: 0,
        closedElevation: 0,
        openShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        closedShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
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
