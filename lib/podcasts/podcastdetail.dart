import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:html/parser.dart';
import 'package:tsacdop/class/audiostate.dart';
import 'package:tsacdop/class/podcast_group.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:provider/provider.dart';
import 'package:line_icons/line_icons.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:tsacdop/class/podcastlocal.dart';
import 'package:tsacdop/class/episodebrief.dart';
import 'package:tsacdop/local_storage/sqflite_localpodcast.dart';
import 'package:tsacdop/util/episodegrid.dart';
import 'package:tsacdop/home/audioplayer.dart';
import 'package:tsacdop/class/fireside_data.dart';
import 'package:tsacdop/util/colorize.dart';
import 'package:tsacdop/util/context_extension.dart';
import 'package:tsacdop/util/custompaint.dart';

class PodcastDetail extends StatefulWidget {
  PodcastDetail({Key key, this.podcastLocal}) : super(key: key);
  final PodcastLocal podcastLocal;
  @override
  _PodcastDetailState createState() => _PodcastDetailState();
}

class _PodcastDetailState extends State<PodcastDetail> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  String backgroundImage;
  List<PodcastHost> hosts;
  Future _updateRssItem(PodcastLocal podcastLocal) async {
    var dbHelper = DBHelper();
    try {
      final result = await dbHelper.updatePodcastRss(podcastLocal);
      if (result == 0) {
        Fluttertoast.showToast(
          msg: 'No Update',
          gravity: ToastGravity.TOP,
        );
      } else {
        Fluttertoast.showToast(
          msg: 'Updated $result Episodes',
          gravity: ToastGravity.TOP,
        );
        Provider.of<GroupList>(context, listen: false)
            .updatePodcast(podcastLocal.id);
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Update failed, network error',
        gravity: ToastGravity.TOP,
      );
    }
    if (mounted) setState(() {});
  }

  Future<List<EpisodeBrief>> _getRssItem(
      PodcastLocal podcastLocal, int i, bool reverse) async {
    var dbHelper = DBHelper();
    List<EpisodeBrief> episodes =
        await dbHelper.getRssItem(podcastLocal.id, i, reverse);
    if (podcastLocal.provider.contains('fireside')) {
      FiresideData data = FiresideData(podcastLocal.id, podcastLocal.link);
      await data.getData();
      backgroundImage = data.background;
      hosts = data.hosts;
    }
    return episodes;
  }

  _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Fluttertoast.showToast(
        msg: '$url Invalid Link',
        gravity: ToastGravity.TOP,
      );
    }
  }

  Widget podcastInfo(BuildContext context) {
    return Container(
      height: 170,
      padding: EdgeInsets.only(top: 40, left: 80, right: 120),
      alignment: Alignment.topLeft,
      child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Text(widget.podcastLocal.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .headline5
                  .copyWith(color: Colors.white))),
    );
  }

  Widget hostsList(BuildContext context, List<PodcastHost> hosts) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        hosts != null
            ? Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        //  colorFilter: ColorFilter.mode(_color, BlendMode.color),
                        image: CachedNetworkImageProvider(
                          backgroundImage,
                        ),
                        fit: BoxFit.cover)),
                alignment: Alignment.centerRight,
                child: Container(
                  color: Colors.black26,
                  padding: EdgeInsets.symmetric(vertical: 5.0),
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.centerRight,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: hosts
                          .map((host) => Container(
                              padding: EdgeInsets.all(5.0),
                              width: 80.0,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  CircleAvatar(
                                      backgroundColor: Colors.grey[400],
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                        host.image,
                                      )),
                                  Padding(
                                    padding: EdgeInsets.all(2),
                                  ),
                                  Text(
                                    host.name,
                                    style: TextStyle(
                                      backgroundColor:
                                          Colors.black.withOpacity(0.5),
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.fade,
                                  ),
                                ],
                              )))
                          .toList()
                          .cast<Widget>(),
                    ),
                  ),
                ))
            : Center(),
        Padding(padding: EdgeInsets.all(10.0)),
        Container(
          padding: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 10.0),
          alignment: Alignment.topLeft,
          color: Theme.of(context).scaffoldBackgroundColor,
          child: AboutPodcast(podcastLocal: widget.podcastLocal),
        ),
      ],
    );
  }

  double _topHeight = 0;

  ScrollController _controller;
  int _top;
  bool _loadMore;
  Layout _layout;
  bool _reverse;
  @override
  void initState() {
    super.initState();
    _loadMore = false;
    _top = 99;
    _layout = Layout.three;
    _reverse = false;
    _controller = ScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color _color = widget.podcastLocal.primaryColor.colorizedark();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Theme.of(context).primaryColor,
        systemNavigationBarIconBrightness:
            Theme.of(context).accentColorBrightness,
        //statusBarColor: _color,
      ),
      child: Scaffold(
        body: SafeArea(
          top: false,
          child: RefreshIndicator(
            key: _refreshIndicatorKey,
            color: Theme.of(context).accentColor,
            onRefresh: () => _updateRssItem(widget.podcastLocal),
            child: Stack(
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: FutureBuilder<List<EpisodeBrief>>(
                        future:
                            _getRssItem(widget.podcastLocal, _top, _reverse),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) print(snapshot.error);
                          return (snapshot.hasData)
                              ? CustomScrollView(
                                  controller: _controller
                                    ..addListener(() async {
                                      if (_controller.offset ==
                                              _controller
                                                  .position.maxScrollExtent &&
                                          snapshot.data.length == _top) {
                                        if (mounted)
                                          setState(() => _loadMore = true);
                                        await Future.delayed(
                                            Duration(seconds: 3));
                                        if (mounted)
                                          setState(() {
                                            _top = _top + 33;
                                            _loadMore = false;
                                          });
                                      }
                                    }),
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  //primary: true,
                                  slivers: <Widget>[
                                    SliverAppBar(
                                      brightness: Brightness.dark,
                                      actions: <Widget>[
                                        PopupMenuButton<String>(
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10))),
                                          elevation: 2,
                                          tooltip: 'Menu',
                                          itemBuilder: (context) => [
                                            widget.podcastLocal.link != null
                                                ? PopupMenuItem(
                                                    value: widget
                                                        .podcastLocal.link,
                                                    child: Container(
                                                      padding: EdgeInsets.only(
                                                          left: 10),
                                                      child: Row(
                                                        children: <Widget>[
                                                          Icon(Icons.link,
                                                              color: Theme.of(
                                                                      context)
                                                                  .tabBarTheme
                                                                  .labelColor),
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        5.0),
                                                          ),
                                                          Text('Visit Site'),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : Center(),
                                            PopupMenuItem(
                                              value: widget.podcastLocal.rssUrl,
                                              child: Container(
                                                padding:
                                                    EdgeInsets.only(left: 10),
                                                child: Row(
                                                  children: <Widget>[
                                                    Icon(
                                                      Icons.rss_feed,
                                                      color: Theme.of(context)
                                                          .tabBarTheme
                                                          .labelColor,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 5.0),
                                                    ),
                                                    Text('View Rss Feed'),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                          onSelected: (url) {
                                            _launchUrl(url);
                                          },
                                        )
                                      ],
                                      elevation: 0,
                                      iconTheme: IconThemeData(
                                        color: Colors.white,
                                      ),
                                      expandedHeight: 150 +
                                          MediaQuery.of(context).padding.top,
                                      backgroundColor: _color,
                                      floating: true,
                                      pinned: true,
                                      flexibleSpace: LayoutBuilder(builder:
                                          (BuildContext context,
                                              BoxConstraints constraints) {
                                        _topHeight = constraints.biggest.height;
                                        return FlexibleSpaceBar(
                                          background: Stack(
                                            children: <Widget>[
                                              Container(
                                                margin: EdgeInsets.only(
                                                    top: 120 +
                                                        MediaQuery.of(context)
                                                            .padding
                                                            .top),
                                                padding: EdgeInsets.only(
                                                    left: 80, right: 120),
                                                color: Colors.white10,
                                                alignment: Alignment.centerLeft,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                        widget.podcastLocal
                                                                .author ??
                                                            '',
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white)),
                                                    widget.podcastLocal.provider
                                                            .isNotEmpty
                                                        ? Text(
                                                            'Hosted on ' +
                                                                widget
                                                                    .podcastLocal
                                                                    .provider,
                                                            maxLines: 1,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          )
                                                        : Center(),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                padding:
                                                    EdgeInsets.only(right: 10),
                                                child: SizedBox(
                                                  height: 120,
                                                  child: Image.file(File(
                                                      "${widget.podcastLocal.imagePath}")),
                                                ),
                                              ),
                                              Container(
                                                alignment: Alignment.center,
                                                child: podcastInfo(context),
                                              ),
                                            ],
                                          ),
                                          title: _topHeight <
                                                  70 +
                                                      MediaQuery.of(context)
                                                          .padding
                                                          .top
                                              ? Text(widget.podcastLocal.title,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: Colors.white))
                                              : Center(),
                                        );
                                      }),
                                    ),
                                    SliverToBoxAdapter(
                                      child: hostsList(context, hosts),
                                    ),
                                    SliverToBoxAdapter(
                                      child: Container(
                                          height: 30,
                                          child: Row(
                                            children: <Widget>[
                                              Material(
                                                color: Colors.transparent,
                                                child: PopupMenuButton<int>(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10))),
                                                  elevation: 1,
                                                  tooltip: 'Sort By',
                                                  child: Container(
                                                      height: 30,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 15),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: <Widget>[
                                                          Text('Sort by'),
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        5),
                                                          ),
                                                          Icon(
                                                            _reverse
                                                                ? LineIcons
                                                                    .hourglass_start_solid
                                                                : LineIcons
                                                                    .hourglass_end_solid,
                                                            size: 18,
                                                          )
                                                        ],
                                                      )),
                                                  itemBuilder: (context) => [
                                                    PopupMenuItem(
                                                      value: 0,
                                                      child:
                                                          Text('Newest first'),
                                                    ),
                                                    PopupMenuItem(
                                                      value: 1,
                                                      child:
                                                          Text('Oldest first'),
                                                    )
                                                  ],
                                                  onSelected: (value) {
                                                    if (value == 0)
                                                      setState(() =>
                                                          _reverse = false);
                                                    else if (value == 1)
                                                      setState(() =>
                                                          _reverse = true);
                                                  },
                                                ),
                                              ),
                                              Spacer(),
                                              Material(
                                                color: Colors.transparent,
                                                child: IconButton(
                                                  padding: EdgeInsets.zero,
                                                  onPressed: () {
                                                    if (_layout == Layout.three)
                                                      setState(() {
                                                        _layout = Layout.two;
                                                      });
                                                    else
                                                      setState(() {
                                                        _layout = Layout.three;
                                                      });
                                                  },
                                                  icon: _layout == Layout.three
                                                      ? SizedBox(
                                                          height: 10,
                                                          width: 30,
                                                          child: CustomPaint(
                                                            painter: LayoutPainter(
                                                                0,
                                                                context
                                                                    .textTheme
                                                                    .bodyText1
                                                                    .color),
                                                          ),
                                                        )
                                                      : SizedBox(
                                                          height: 10,
                                                          width: 30,
                                                          child: CustomPaint(
                                                            painter: LayoutPainter(
                                                                1,
                                                                context
                                                                    .textTheme
                                                                    .bodyText1
                                                                    .color),
                                                          ),
                                                        ),
                                                ),
                                              ),
                                            ],
                                          )),
                                    ),
                                    EpisodeGrid(
                                      episodes: snapshot.data,
                                      showFavorite: true,
                                      showNumber: true,
                                      layout: _layout,
                                      reverse: _reverse,
                                      episodeCount:
                                          widget.podcastLocal.episodeCount,
                                    ),
                                    SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        (BuildContext context, int index) {
                                          return _loadMore
                                              ? Container(
                                                  height: 2,
                                                  child:
                                                      LinearProgressIndicator())
                                              : Center();
                                        },
                                        childCount: 1,
                                      ),
                                    ),
                                  ],
                                )
                              : Center(child: CircularProgressIndicator());
                        },
                      ),
                    ),
                    Selector<AudioPlayerNotifier, bool>(
                        selector: (_, audio) => audio.playerRunning,
                        builder: (_, data, __) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: data ? 60.0 : 0),
                          );
                        }),
                  ],
                ),
                Container(child: PlayerWidget()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AboutPodcast extends StatefulWidget {
  final PodcastLocal podcastLocal;
  AboutPodcast({this.podcastLocal, Key key}) : super(key: key);

  @override
  _AboutPodcastState createState() => _AboutPodcastState();
}

class _AboutPodcastState extends State<AboutPodcast> {
  String _description;
  bool _load;
  bool _expand;
  void getDescription(String id) async {
    var dbHelper = DBHelper();
    String description = await dbHelper.getFeedDescription(id);
    if (description == null || description.isEmpty) {
      _description = '';
    } else {
      var doc = parse(description);
      _description = parse(doc.body.text).documentElement.text;
    }
    setState(() => _load = true);
  }

  _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    super.initState();
    _load = false;
    _expand = false;
    getDescription(widget.podcastLocal.id);
  }

  @override
  Widget build(BuildContext context) {
    return !_load
        ? Center()
        : LayoutBuilder(
            builder: (context, size) {
              final span = TextSpan(text: _description);
              final tp = TextPainter(
                  text: span, maxLines: 3, textDirection: TextDirection.ltr);
              tp.layout(maxWidth: size.maxWidth);

              if (tp.didExceedMaxLines) {
                return GestureDetector(
                  onTap: () {
                    setState(() => _expand = !_expand);
                  },
                  child: !_expand
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Linkify(
                              onOpen: (link) {
                                _launchUrl(link.url);
                              },
                              text: _description,
                              linkStyle: TextStyle(
                                  color: Theme.of(context).accentColor,
                                  decoration: TextDecoration.underline,
                                  textBaseline: TextBaseline.ideographic),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        )
                      : Linkify(
                          onOpen: (link) {
                            _launchUrl(link.url);
                          },
                          text: _description,
                          linkStyle: TextStyle(
                              color: Theme.of(context).accentColor,
                              decoration: TextDecoration.underline,
                              textBaseline: TextBaseline.ideographic),
                        ),
                );
              } else {
                return Linkify(
                  text: _description,
                  onOpen: (link) {
                    _launchUrl(link.url);
                  },
                  linkStyle: TextStyle(
                      color: Theme.of(context).accentColor,
                      decoration: TextDecoration.underline,
                      textBaseline: TextBaseline.ideographic),
                );
              }
            },
          );
  }
}
