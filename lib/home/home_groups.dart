import 'dart:io';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tuple/tuple.dart';
import 'package:line_icons/line_icons.dart';

import '../type/episodebrief.dart';
import '../state/podcast_group.dart';
import '../state/subscribe_podcast.dart';
import '../type/podcastlocal.dart';
import '../state/audiostate.dart';
import '../util/custompaint.dart';
import '../util/pageroute.dart';
import '../util/colorize.dart';
import '../util/context_extension.dart';
import '../local_storage/sqflite_localpodcast.dart';
import '../episodes/episodedetail.dart';
import '../podcasts/podcastdetail.dart';
import '../podcasts/podcastmanage.dart';

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
    return Consumer<GroupList>(builder: (_, groupList, __) {
      var groups = groupList.groups;
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
                                  msg: 'Add some groups',
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
                                  msg: 'Add some groups',
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
                                              'See All',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1
                                                  .copyWith(
                                                      color: Theme.of(context)
                                                          .accentColor),
                                            )),
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
                                : Text('No podcast in this group',
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
                                msg: 'Add some groups',
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
                                msg: 'Add some groups',
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
                                    height: 30.0,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 15),
                                    alignment: Alignment.bottomRight,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          SlideLeftRoute(page: PodcastManage()),
                                        );
                                      },
                                      child: Container(
                                          height: 30,
                                          padding: EdgeInsets.all(5.0),
                                          child: Text(
                                            'See All',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1
                                                .copyWith(
                                                    color: Theme.of(context)
                                                        .accentColor),
                                          )),
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
                                    color: Theme.of(context).accentColor,
                                    radius: 3),
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

class PodcastPreview extends StatefulWidget {
  final PodcastLocal podcastLocal;
  PodcastPreview({this.podcastLocal, Key key}) : super(key: key);
  @override
  _PodcastPreviewState createState() => _PodcastPreviewState();
}

class _PodcastPreviewState extends State<PodcastPreview> {
  Future<List<EpisodeBrief>> _getRssItemTop(PodcastLocal podcastLocal) async {
    var dbHelper = DBHelper();
    List<EpisodeBrief> episodes = await dbHelper.getRssItemTop(podcastLocal.id);
    return episodes;
  }

  @override
  Widget build(BuildContext context) {
    Color _c = (Theme.of(context).brightness == Brightness.light)
        ? widget.podcastLocal.primaryColor.colorizedark()
        : widget.podcastLocal.primaryColor.colorizeLight();
    return Column(
      children: <Widget>[
        Expanded(
          child: Selector<SubscribeWorker, bool>(
              selector: (_, worker) => worker.created,
              builder: (context, created, child) {
                return FutureBuilder<List<EpisodeBrief>>(
                  future: _getRssItemTop(widget.podcastLocal),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      print(snapshot.error);
                      Center();
                    }
                    return (snapshot.hasData)
                        ? ShowEpisode(
                            episodes: snapshot.data,
                            podcastLocal: widget.podcastLocal,
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
                child: Text(widget.podcastLocal.title,
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
                        tooltip: 'See All',
                        onPressed: () {
                          Navigator.push(
                            context,
                            SlideLeftHideRoute(
                                transitionPage: PodcastDetail(
                                  podcastLocal: widget.podcastLocal,
                                  hide: playerRunning,
                                ),
                                page: PodcastDetail(
                                  podcastLocal: widget.podcastLocal,
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

  _showPopupMenu(Offset offset, EpisodeBrief episode, BuildContext context,
      bool isPlaying, bool isInPlaylist) async {
    var audio = Provider.of<AudioPlayerNotifier>(context, listen: false);
    double left = offset.dx;
    double top = offset.dy;
    await showMenu<int>(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      context: context,
      position: RelativeRect.fromLTRB(left, top, context.width - left, 0),
      items: <PopupMenuEntry<int>>[
        PopupMenuItem(
          value: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Icon(
                LineIcons.play_circle_solid,
                color: Theme.of(context).accentColor,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 2),
              ),
              !isPlaying ? Text('Play') : Text('Playing'),
            ],
          ),
        ),
        PopupMenuItem(
            value: 1,
            child: Row(
              children: <Widget>[
                Icon(
                  LineIcons.clock_solid,
                  color: Colors.red,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2),
                ),
                !isInPlaylist ? Text('Later') : Text('Remove')
              ],
            )),
      ],
      elevation: 5.0,
    ).then((value) {
      if (value == 0) {
        if (!isPlaying) audio.episodeLoad(episode);
      } else if (value == 1) {
        if (!isInPlaylist) {
          audio.addToPlaylist(episode);
          Fluttertoast.showToast(
            msg: 'Added to playlist',
            gravity: ToastGravity.BOTTOM,
          );
        } else {
          audio.delFromPlaylist(episode);
          Fluttertoast.showToast(
            msg: 'Removed from playlist',
            gravity: ToastGravity.BOTTOM,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double _width = context.width;
    Offset offset;
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
                    audio.queue.playlist.map((e) => e.enclosureUrl).toList(),
                  ),
                  builder: (_, data, __) => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    alignment: Alignment.center,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        onTapDown: (details) => offset = Offset(
                            details.globalPosition.dx,
                            details.globalPosition.dy),
                        onLongPress: () => _showPopupMenu(
                            offset,
                            episodes[index],
                            context,
                            data.item1 == episodes[index],
                            data.item2.contains(episodes[index].enclosureUrl)),
                        onTap: () {
                          Navigator.push(
                            context,
                            ScaleRoute(
                                page: EpisodeDetail(
                              episodeItem: episodes[index],
                              heroTag: 'scroll',
                              //unique hero tag
                            )),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                flex: 2,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
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
                                            audio.episode, audio.playerRunning),
                                        builder: (_, data, __) {
                                          return (episodes[index]
                                                          .enclosureUrl ==
                                                      data.item1
                                                          ?.enclosureUrl &&
                                                  data.item2)
                                              ? Container(
                                                  height: 20,
                                                  width: 20,
                                                  margin: EdgeInsets.symmetric(
                                                      horizontal: 2),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: WaveLoader(
                                                      color:
                                                          context.accentColor))
                                              : Center();
                                        }),
                                    episodes[index].isNew == 1
                                        ? Text(
                                            'New',
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontStyle: FontStyle.italic),
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
                                          episodes[index].dateToString(),
                                          //podcast[index].pubDate.substring(4, 16),
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
                                              episodes[index].enclosureLength ==
                                                  null ||
                                              episodes[index].enclosureLength ==
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
                                      episodes[index].enclosureLength != null &&
                                              episodes[index].enclosureLength !=
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
                                    ],
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
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
