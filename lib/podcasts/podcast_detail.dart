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
import '../type/play_histroy.dart';
import '../local_storage/sqflite_localpodcast.dart';
import '../local_storage/key_value_storage.dart';
import '../util/episodegrid.dart';
import '../home/audioplayer.dart';
import '../type/fireside_data.dart';
import '../util/extension_helper.dart';
import '../util/custompaint.dart';
import '../util/general_dialog.dart';
import '../state/audio_state.dart';

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

  /// Fireside background if hosted on fireside.
  String _backgroundImage;

  /// Fireside hosts if hosted on fireside.
  List<PodcastHost> _hosts;

  /// Episodes total count.
  int _episodeCount;

  /// Default layout.
  Layout _layout;

  /// If true, stop grid load animation.
  bool _scroll = false;

  double _topHeight = 0;

  ScrollController _controller;

  /// Episodes num load first time.
  int _top = 96;

  /// Load more episodes when scroll to bottom.
  bool _loadMore = false;

  /// Change sort by.
  bool _reverse = false;

  /// Filter type.
  Filter _filter = Filter.all;

  /// Query string
  String _query = '';

  ///Hide listened.
  bool _hideListened = false;

  @override
  void initState() {
    super.initState();
    _loadMore = false;
    _reverse = false;
    _controller = ScrollController();
    _scroll = false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future _updateRssItem(BuildContext context, PodcastLocal podcastLocal) async {
    var dbHelper = DBHelper();
    final result = await dbHelper.updatePodcastRss(podcastLocal);
    if (result == 0) {
      Fluttertoast.showToast(
        msg: 'No Update',
        gravity: ToastGravity.TOP,
      );
    } else if (result > 0) {
      Fluttertoast.showToast(
        msg: context.s.updateEpisodesCount(result),
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
            for (var episode in episodes)
              downloader.startTask(episode, showNotification: false);
        } else if (result == ConnectivityResult.wifi) {
          List<EpisodeBrief> episodes =
              await dbHelper.getNewEpisodes(podcastLocal.id);
          //For safety
          if (episodes.length < 100)
            for (var episode in episodes)
              downloader.startTask(episode, showNotification: false);
        }
      }
    } else {
      Fluttertoast.showToast(
        msg: context.s.updateFailed,
        gravity: ToastGravity.TOP,
      );
    }
    if (mounted) setState(() {});
  }

  Future<List<EpisodeBrief>> _getRssItem(PodcastLocal podcastLocal,
      {int count, bool reverse, Filter filter, String query}) async {
    var dbHelper = DBHelper();
    List<EpisodeBrief> episodes = [];
    _episodeCount = await dbHelper.getPodcastCounts(podcastLocal.id);
    KeyValueStorage storage = KeyValueStorage(podcastLayoutKey);
    int index = await storage.getInt(defaultValue: 1);
    if (_layout == null) _layout = Layout.values[index];
    episodes = await dbHelper.getRssItem(podcastLocal.id, count, reverse,
        filter: filter, query: query);
    if (podcastLocal.provider.contains('fireside')) {
      FiresideData data = FiresideData(podcastLocal.id, podcastLocal.link);
      await data.getData();
      _backgroundImage = data.background;
      _hosts = data.hosts;
    }
    return episodes;
  }

  _markListened(String podcastId) async {
    DBHelper dbHelper = DBHelper();
    List<EpisodeBrief> episodes =
        await dbHelper.getRssItem(podcastId, -1, true);
    for (var episode in episodes) {
      bool marked = await dbHelper.checkMarked(episode);
      if (!marked) {
        final PlayHistory history =
            PlayHistory(episode.title, episode.enclosureUrl, 0, 1);
        await dbHelper.saveHistory(history);
        if (mounted) setState(() {});
      }
    }
  }

  Widget podcastInfo(BuildContext context) {
    return Container(
      height: 170,
      padding: EdgeInsets.only(top: 40, left: 80, right: 130),
      alignment: Alignment.topLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Text(
          widget.podcastLocal.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context)
              .textTheme
              .headline5
              .copyWith(color: Colors.white),
        ),
      ),
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

  _customPopupMenu(
          {Widget child,
          String tooltip,
          List<PopupMenuEntry<int>> itemBuilder,
          Function(int) onSelected}) =>
      Material(
        color: Colors.transparent,
        child: PopupMenuButton<int>(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 1,
          tooltip: tooltip,
          child: child,
          itemBuilder: (context) => itemBuilder,
          onSelected: (value) => onSelected(value),
        ),
      );

  _confirmMarkListened(BuildContext context) => generalDialog(
        context,
        title: Text(context.s.markConfirm),
        content: Text(context.s.markConfirmContent),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              context.s.cancel,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          FlatButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _markListened(widget.podcastLocal.id);
            },
            child: Text(
              context.s.confirm,
              style: TextStyle(color: context.accentColor),
            ),
          )
        ],
      );

  @override
  Widget build(BuildContext context) {
    Color _color = widget.podcastLocal.primaryColor.colorizedark();
    final s = context.s;
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
              await _updateRssItem(context, widget.podcastLocal);
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
                        future: _getRssItem(widget.podcastLocal,
                            count: _top,
                            reverse: _reverse,
                            filter: _filter,
                            query: _query),
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
                                            _top = _top + 36;
                                            _loadMore = false;
                                          });
                                      }
                                      if (_controller.offset > 0 &&
                                          mounted &&
                                          !_scroll)
                                        setState(() => _scroll = true);
                                    }),
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  slivers: <Widget>[
                                    SliverAppBar(
                                      brightness: Brightness.dark,
                                      actions: <Widget>[
                                        _customPopupMenu(
                                          tooltip: s.menu,
                                          onSelected: (int value) {
                                            switch (value) {
                                              case 0:
                                                widget.podcastLocal.link
                                                    .launchUrl;
                                                break;
                                              case 1:
                                                widget.podcastLocal.rssUrl
                                                    .launchUrl;
                                                break;
                                              case 2:
                                                _confirmMarkListened(context);
                                                break;
                                            }
                                          },
                                          itemBuilder: [
                                            if (widget.podcastLocal.link !=
                                                null)
                                              PopupMenuItem(
                                                value: 0,
                                                child: Container(
                                                  padding:
                                                      EdgeInsets.only(left: 10),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Icon(Icons.link,
                                                          color: context
                                                              .textColor),
                                                      Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    5.0),
                                                      ),
                                                      Text(s.menuVisitSite),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            PopupMenuItem(
                                              value: 1,
                                              child: Container(
                                                padding:
                                                    EdgeInsets.only(left: 10),
                                                child: Row(
                                                  children: <Widget>[
                                                    Icon(
                                                      Icons.rss_feed,
                                                      color: context.textColor,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 5.0),
                                                    ),
                                                    Text(s.menuViewRSS),
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
                                                                      .textColor,
                                                                  stroke: 2)),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 5.0),
                                                    ),
                                                    Text(
                                                      s.menuMarkAllListened,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      elevation: 0,
                                      iconTheme: IconThemeData(
                                        color: Colors.white,
                                      ),
                                      expandedHeight: 150 + context.paddingTop,
                                      backgroundColor: _color,
                                      floating: true,
                                      pinned: true,
                                      flexibleSpace: LayoutBuilder(
                                          builder: (context, constraints) {
                                        _topHeight = constraints.biggest.height;
                                        return FlexibleSpaceBar(
                                          background: Stack(
                                            children: <Widget>[
                                              Container(
                                                margin: EdgeInsets.only(
                                                    top: 120 +
                                                        context.paddingTop),
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
                                                    if (widget.podcastLocal
                                                        .provider.isNotEmpty)
                                                      Text(
                                                        s.hostedOn(widget
                                                            .podcastLocal
                                                            .provider),
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
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
                                                  70 + context.paddingTop
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
                                                child: _customPopupMenu(
                                                  tooltip: s.homeSubMenuSortBy,
                                                  child: Container(
                                                      height: 30,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 15),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: <Widget>[
                                                          Text(s
                                                              .homeSubMenuSortBy),
                                                          SizedBox(width: 10),
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
                                                  itemBuilder: [
                                                    PopupMenuItem(
                                                      value: 0,
                                                      child:
                                                          Text(s.newestFirst),
                                                    ),
                                                    PopupMenuItem(
                                                      value: 1,
                                                      child:
                                                          Text(s.oldestFirst),
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
                                              Material(
                                                color: Colors.transparent,
                                                child: _customPopupMenu(
                                                    tooltip: 'Filter',
                                                    child: Container(
                                                      height: 30,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 15),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: <Widget>[
                                                          Text('Filter'),
                                                          SizedBox(width: 10),
                                                          Icon(
                                                            LineIcons
                                                                .filter_solid,
                                                            size: 18,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    itemBuilder: [
                                                      PopupMenuItem(
                                                        value: 0,
                                                        child: Text('All'),
                                                      ),
                                                      PopupMenuItem(
                                                        value: 1,
                                                        child: Text(
                                                            'Not listened'),
                                                      ),
                                                      PopupMenuItem(
                                                        value: 2,
                                                        child: Text('Liked'),
                                                      ),
                                                      PopupMenuItem(
                                                        value: 3,
                                                        child:
                                                            Text('Downloaded'),
                                                      ),
                                                      PopupMenuItem(
                                                        value: 4,
                                                        child: Text('Search'),
                                                      ),
                                                    ],
                                                    onSelected: (value) {
                                                      switch (value) {
                                                        case 0:
                                                          if (_filter !=
                                                              Filter.all)
                                                            setState(() {
                                                              _hideListened =
                                                                  false;
                                                              _filter =
                                                                  Filter.all;
                                                            });
                                                          break;
                                                        case 1:
                                                          setState(() =>
                                                              _hideListened =
                                                                  true);
                                                          break;
                                                        case 2:
                                                          if (_filter !=
                                                              Filter.liked)
                                                            setState(() =>
                                                                _filter = Filter
                                                                    .liked);
                                                          break;
                                                        case 3:
                                                          if (_filter !=
                                                              Filter.downloaded)
                                                            setState(() =>
                                                                _filter = Filter
                                                                    .downloaded);
                                                          break;
                                                        case 4:
                                                          showGeneralDialog(
                                                              context: context,
                                                              barrierDismissible:
                                                                  true,
                                                              barrierLabel:
                                                                  MaterialLocalizations
                                                                          .of(
                                                                              context)
                                                                      .modalBarrierDismissLabel,
                                                              barrierColor:
                                                                  Colors
                                                                      .black54,
                                                              transitionDuration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          200),
                                                              pageBuilder: (BuildContext
                                                                          context,
                                                                      Animation
                                                                          animaiton,
                                                                      Animation
                                                                          secondaryAnimation) =>
                                                                  SearchEpisdoe(
                                                                    onSearch:
                                                                        (query) {
                                                                      setState(
                                                                          () {
                                                                        _query =
                                                                            query;
                                                                        _filter =
                                                                            Filter.search;
                                                                      });
                                                                    },
                                                                  ));
                                                          break;
                                                        default:
                                                      }
                                                    }),
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
                                      hideListened: _hideListened,
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

class SearchEpisdoe extends StatefulWidget {
  SearchEpisdoe({this.onSearch, Key key}) : super(key: key);
  final ValueChanged<String> onSearch;
  @override
  _SearchEpisodeState createState() => _SearchEpisodeState();
}

class _SearchEpisodeState extends State<SearchEpisdoe> {
  TextEditingController _controller;
  String _query;
  int _error;

  @override
  void initState() {
    super.initState();
    _error = 0;
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor:
            Theme.of(context).brightness == Brightness.light
                ? Color.fromRGBO(113, 113, 113, 1)
                : Color.fromRGBO(5, 5, 5, 1),
      ),
      child: AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        elevation: 1,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        titlePadding:
            const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
        actionsPadding: EdgeInsets.all(0),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              s.cancel,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          FlatButton(
            onPressed: (_query != null && _query != '')
                ? () {
                    {
                      widget.onSearch(_query);
                      Navigator.of(context).pop();
                    }
                  }
                : null,
            child: Text(s.confirm,
                style: TextStyle(color: Theme.of(context).accentColor)),
          )
        ],
        title: SizedBox(width: context.width - 160, child: Text(s.newGroup)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                hintText: s.newGroup,
                hintStyle: TextStyle(fontSize: 18),
                filled: true,
                focusedBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: context.accentColor, width: 2.0),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: context.accentColor, width: 2.0),
                ),
              ),
              cursorRadius: Radius.circular(2),
              autofocus: true,
              maxLines: 1,
              controller: _controller,
              onChanged: (value) {
                _query = value;
              },
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: (_error == 1)
                  ? Text(
                      s.groupExisted,
                      style: TextStyle(color: Colors.red[400]),
                    )
                  : Center(),
            ),
          ],
        ),
      ),
    );
  }
}
