import 'dart:io';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tsacdop/class/audiostate.dart';
import 'package:tuple/tuple.dart';
import 'package:line_icons/line_icons.dart';
import 'package:tsacdop/class/episodebrief.dart';
import 'package:tsacdop/class/importompl.dart';
import 'package:tsacdop/class/podcast_group.dart';
import 'package:tsacdop/class/podcastlocal.dart';
import 'package:tsacdop/local_storage/sqflite_localpodcast.dart';
import 'package:tsacdop/episodes/episodedetail.dart';
import 'package:tsacdop/podcasts/podcastdetail.dart';
import 'package:tsacdop/podcasts/podcastmanage.dart';
import 'package:tsacdop/util/pageroute.dart';
import 'package:tsacdop/util/colorize.dart';

class ScrollPodcasts extends StatefulWidget {
  @override
  _ScrollPodcastsState createState() => _ScrollPodcastsState();
}

class _ScrollPodcastsState extends State<ScrollPodcasts> {
  int _groupIndex;
  @override
  void initState() {
    super.initState();
    _groupIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    return Consumer<GroupList>(builder: (_, groupList, __) {
      var groups = groupList.groups;
      bool isLoading = groupList.isLoading;
      return isLoading
          ? Container(
              height: (_width - 20) / 3 + 110,
            )
          : groups[_groupIndex].podcastList.length == 0
              ? Column(
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
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                          ],
                        )),
                    Container(
                      height: (_width - 20) / 3 + 40,
                      color: Theme.of(context).primaryColor,
                      margin: EdgeInsets.symmetric(horizontal: 15),
                    ),
                  ],
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
                                    height: 30,
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
                              // color: Colors.white10,
                              height: 70,
                              width: _width,
                              alignment: Alignment.centerLeft,
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
                                    .map<Tab>((PodcastLocal podcastLocal) {
                                  return Tab(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(25.0)),
                                      child: LimitedBox(
                                        maxHeight: 50,
                                        maxWidth: 50,
                                        child: Image.file(
                                            File("${podcastLocal.imagePath}")),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Consumer<ImportOmpl>(
                        builder: (_, ompl, __) => Container(
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
          child: Container(
            child: FutureBuilder<List<EpisodeBrief>>(
              future: _getRssItemTop(widget.podcastLocal),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print(snapshot.error);
                  Center(child: CircularProgressIndicator());
                }
                return (snapshot.hasData)
                    ? ShowEpisode(
                        podcast: snapshot.data,
                        podcastLocal: widget.podcastLocal,
                      )
                    : Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ),
        Container(
          height: 40,
          padding: EdgeInsets.symmetric(horizontal: 10.0),
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
                    child: IconButton(
                      icon: Icon(Icons.arrow_forward),
                      tooltip: 'See All',
                      onPressed: () {
                        Navigator.push(
                          context,
                          SlideLeftRoute(
                              page: PodcastDetail(
                            podcastLocal: widget.podcastLocal,
                          )),
                        );
                      },
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
  final List<EpisodeBrief> podcast;
  final PodcastLocal podcastLocal;
  ShowEpisode({Key key, this.podcast, this.podcastLocal}) : super(key: key);
  Offset offset;
  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    _showPopupMenu(Offset offset, EpisodeBrief episode, BuildContext context,
        bool isPlaying, bool isInPlaylist) async {
      var audio = Provider.of<AudioPlayerNotifier>(context, listen: false);
      double left = offset.dx;
      double top = offset.dy;
      await showMenu<int>(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        context: context,
        position: RelativeRect.fromLTRB(left, top, _width - left, 0),
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
          if (isInPlaylist) {
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

    return CustomScrollView(
      // physics: const AlwaysScrollableScrollPhysics(),
      physics: ClampingScrollPhysics(),
      primary: false,
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.all(5.0),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 1.0,
              crossAxisCount: 3,
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
                            podcast[index],
                            context,
                            data.item1 == podcast[index],
                            data.item2.contains(podcast[index].enclosureUrl)),
                        onTap: () {
                          Navigator.push(
                            context,
                            ScaleRoute(
                                page: EpisodeDetail(
                              episodeItem: podcast[index],
                              heroTag: 'scroll',
                              //unique hero tag
                            )),
                          );
                        },
                        child: Container(
                          // decoration: BoxDecoration(
                          //   border: Border.all(
                          //     color: Theme.of(context).brightness ==
                          //             Brightness.light
                          //         ? Theme.of(context).primaryColor
                          //         : Theme.of(context).scaffoldBackgroundColor,
                          //     width: 0.0,
                          //   ),
                          // ),
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
                                      tag: podcast[index].enclosureUrl +
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
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Container(
                                  padding: EdgeInsets.only(top: 2.0),
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    podcast[index].title,
                                    style: TextStyle(
                                      fontSize: _width / 32,
                                    ),
                                    maxLines: 4,
                                    overflow: TextOverflow.fade,
                                  ),
                                ),
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Container(
                                    alignment: Alignment.bottomLeft,
                                    child: Text(
                                      podcast[index].dateToString(),
                                      //podcast[index].pubDate.substring(4, 16),
                                      style: TextStyle(
                                        fontSize: _width / 35,
                                        color: _c,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
              childCount: (podcast.length > 3) ? 3 : podcast.length,
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
