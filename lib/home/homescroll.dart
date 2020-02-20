import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:tsacdop/class/episodebrief.dart';
import 'package:tsacdop/class/podcast_group.dart';
import 'package:tsacdop/class/podcastlocal.dart';
import 'package:tsacdop/class/importompl.dart';
import 'package:tsacdop/local_storage/sqflite_localpodcast.dart';

import 'package:tsacdop/episodes/episodedetail.dart';
import 'package:tsacdop/podcasts/podcastdetail.dart';
import 'package:tsacdop/podcasts/podcastmanage.dart';
import 'package:tsacdop/util/pageroute.dart';
import 'package:tsacdop/class/settingstate.dart';

class ScrollPodcasts extends StatefulWidget {
  @override
  _ScrollPodcastsState createState() => _ScrollPodcastsState();
}

class _ScrollPodcastsState extends State<ScrollPodcasts> {
  var dir;
  int _groupIndex;
  bool _loaded;

  ImportState importState;
  Update subscribeUpdate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    subscribeUpdate = Provider.of<SettingState>(context).subscribeupdate;
    if (subscribeUpdate == Update.backhome) {
      setState(() {
        _groupIndex = 0;
      });
    } else if (subscribeUpdate == Update.justupdate) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _loaded = false;
    _groupIndex = 0;
    getApplicationDocumentsDirectory().then((value) {
      dir = value.path;
      setState(() => _loaded = true);
    });
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
              child: SizedBox(
                height: 20.0,
                width: 20.0,
                child: CircularProgressIndicator()),
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
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 15.0),
                                  child: Text(
                                    groups[_groupIndex].name,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red[300]),
                                  )),
                              Spacer(),
                              Container(
                                height: 30,
                                padding: EdgeInsets.symmetric(horizontal: 15),
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
                                    child: Text('See All',
                                        style: TextStyle(
                                          color: Colors.red[300],
                                          fontWeight: FontWeight.bold,
                                        )),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          color: Colors.white10,
                          height: 70,
                          width: _width,
                          alignment: Alignment.centerLeft,
                          child: TabBar(
                            labelPadding: EdgeInsets.only(
                                top: 5.0, bottom: 10.0, left: 6.0, right: 6.0),
                            indicator: CircleTabIndicator(
                                color: Colors.blue, radius: 3),
                            isScrollable: true,
                            tabs: groups[_groupIndex].podcasts
                                .map<Tab>((PodcastLocal podcastLocal) {
                              return Tab(
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25.0)),
                                  child: LimitedBox(
                                    maxHeight: 50,
                                    maxWidth: 50,
                                    child: !_loaded
                                        ? CircularProgressIndicator()
                                        : Image.file(File(
                                            "$dir/${podcastLocal.title}.png")),
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
                      color: Colors.white,
                    ),
                    child: TabBarView(
                      children: groups[_groupIndex].podcasts
                          .map<Widget>((PodcastLocal podcastLocal) {
                        return Container(
                          decoration: BoxDecoration(color: Colors.grey[100]),
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
  String path;
  Future<List<EpisodeBrief>> _getRssItemTop(PodcastLocal podcastLocal) async {
    var dbHelper = DBHelper();
    var dir = await getApplicationDocumentsDirectory();
    path = dir.path;
    Future<List<EpisodeBrief>> episodes =
        dbHelper.getRssItemTop(podcastLocal.title);
    return episodes;
  }

  Color _c;
  @override
  void initState() {
    super.initState();
    var color = json.decode(widget.podcastLocal.primaryColor);
    (color[0] > 200 && color[1] > 200 && color[2] > 200)
        ? _c = Color.fromRGBO(
            (255 - color[0]), 255 - color[1], 255 - color[2], 1.0)
        : _c = Color.fromRGBO(color[0], color[1], color[2], 1.0);
  }

  @override
  Widget build(BuildContext context) {
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
                        path: path,
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
              Text(widget.podcastLocal.title,
                  style: TextStyle(fontWeight: FontWeight.bold, color: _c)),
              Spacer(),
              Material(
                color: Colors.transparent,
                child: IconButton(
                  icon: Icon(Icons.arrow_forward),
                  splashColor: Colors.transparent,
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
  final String path;
  ShowEpisode({Key key, this.podcast, this.podcastLocal, this.path})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
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
                Color _c;
                var color = json.decode(podcast[index].primaryColor);
                (color[0] > 200 && color[1] > 200 && color[2] > 200)
                    ? _c = Color.fromRGBO(
                        (255 - color[0]), 255 - color[1], 255 - color[2], 1.0)
                    : _c = Color.fromRGBO(color[0], color[1], color[2], 1.0);
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      ScaleRoute(
                          page: EpisodeDetail(
                        episodeItem: podcast[index],
                        heroTag: 'scroll',
                        //unique hero tag
                        path: path,
                      )),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        color: Theme.of(context).scaffoldBackgroundColor,
                        border: Border.all(
                          color: Colors.grey[100],
                          width: 3.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey[100],
                            blurRadius: 1.0,
                            spreadRadius: 0.5,
                          ),
                        ]),
                    alignment: Alignment.center,
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
                                tag: podcast[index].enclosureUrl + 'scroll',
                                child: Container(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(_width / 36)),
                                    child: Container(
                                      height: _width / 18,
                                      width: _width / 18,
                                      child: Image.file(File(
                                          "$path/${podcastLocal.title}.png")),
                                    ),
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
                              podcast[index].pubDate.substring(4, 16),
                              style: TextStyle(
                                fontSize: _width / 35,
                                color: _c,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                      ],
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
