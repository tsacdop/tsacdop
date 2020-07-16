import 'dart:io';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tuple/tuple.dart';
import 'package:line_icons/line_icons.dart';

import '../type/episodebrief.dart';
import '../state/podcast_group.dart';
import '../state/download_state.dart';
import '../type/podcastlocal.dart';
import '../state/audio_state.dart';
import '../util/custompaint.dart';
import '../util/pageroute.dart';
import '../util/colorize.dart';
import '../util/context_extension.dart';
import '../local_storage/sqflite_localpodcast.dart';
import '../local_storage/key_value_storage.dart';
import '../episodes/episode_detail.dart';
import '../podcasts/podcast_detail.dart';
import '../podcasts/podcast_manage.dart';

class ScrollPodcasts extends StatefulWidget {
  @override
  _ScrollPodcastsState createState() => _ScrollPodcastsState();
}

class _ScrollPodcastsState extends State<ScrollPodcasts> {
  int _groupIndex;

  Future<int> getPodcastUpdateCounts(String id) async {
    var dbHelper = DBHelper();
    return await dbHelper.getPodcastUpdateCounts(id);
  }

  @override
  void initState() {
    super.initState();
    _groupIndex = 0;
  }

  Widget _circleContainer(BuildContext context) => Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        height: 50,
        width: 50,
        decoration:
            BoxDecoration(shape: BoxShape.circle, color: context.primaryColor),
      );

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    final s = context.s;
    return Consumer<GroupList>(builder: (_, groupList, __) {
      var groups = groupList.groups;
      bool import = groupList.created;
      bool isLoading = groupList.isLoading;
      return isLoading
          ? Container(
              height: (_width - 20) / 3 + 140,
            )
          : groups[_groupIndex].podcastList.length == 0
              ? Container(
                  height: (_width - 20) / 3 + 140,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      GestureDetector(
                          onVerticalDragEnd: (event) {
                            if (event.primaryVelocity > 200) {
                              if (groups.length == 1) {
                                Fluttertoast.showToast(
                                  msg: s.addSomeGroups,
                                  gravity: ToastGravity.BOTTOM,
                                );
                              } else {
                                if (mounted)
                                  setState(() {
                                    (_groupIndex != 0)
                                        ? _groupIndex--
                                        : _groupIndex = groups.length - 1;
                                  });
                              }
                            } else if (event.primaryVelocity < -200) {
                              if (groups.length == 1) {
                                Fluttertoast.showToast(
                                  msg: s.addSomeGroups,
                                  gravity: ToastGravity.BOTTOM,
                                );
                              } else {
                                setState(() {
                                  (_groupIndex < groups.length - 1)
                                      ? _groupIndex++
                                      : _groupIndex = 0;
                                });
                              }
                            }
                          },
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 15.0),
                                        child: Text(
                                          groups[_groupIndex].name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .accentColor),
                                        )),
                                    Spacer(),
                                    Container(
                                      height: 30,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 15),
                                      alignment: Alignment.bottomRight,
                                      child: InkWell(
                                        onTap: () {
                                          if (!import)
                                            Navigator.push(
                                              context,
                                              SlideLeftRoute(
                                                  page: PodcastManage()),
                                            );
                                        },
                                        child: Container(
                                          height: 30,
                                          padding: EdgeInsets.all(5.0),
                                          child: Text(
                                            s.homeGroupsSeeAll,
                                            style: context.textTheme.bodyText1
                                                .copyWith(
                                                    color: import
                                                        ? context
                                                            .primaryColorDark
                                                        : context.accentColor),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                  height: 70,
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  child: Row(
                                    children: <Widget>[
                                      _circleContainer(context),
                                      _circleContainer(context),
                                      _circleContainer(context)
                                    ],
                                  )),
                            ],
                          )),
                      Container(
                        height: (_width - 20) / 3 + 40,
                        color: Theme.of(context).primaryColor,
                        margin: EdgeInsets.symmetric(horizontal: 15),
                        child: Center(
                            child: _groupIndex == 0
                                ? Text.rich(TextSpan(
                                    style: context.textTheme.headline6
                                        .copyWith(height: 2),
                                    children: [
                                      TextSpan(
                                          text: 'Welcome to Tsacdop\n',
                                          style: context.textTheme.headline6
                                              .copyWith(
                                                  color: context.accentColor)),
                                      TextSpan(
                                          text: 'Get started\n',
                                          style: context.textTheme.headline6
                                              .copyWith(
                                                  color: context.accentColor)),
                                      TextSpan(text: 'Tap '),
                                      WidgetSpan(
                                          child:
                                              Icon(Icons.add_circle_outline)),
                                      TextSpan(text: ' to subscribe podcasts')
                                    ],
                                  ))
                                : Text(s.noPodcastGroup,
                                    style: TextStyle(
                                        color: context.textTheme.bodyText2.color
                                            .withOpacity(0.5)))),
                      ),
                    ],
                  ),
                )
              : DefaultTabController(
                  length: groups[_groupIndex].podcastList.length,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      GestureDetector(
                        onVerticalDragEnd: (event) {
                          if (event.primaryVelocity > 200) {
                            if (groups.length == 1) {
                              Fluttertoast.showToast(
                                msg: s.addSomeGroups,
                                gravity: ToastGravity.BOTTOM,
                              );
                            } else {
                              if (mounted)
                                setState(() {
                                  (_groupIndex != 0)
                                      ? _groupIndex--
                                      : _groupIndex = groups.length - 1;
                                });
                            }
                          } else if (event.primaryVelocity < -200) {
                            if (groups.length == 1) {
                              Fluttertoast.showToast(
                                msg: s.addSomeGroups,
                                gravity: ToastGravity.BOTTOM,
                              );
                            } else {
                              setState(() {
                                (_groupIndex < groups.length - 1)
                                    ? _groupIndex++
                                    : _groupIndex = 0;
                              });
                            }
                          }
                        },
                        child: Column(
                          children: <Widget>[
                            Container(
                              child: Row(
                                children: <Widget>[
                                  Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15.0),
                                      child: Text(
                                        groups[_groupIndex].name,
                                        style: context.textTheme.bodyText1
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .accentColor),
                                      )),
                                  Spacer(),
                                  Container(
                                    height: 30.0,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 15),
                                    alignment: Alignment.bottomRight,
                                    child: InkWell(
                                      onTap: () {
                                        if (!import)
                                          Navigator.push(
                                            context,
                                            SlideLeftRoute(
                                                page: PodcastManage()),
                                          );
                                      },
                                      child: Container(
                                        height: 30,
                                        padding: EdgeInsets.all(5.0),
                                        child: Text(
                                          s.homeGroupsSeeAll,
                                          style: context.textTheme.bodyText1
                                              .copyWith(
                                                  color: import
                                                      ? context.primaryColorDark
                                                      : context.accentColor),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 70,
                              width: _width,
                              alignment: Alignment.centerLeft,
                              color: context.scaffoldBackgroundColor,
                              child: TabBar(
                                labelPadding: EdgeInsets.only(
                                    top: 5.0,
                                    bottom: 10.0,
                                    left: 6.0,
                                    right: 6.0),
                                indicator: CircleTabIndicator(
                                    color: context.accentColor, radius: 3),
                                isScrollable: true,
                                tabs: groups[_groupIndex]
                                    .podcasts
                                    .map<Widget>((PodcastLocal podcastLocal) {
                                  return Tab(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(25.0)),
                                      child: Stack(
                                        alignment: Alignment.bottomCenter,
                                        children: <Widget>[
                                          LimitedBox(
                                            maxHeight: 50,
                                            maxWidth: 50,
                                            child: Image.file(File(
                                                "${podcastLocal.imagePath}")),
                                          ),
                                          FutureBuilder<int>(
                                              future: getPodcastUpdateCounts(
                                                  podcastLocal.id),
                                              initialData: 0,
                                              builder: (context, snapshot) {
                                                return snapshot.data > 0
                                                    ? Container(
                                                        alignment:
                                                            Alignment.center,
                                                        height: 10,
                                                        width: 40,
                                                        color: Colors.black54,
                                                        child: Text('New',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red,
                                                                fontSize: 8,
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic)),
                                                      )
                                                    : Center();
                                              }),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: (_width - 20) / 3 + 40,
                        margin: EdgeInsets.only(left: 10, right: 10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                        child: TabBarView(
                          children: groups[_groupIndex]
                              .podcasts
                              .map<Widget>((PodcastLocal podcastLocal) {
                            return Container(
                              decoration: BoxDecoration(
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Theme.of(context).primaryColor
                                      : Colors.black12),
                              margin: EdgeInsets.symmetric(horizontal: 5.0),
                              key: ObjectKey(podcastLocal.title),
                              child: PodcastPreview(
                                podcastLocal: podcastLocal,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                );
    });
  }
}

class PodcastPreview extends StatelessWidget {
  final PodcastLocal podcastLocal;
  PodcastPreview({this.podcastLocal, Key key}) : super(key: key);

  Future<List<EpisodeBrief>> _getRssItemTop(PodcastLocal podcastLocal) async {
    var dbHelper = DBHelper();
    List<EpisodeBrief> episodes = await dbHelper.getRssItemTop(podcastLocal.id);
    return episodes;
  }

  @override
  Widget build(BuildContext context) {
    Color _c = (Theme.of(context).brightness == Brightness.light)
        ? podcastLocal.primaryColor.colorizedark()
        : podcastLocal.primaryColor.colorizeLight();
    return Column(
      children: <Widget>[
        Expanded(
          child: Selector<GroupList, bool>(
              selector: (_, worker) => worker.created,
              builder: (context, created, child) {
                return FutureBuilder<List<EpisodeBrief>>(
                  future: _getRssItemTop(podcastLocal),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      print(snapshot.error);
                      Center();
                    }
                    return (snapshot.hasData)
                        ? ShowEpisode(
                            episodes: snapshot.data,
                            podcastLocal: podcastLocal,
                          )
                        : Container(
                            padding: EdgeInsets.all(5.0),
                          );
                  },
                );
              }),
        ),
        Container(
          height: 40,
          padding: EdgeInsets.only(left: 10.0),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 4,
                child: Text(podcastLocal.title,
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                    style: TextStyle(fontWeight: FontWeight.bold, color: _c)),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.centerRight,
                  child: Material(
                    color: Colors.transparent,
                    child: Selector<AudioPlayerNotifier, bool>(
                      selector: (_, audio) => audio.playerRunning,
                      builder: (_, playerRunning, __) => IconButton(
                        icon: Icon(Icons.arrow_forward),
                        tooltip: context.s.homeGroupsSeeAll,
                        onPressed: () {
                          Navigator.push(
                            context,
                            SlideLeftHideRoute(
                                transitionPage: PodcastDetail(
                                  podcastLocal: podcastLocal,
                                  hide: playerRunning,
                                ),
                                page: PodcastDetail(
                                  podcastLocal: podcastLocal,
                                )),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ShowEpisode extends StatelessWidget {
  final List<EpisodeBrief> episodes;
  final PodcastLocal podcastLocal;
  ShowEpisode({Key key, this.episodes, this.podcastLocal}) : super(key: key);
  String _stringForSeconds(double seconds) {
    if (seconds == null) return null;
    return '${(seconds ~/ 60)}:${(seconds.truncate() % 60).toString().padLeft(2, '0')}';
  }

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

  Future<Tuple5<int, bool, bool, bool, List<int>>> _initData(
      EpisodeBrief episode) async {
    List<int> menuList = await _getEpisodeMenu();
    bool tapToOpen = await _getTapToOpenPopupMenu();
    int listened = await _isListened(episode);

    bool liked = await _isLiked(episode);
    bool downloaded = await _isDownloaded(episode);

    return Tuple5(listened, liked, downloaded, tapToOpen, menuList);
  }

  Future<int> _isListened(EpisodeBrief episode) async {
    DBHelper dbHelper = DBHelper();
    return await dbHelper.isListened(episode.enclosureUrl);
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
    int boo = await tapToOpenPopupMenuStorage.getInt(defaultValue: 0);
    return boo == 1;
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

  @override
  Widget build(BuildContext context) {
    double _width = context.width;
    final s = context.s;
    var downloader = Provider.of<DownloadState>(context, listen: false);
    var audio = Provider.of<AudioPlayerNotifier>(context, listen: false);
    return CustomScrollView(
      physics: NeverScrollableScrollPhysics(),
      primary: false,
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.all(5.0),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 1.5,
              crossAxisCount: 2,
              mainAxisSpacing: 6.0,
              crossAxisSpacing: 6.0,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                Color _c = (Theme.of(context).brightness == Brightness.light)
                    ? podcastLocal.primaryColor.colorizedark()
                    : podcastLocal.primaryColor.colorizeLight();
                return Selector<AudioPlayerNotifier,
                        Tuple2<EpisodeBrief, List<String>>>(
                    selector: (_, audio) => Tuple2(
                          audio?.episode,
                          audio.queue.playlist
                              .map((e) => e.enclosureUrl)
                              .toList(),
                        ),
                    builder: (_, data, __) => FutureBuilder<
                            Tuple5<int, bool, bool, bool, List<int>>>(
                        future: _initData(episodes[index]),
                        initialData: Tuple5(0, false, false, false, []),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          int isListened = snapshot.data.item1;
                          bool isLiked = snapshot.data.item2;
                          bool isDownloaded = snapshot.data.item3;
                          bool tapToOpen = snapshot.data.item4;
                          List<int> menuList = snapshot.data.item5;
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                            alignment: Alignment.center,
                            child: FocusedMenuHolder(
                              blurSize: 0.0,
                              menuItemExtent: 45,
                              menuBoxDecoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0))),
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
                                        backgroundColor: context.brightness ==
                                                Brightness.light
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
                                        })
                                    : null,
                                menuList.contains(2)
                                    ? FocusedMenuItem(
                                        backgroundColor: context.brightness ==
                                                Brightness.light
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
                                        backgroundColor: context.brightness ==
                                                Brightness.light
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
                                            await _markListened(
                                                episodes[index]);
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
                                        backgroundColor: context.brightness ==
                                                Brightness.light
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
                                            downloader
                                                .startTask(episodes[index]);
                                        })
                                    : null
                              ],
                              action: () => Navigator.push(
                                context,
                                ScaleRoute(
                                    page: EpisodeDetail(
                                  episodeItem: episodes[index],
                                  heroTag: 'scroll',
                                  //unique hero tag
                                )),
                              ),
                              child: Container(
                                padding: EdgeInsets.all(10.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 2,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Hero(
                                            tag: episodes[index].enclosureUrl +
                                                'scroll',
                                            child: Container(
                                              height: _width / 18,
                                              width: _width / 18,
                                              child: CircleAvatar(
                                                backgroundImage: FileImage(File(
                                                    "${podcastLocal.imagePath}")),
                                              ),
                                            ),
                                          ),
                                          Spacer(),
                                          Selector<AudioPlayerNotifier,
                                                  Tuple2<EpisodeBrief, bool>>(
                                              selector: (_, audio) => Tuple2(
                                                  audio.episode,
                                                  audio.playerRunning),
                                              builder: (_, data, __) {
                                                return (episodes[index]
                                                                .enclosureUrl ==
                                                            data.item1
                                                                ?.enclosureUrl &&
                                                        data.item2)
                                                    ? Container(
                                                        height: 20,
                                                        width: 20,
                                                        margin: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 2),
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: WaveLoader(
                                                            color: context
                                                                .accentColor))
                                                    : Center();
                                              }),
                                          episodes[index].isNew == 1
                                              ? Text(
                                                  'New',
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontStyle:
                                                          FontStyle.italic),
                                                )
                                              : Center(),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Container(
                                        padding: EdgeInsets.only(top: 2.0),
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          episodes[index].title,
                                          style: TextStyle(
                                              //fontSize: _width / 32,
                                              ),
                                          maxLines: 4,
                                          overflow: TextOverflow.fade,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                        flex: 1,
                                        child: Row(
                                          children: <Widget>[
                                            Container(
                                              alignment: Alignment.bottomLeft,
                                              child: Text(
                                                _dateToString(context,
                                                    pubDate: episodes[index]
                                                        .pubDate),
                                                style: TextStyle(
                                                  fontSize: _width / 35,
                                                  color: _c,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ),
                                            Spacer(),
                                            episodes[index].duration != 0
                                                ? Container(
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      _stringForSeconds(
                                                              episodes[index]
                                                                  .duration
                                                                  .toDouble())
                                                          .toString(),
                                                      style: TextStyle(
                                                        fontSize: _width / 35,
                                                        // color: _c,
                                                        // fontStyle: FontStyle.italic,
                                                      ),
                                                    ),
                                                  )
                                                : Center(),
                                            episodes[index].duration == 0 ||
                                                    episodes[index]
                                                            .enclosureLength ==
                                                        null ||
                                                    episodes[index]
                                                            .enclosureLength ==
                                                        0
                                                ? Center()
                                                : Text(
                                                    '|',
                                                    style: TextStyle(
                                                      fontSize: _width / 35,
                                                      // color: _c,
                                                      // fontStyle: FontStyle.italic,
                                                    ),
                                                  ),
                                            episodes[index].enclosureLength !=
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
                                                          fontSize:
                                                              _width / 35),
                                                    ),
                                                  )
                                                : Center(),
                                          ],
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }));
              },
              childCount: (episodes.length > 2) ? 2 : episodes.length,
            ),
          ),
        ),
      ],
    );
  }
}

//Circle Indicator
class CircleTabIndicator extends Decoration {
  final BoxPainter _painter;
  CircleTabIndicator({@required Color color, @required double radius})
      : _painter = _CirclePainter(color, radius);
  @override
  BoxPainter createBoxPainter([onChanged]) => _painter;
}

class _CirclePainter extends BoxPainter {
  final Paint _paint;
  final double radius;

  _CirclePainter(Color color, this.radius)
      : _paint = Paint()
          ..color = color
          ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final Offset circleOffset =
        offset + Offset(cfg.size.width / 2, cfg.size.height - radius);
    canvas.drawCircle(circleOffset, radius, _paint);
  }
}
