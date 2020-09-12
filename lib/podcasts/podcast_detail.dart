import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:html/parser.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../home/audioplayer.dart';
import '../local_storage/key_value_storage.dart';
import '../local_storage/sqflite_localpodcast.dart';
import '../state/audio_state.dart';
import '../state/download_state.dart';
import '../type/episodebrief.dart';
import '../type/fireside_data.dart';
import '../type/podcastlocal.dart';
import '../util/audiopanel.dart';
import '../util/custom_widget.dart';
import '../util/episodegrid.dart';
import '../util/extension_helper.dart';
import '../util/general_dialog.dart';
import 'podcast_settings.dart';

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

  final GlobalKey<AudioPanelState> _playerKey = GlobalKey<AudioPanelState>();

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
  int _dataCount = 0;

  /// Load more episodes when scroll to bottom.
  bool _loadMore = false;

  /// Change sort by.
  bool _reverse = false;

  /// Filter type.
  Filter _filter = Filter.all;

  /// Query string
  String _query = '';

  ///Hide listened.
  bool _hideListened;

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
    if (result >= 0) {
      Fluttertoast.showToast(
        msg: context.s.updateEpisodesCount(result),
        gravity: ToastGravity.TOP,
      );
    }
    if (result > 0) {
      var autoDownload = await dbHelper.getAutoDownload(podcastLocal.id);
      if (autoDownload) {
        var downloader = Provider.of<DownloadState>(context, listen: false);
        var result = await Connectivity().checkConnectivity();
        var autoDownloadStorage = KeyValueStorage(autoDownloadNetworkKey);
        var autoDownloadNetwork = await autoDownloadStorage.getInt();
        if (autoDownloadNetwork == 1) {
          var episodes = await dbHelper.getNewEpisodes(podcastLocal.id);
          // For safety
          if (episodes.length < 100) {
            for (var episode in episodes) {
              downloader.startTask(episode, showNotification: false);
            }
          }
        } else if (result == ConnectivityResult.wifi) {
          var episodes = await dbHelper.getNewEpisodes(podcastLocal.id);
          //For safety
          if (episodes.length < 100) {
            for (var episode in episodes) {
              downloader.startTask(episode, showNotification: false);
            }
          }
        }
      }
    } else if (result != 0) {
      Fluttertoast.showToast(
        msg: context.s.updateFailed,
        gravity: ToastGravity.TOP,
      );
    }
    if (mounted && result > 0) setState(() {});
  }

  Future<List<EpisodeBrief>> _getRssItem(PodcastLocal podcastLocal,
      {int count, bool reverse, Filter filter, String query}) async {
    var dbHelper = DBHelper();
    var episodes = <EpisodeBrief>[];
    _episodeCount = await dbHelper.getPodcastCounts(podcastLocal.id);
    var storage = KeyValueStorage(podcastLayoutKey);
    var hideListenedStorage = KeyValueStorage(hideListenedKey);
    var index = await storage.getInt(defaultValue: 1);
    if (_layout == null) _layout = Layout.values[index];
    if (_hideListened == null) {
      _hideListened = await hideListenedStorage.getBool(defaultValue: false);
    }
    episodes = await dbHelper.getRssItem(podcastLocal.id, count,
        reverse: reverse,
        filter: filter,
        query: query,
        hideListened: _hideListened);
    _dataCount = episodes.length;
    return episodes;
  }

  Future<Tuple2<String, List<PodcastHost>>> _getHosts(
      PodcastLocal podcastLocal) async {
    var data = FiresideData(podcastLocal.id, podcastLocal.link);
    await data.getData();
    var backgroundImage = data.background;
    var hosts = data.hosts;
    return Tuple2(backgroundImage, hosts);
  }

  Future<int> _getLayout() async {
    var storage = KeyValueStorage(podcastLayoutKey);
    var index = await storage.getInt(defaultValue: 1);
    return index;
  }

  Future<bool> _getHideListened() async {
    var hideListenedStorage = KeyValueStorage(hideListenedKey);
    var hideListened = await hideListenedStorage.getBool(defaultValue: false);
    return hideListened;
  }

  Widget _podcastInfo(BuildContext context) {
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
          style: context.textTheme.headline5.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _hostsList(BuildContext context, PodcastLocal podcastLocal) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (podcastLocal.provider.contains('fireside'))
          FutureBuilder(
              future: _getHosts(podcastLocal),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var hosts = snapshot.data.item2;
                  var backgroundImage = snapshot.data.item1;
                  return CachedNetworkImage(
                    imageUrl: backgroundImage,
                    errorWidget: (context, url, error) => Center(),
                    imageBuilder: (context, backgroundImageProvider) =>
                        Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: backgroundImageProvider,
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
                                        .map<Widget>((host) {
                                          final image = host.image ==
                                                  "http://xuanmei.us/assets/default/avatar_small-"
                                                      "170afdc2be97fc6148b283083942d82c101d4c1061f6b28f87c8958b52664af9.jpg"
                                              ? "https://fireside.fm/assets/default/avatar_small"
                                                  "-170afdc2be97fc6148b283083942d82c101d4c1061f6b28f87c8958b52664af9.jpg"
                                              : host.image;
                                          return Container(
                                              padding: EdgeInsets.all(5.0),
                                              width: 80.0,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  CachedNetworkImage(
                                                    imageUrl: image,
                                                    progressIndicatorBuilder:
                                                        (context, url,
                                                                downloadProgress) =>
                                                            SizedBox(
                                                      width: 40,
                                                      height: 2,
                                                      child: LinearProgressIndicator(
                                                          value:
                                                              downloadProgress
                                                                  .progress),
                                                    ),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            CircleAvatar(
                                                      backgroundColor:
                                                          Colors.grey[400],
                                                      backgroundImage: AssetImage(
                                                          'assets/fireside.jpg'),
                                                    ),
                                                    imageBuilder: (context,
                                                            hostImage) =>
                                                        CircleAvatar(
                                                            backgroundColor:
                                                                Colors
                                                                    .grey[400],
                                                            backgroundImage:
                                                                hostImage),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.all(2),
                                                  ),
                                                  Text(
                                                    host.name,
                                                    style: TextStyle(
                                                      backgroundColor: Colors
                                                          .black
                                                          .withOpacity(0.5),
                                                      color: Colors.white,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    maxLines: 2,
                                                    overflow: TextOverflow.fade,
                                                  ),
                                                ],
                                              ));
                                        })
                                        .toList()
                                        .cast<Widget>()),
                              ),
                            )),
                  );
                } else {
                  return Center();
                }
              }),
        Padding(padding: EdgeInsets.all(10.0)),
        Container(
          padding: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 10.0),
          alignment: Alignment.topLeft,
          color: context.scaffoldBackgroundColor,
          child: AboutPodcast(podcastLocal: widget.podcastLocal),
        ),
      ],
    );
  }

  Widget _customPopupMenu(
          {Widget child,
          String tooltip,
          List<PopupMenuEntry<int>> itemBuilder,
          Function(int) onSelected,
          bool clip = true}) =>
      Material(
        key: UniqueKey(),
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(100),
        clipBehavior: clip ? Clip.hardEdge : Clip.none,
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

  Widget _rightTopMenu(BuildContext context) {
    final s = context.s;
    return _customPopupMenu(
        tooltip: s.menu,
        clip: false,
        onSelected: (value) {
          switch (value) {
            case 0:
              widget.podcastLocal.link.launchUrl;
              break;
            case 1:
              widget.podcastLocal.rssUrl.launchUrl;
              break;
            case 2:
              generalSheet(
                context,
                title: s.settings,
                child: PodcastSetting(podcastLocal: widget.podcastLocal),
              ).then((value) => setState(() {}));
              break;
          }
        },
        itemBuilder: [
          if (widget.podcastLocal.link != null)
            PopupMenuItem(
              value: 0,
              child: Container(
                padding: EdgeInsets.only(left: 10),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.link, color: context.textColor),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.0),
                    ),
                    Text(s.menuVisitSite),
                  ],
                ),
              ),
            ),
          PopupMenuItem(
            value: 1,
            child: Container(
              padding: EdgeInsets.only(left: 10),
              child: Row(
                children: <Widget>[
                  Icon(
                    LineIcons.rss_square_solid,
                    color: context.textColor,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.0),
                  ),
                  Text(s.menuViewRSS),
                ],
              ),
            ),
          ),
          PopupMenuItem(
            value: 2,
            child: Container(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(LineIcons.cog_solid, color: context.textColor),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.0),
                  ),
                  Text(s.settings),
                ],
              ),
            ),
          )
        ]);
  }

  Widget _actionBar(BuildContext context) {
    final s = context.s;
    return Container(
        height: 30,
        child: Row(
          children: <Widget>[
            SizedBox(width: 10),
            _customPopupMenu(
              tooltip: s.homeSubMenuSortBy,
              child: Container(
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100.0),
                    border: Border.all(color: context.primaryColorDark),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(s.homeSubMenuSortBy),
                      SizedBox(width: 5),
                      Icon(
                        _reverse
                            ? LineIcons.hourglass_start_solid
                            : LineIcons.hourglass_end_solid,
                        size: 18,
                      )
                    ],
                  )),
              itemBuilder: [
                PopupMenuItem(
                  value: 0,
                  child: Row(
                    children: [
                      Text(s.newestFirst),
                      Spacer(),
                      if (!_reverse) DotIndicator()
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 1,
                  child: Row(
                    children: [
                      Text(s.oldestFirst),
                      Spacer(),
                      if (_reverse) DotIndicator()
                    ],
                  ),
                )
              ],
              onSelected: (value) {
                if (value == 0) {
                  setState(() => _reverse = false);
                } else if (value == 1) setState(() => _reverse = true);
              },
            ),
            SizedBox(width: 10),
            _customPopupMenu(
                tooltip: s.filter,
                child: Container(
                  height: 30,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: context.primaryColorDark)),
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(s.filter),
                      SizedBox(width: 5),
                      Icon(
                        LineIcons.filter_solid,
                        color:
                            _filter != Filter.all ? context.accentColor : null,
                        size: 18,
                      )
                    ],
                  ),
                ),
                itemBuilder: [
                  PopupMenuItem(
                    value: 0,
                    child: Row(
                      children: [
                        Text(s.all),
                        Spacer(),
                        if (_filter == Filter.all) DotIndicator(),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 1,
                    child: Row(
                      children: [
                        Text(s.homeTabMenuFavotite),
                        Spacer(),
                        if (_filter == Filter.liked) DotIndicator()
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 2,
                    child: Row(
                      children: [
                        Text(s.downloaded),
                        Spacer(),
                        if (_filter == Filter.downloaded) DotIndicator()
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 3,
                    child: Container(
                        padding: EdgeInsets.only(
                            top: 5, bottom: 5, left: 2, right: 2),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                                width: 2,
                                color: context.textColor.withOpacity(0.2))),
                        child: _query == ''
                            ? Row(
                                children: [
                                  Text(s.search,
                                      style: TextStyle(
                                          color: context.textColor
                                              .withOpacity(0.4))),
                                  Spacer()
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    child: Text(_query,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: context.accentColor)),
                                  ),
                                ],
                              )),
                  ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 0:
                      if (_filter != Filter.all) {
                        setState(() {
                          _filter = Filter.all;
                          _query = '';
                        });
                      }
                      break;
                    case 1:
                      if (_filter != Filter.liked) {
                        setState(() {
                          _query = '';
                          _filter = Filter.liked;
                        });
                      }
                      break;
                    case 2:
                      if (_filter != Filter.downloaded) {
                        setState(() {
                          _query = '';
                          _filter = Filter.downloaded;
                        });
                      }
                      break;
                    case 3:
                      showGeneralDialog(
                          context: context,
                          barrierDismissible: true,
                          barrierLabel: MaterialLocalizations.of(context)
                              .modalBarrierDismissLabel,
                          barrierColor: Colors.black54,
                          transitionDuration: const Duration(milliseconds: 200),
                          pageBuilder:
                              (context, animaiton, secondaryAnimation) =>
                                  SearchEpisode(
                                    onSearch: (query) {
                                      setState(() {
                                        _query = query;
                                        _filter = Filter.search;
                                      });
                                    },
                                  ));
                      break;
                    default:
                  }
                }),
            Spacer(),
            FutureBuilder<bool>(
                future: _getHideListened(),
                builder: (context, snapshot) {
                  if (_hideListened == null) {
                    _hideListened = snapshot.data;
                  }
                  return Material(
                      color: Colors.transparent,
                      clipBehavior: Clip.hardEdge,
                      borderRadius: BorderRadius.circular(100),
                      child: IconButton(
                        icon: SizedBox(
                          width: 30,
                          height: 30,
                          child: HideListened(
                            hideListened: _hideListened ?? false,
                          ),
                        ),
                        onPressed: () {
                          setState(() => _hideListened = !_hideListened);
                        },
                      ));
                }),
            FutureBuilder<int>(
                future: _getLayout(),
                initialData: 1,
                builder: (context, snapshot) {
                  if (_layout == null) _layout = Layout.values[snapshot.data];
                  return Material(
                    color: Colors.transparent,
                    clipBehavior: Clip.hardEdge,
                    borderRadius: BorderRadius.circular(100),
                    child: LayoutButton(
                      layout: _layout,
                      onPressed: (layout) => setState(() {
                        _layout = layout;
                      }),
                    ),
                  );
                }),
            SizedBox(width: 10)
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    var _color = widget.podcastLocal.primaryColor.colorizedark();
    final s = context.s;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Theme.of(context).primaryColor,
        systemNavigationBarIconBrightness:
            Theme.of(context).accentColorBrightness,
      ),
      child: WillPopScope(
        onWillPop: () {
          if (_playerKey.currentState != null &&
              _playerKey.currentState.initSize > 100) {
            _playerKey.currentState.backToMini();
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          body: SafeArea(
            top: false,
            //minimum:
            //    widget.hide ? EdgeInsets.only(bottom: 50) : EdgeInsets.zero,
            child: RefreshIndicator(
              key: _refreshIndicatorKey,
              color: context.accentColor,
              onRefresh: () async {
                await _updateRssItem(context, widget.podcastLocal);
              },
              child: Stack(
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: ScrollConfiguration(
                          behavior: NoGrowBehavior(),
                          child: CustomScrollView(
                            controller: _controller
                              ..addListener(() async {
                                if (_controller.offset ==
                                        _controller.position.maxScrollExtent &&
                                    _dataCount == _top) {
                                  if (mounted) {
                                    setState(() => _loadMore = true);
                                  }
                                  await Future.delayed(Duration(seconds: 3));
                                  if (mounted && _loadMore) {
                                    setState(() {
                                      _top = _top + 36;
                                      _loadMore = false;
                                    });
                                  }
                                }
                                if (_controller.offset > 0 &&
                                    mounted &&
                                    !_scroll) {
                                  setState(() => _scroll = true);
                                }
                              }),
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: <Widget>[
                              SliverAppBar(
                                brightness: Brightness.dark,
                                actions: <Widget>[_rightTopMenu(context)],
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
                                              top: 120 + context.paddingTop),
                                          padding: EdgeInsets.only(
                                              left: 80, right: 120),
                                          color: Colors.white10,
                                          alignment: Alignment.centerLeft,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                  widget.podcastLocal.author ??
                                                      '',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                              if (widget.podcastLocal.provider
                                                  .isNotEmpty)
                                                Text(
                                                  s.hostedOn(widget
                                                      .podcastLocal.provider),
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          alignment: Alignment.centerRight,
                                          padding: EdgeInsets.only(right: 10),
                                          child: SizedBox(
                                            height: 120,
                                            child: Image.file(File(
                                                "${widget.podcastLocal.imagePath}")),
                                          ),
                                        ),
                                        Container(
                                          alignment: Alignment.center,
                                          child: _podcastInfo(context),
                                        ),
                                      ],
                                    ),
                                    title: _topHeight < 70 + context.paddingTop
                                        ? Text(widget.podcastLocal.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.clip,
                                            style:
                                                TextStyle(color: Colors.white))
                                        : Center(),
                                  );
                                }),
                              ),
                              SliverToBoxAdapter(
                                child: _hostsList(context, widget.podcastLocal),
                              ),
                              SliverToBoxAdapter(child: _actionBar(context)),
                              FutureBuilder<List<EpisodeBrief>>(
                                  future: _getRssItem(widget.podcastLocal,
                                      count: _top,
                                      reverse: _reverse,
                                      filter: _filter,
                                      query: _query),
                                  builder: (context, snapshot) {
                                    return (snapshot.hasData)
                                        ? EpisodeGrid(
                                            episodes: snapshot.data,
                                            showFavorite: true,
                                            showNumber: _filter == Filter.all &&
                                                    !_hideListened
                                                ? true
                                                : false,
                                            layout: _layout,
                                            reverse: _reverse,
                                            episodeCount: _episodeCount,
                                            initNum: _scroll ? 0 : 12,
                                          )
                                        : SliverToBoxAdapter(
                                            child: Center(),
                                          );
                                  }),
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    return _loadMore
                                        ? Container(
                                            height: 2,
                                            child: LinearProgressIndicator())
                                        : Center();
                                  },
                                  childCount: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Selector<AudioPlayerNotifier, Tuple2<bool, PlayerHeight>>(
                          selector: (_, audio) =>
                              Tuple2(audio.playerRunning, audio.playerHeight),
                          builder: (_, data, __) {
                            var height = kMinPlayerHeight[data.item2.index];
                            return SizedBox(
                              height: data.item1 ? height : 0,
                            );
                          }),
                    ],
                  ),
                  Container(
                      child: PlayerWidget(
                    playerKey: _playerKey,
                  )),
                ],
              ),
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
    var description = await dbHelper.getFeedDescription(id);
    if (description == null || description.isEmpty) {
      _description = '';
    } else {
      var doc = parse(description);
      _description = parse(doc.body.text).documentElement.text;
    }
    if (mounted) setState(() => _load = true);
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
                                link.url.launchUrl;
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
                            link.url.launchUrl;
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
                    link.url.launchUrl;
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

class SearchEpisode extends StatefulWidget {
  SearchEpisode({this.onSearch, Key key}) : super(key: key);
  final ValueChanged<String> onSearch;
  @override
  _SearchEpisodeState createState() => _SearchEpisodeState();
}

class _SearchEpisodeState extends State<SearchEpisode> {
  TextEditingController _controller;
  String _query;

  @override
  void initState() {
    super.initState();
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
        titlePadding: const EdgeInsets.all(20),
        actionsPadding: EdgeInsets.zero,
        actions: <Widget>[
          FlatButton(
            splashColor: context.accentColor.withAlpha(70),
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              s.cancel,
              textAlign: TextAlign.end,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          FlatButton(
            splashColor: context.accentColor.withAlpha(70),
            onPressed: () {
              if ((_query ?? '').isNotEmpty) {
                widget.onSearch(_query);
                Navigator.of(context).pop();
              }
            },
            child:
                Text(s.confirm, style: TextStyle(color: context.accentColor)),
          )
        ],
        title: SizedBox(width: context.width - 160, child: Text(s.search)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                hintText: s.searchEpisode,
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
                setState(() => _query = value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
