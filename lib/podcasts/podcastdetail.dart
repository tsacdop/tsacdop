import 'dart:io';
import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:html/parser.dart';
import 'package:tsacdop/state/download_state.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:provider/provider.dart';
import 'package:line_icons/line_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../type/podcastlocal.dart';
import '../type/episodebrief.dart';
import '../local_storage/sqflite_localpodcast.dart';
import '../local_storage/key_value_storage.dart';
import '../util/episodegrid.dart';
import '../home/audioplayer.dart';
import '../type/fireside_data.dart';
import '../util/colorize.dart';
import '../util/context_extension.dart';
import '../util/custompaint.dart';
import '../util/general_dialog.dart';
import '../state/audiostate.dart';

class PodcastDetail extends StatefulWidget {
  PodcastDetail({Key key, @required this.podcastLocal, this.hide = false})
      : super(key: key);
  final PodcastLocal podcastLocal;
  final bool hide;
  @override
  _PodcastDetailState createState() => _PodcastDetailState();
}

class _PodcastDetailState extends State<PodcastDetail> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  String _backgroundImage;
  List<PodcastHost> _hosts;
  int _episodeCount;
  Layout _layout;
  bool _scroll;
  Future _updateRssItem(PodcastLocal podcastLocal) async {
    var dbHelper = DBHelper();
    final result = await dbHelper.updatePodcastRss(podcastLocal);
    if (result == 0) {
      Fluttertoast.showToast(
        msg: 'No Update',
        gravity: ToastGravity.TOP,
      );
    } else if (result > 0) {
      Fluttertoast.showToast(
        msg: 'Updated $result Episodes',
        gravity: ToastGravity.TOP,
      );

      bool autoDownload = await dbHelper.getAutoDownload(podcastLocal.id);
      if (autoDownload) {
        var downloader = Provider.of<DownloadState>(context, listen: false);
        var result = await Connectivity().checkConnectivity();
        KeyValueStorage autoDownloadStorage =
            KeyValueStorage(autoDownloadNetworkKey);
        int autoDownloadNetwork = await autoDownloadStorage.getInt();
        if (autoDownloadNetwork == 1) {
          List<EpisodeBrief> episodes =
              await dbHelper.getNewEpisodes(podcastLocal.id);
          // For safety
          if (episodes.length < 100)
            episodes.forEach((episode) {
              downloader.startTask(episode, showNotification: false);
            });
        } else if (result == ConnectivityResult.wifi) {
          List<EpisodeBrief> episodes =
              await dbHelper.getNewEpisodes(podcastLocal.id);
          //For safety
          if (episodes.length < 100)
            episodes.forEach((episode) {
              downloader.startTask(episode, showNotification: false);
            });
        }
      }
    } else {
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
    _episodeCount = await dbHelper.getPodcastCounts(podcastLocal.id);
    KeyValueStorage storage = KeyValueStorage(podcastLayoutKey);
    int index = await storage.getInt();
    if (_layout == null) _layout = Layout.values[index];
    List<EpisodeBrief> episodes =
        await dbHelper.getRssItem(podcastLocal.id, i, reverse);
    if (podcastLocal.provider.contains('fireside')) {
      FiresideData data = FiresideData(podcastLocal.id, podcastLocal.link);
      await data.getData();
      _backgroundImage = data.background;
      _hosts = data.hosts;
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

  _markListened(String podcastId) async {
    DBHelper dbHelper = DBHelper();
    List<EpisodeBrief> episodes =
        await dbHelper.getRssItem(podcastId, -1, true);
    await Future.forEach(episodes, (episode) async {
      bool marked = await dbHelper.checkMarked(episode);
      if (!marked) {
        final PlayHistory history =
            PlayHistory(episode.title, episode.enclosureUrl, 0, 1);
        await dbHelper.saveHistory(history);
        if (mounted) setState(() {});
      }
    });
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
                          _backgroundImage,
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

  _confirmMarkListened(BuildContext context) => generalDialog(
        context,
        title: Text('Mark confirm'),
        content: Text('Confirm mark all episodes listened?'),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'CANCEL',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          FlatButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _markListened(widget.podcastLocal.id);
            },
            child: Text(
              'CONFIRM',
              style: TextStyle(color: context.accentColor),
            ),
          )
        ],
      );

  double _topHeight = 0;

  ScrollController _controller;
  int _top;
  bool _loadMore;
  bool _reverse;
  @override
  void initState() {
    super.initState();
    _loadMore = false;
    _top = 99;
    _reverse = false;
    _controller = ScrollController();
    _scroll = false;
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
          minimum: widget.hide ? EdgeInsets.only(bottom: 50) : EdgeInsets.zero,
          child: RefreshIndicator(
            key: _refreshIndicatorKey,
            color: Theme.of(context).accentColor,
            onRefresh: () async {
              await _updateRssItem(widget.podcastLocal);
              //  audio.addNewEpisode(widget.podcastLocal.id);
            },
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
                                      if (_controller.offset > 0 &&
                                          mounted &&
                                          !_scroll)
                                        setState(() {
                                          _scroll = true;
                                        });
                                    }),
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  //primary: true,
                                  slivers: <Widget>[
                                    SliverAppBar(
                                      brightness: Brightness.dark,
                                      actions: <Widget>[
                                        PopupMenuButton<int>(
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10))),
                                          elevation: 2,
                                          tooltip: 'Menu',
                                          itemBuilder: (context) => [
                                            widget.podcastLocal.link != null
                                                ? PopupMenuItem(
                                                    value: 0,
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
                                              value: 1,
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
                                            PopupMenuItem(
                                              value: 2,
                                              child: Container(
                                                padding:
                                                    EdgeInsets.only(left: 10),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    SizedBox(
                                                      width: 25,
                                                      height: 25,
                                                      child: CustomPaint(
                                                          painter:
                                                              ListenedAllPainter(
                                                                  context
                                                                      .textTheme
                                                                      .bodyText1
                                                                      .color,
                                                                  stroke: 2)),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 5.0),
                                                    ),
                                                    Text(
                                                      'Mark All Listened',
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                          onSelected: (int value) {
                                            switch (value) {
                                              case 0:
                                                _launchUrl(
                                                    widget.podcastLocal.link);
                                                break;
                                              case 1:
                                                _launchUrl(
                                                    widget.podcastLocal.rssUrl);
                                                break;
                                              case 2:
                                                _confirmMarkListened(context);
                                                break;
                                            }
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
                                      child: hostsList(context, _hosts),
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
                                                        _layout = Layout.one;
                                                      });
                                                    else if (_layout ==
                                                        Layout.two)
                                                      setState(() {
                                                        _layout = Layout.three;
                                                      });
                                                    else
                                                      setState(() {
                                                        _layout = Layout.two;
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
                                                      : _layout == Layout.two
                                                          ? SizedBox(
                                                              height: 10,
                                                              width: 30,
                                                              child:
                                                                  CustomPaint(
                                                                painter: LayoutPainter(
                                                                    1,
                                                                    context
                                                                        .textTheme
                                                                        .bodyText1
                                                                        .color),
                                                              ),
                                                            )
                                                          : SizedBox(
                                                              height: 10,
                                                              width: 30,
                                                              child:
                                                                  CustomPaint(
                                                                painter: LayoutPainter(
                                                                    4,
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
                                      episodeCount: _episodeCount,
                                      initNum: _scroll ? 0 : 12,
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
    if (mounted) setState(() => _load = true);
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
