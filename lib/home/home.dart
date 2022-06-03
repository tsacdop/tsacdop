import 'dart:async';
import 'dart:io';

import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart' hide NestedScrollView, showSearch;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../local_storage/key_value_storage.dart';
import '../local_storage/sqflite_localpodcast.dart';
import '../playlists/playlist_home.dart';
import '../state/audio_state.dart';
import '../state/download_state.dart';
import '../state/podcast_group.dart';
import '../state/refresh_podcast.dart';
import '../state/setting_state.dart';
import '../type/episodebrief.dart';
import '../util/extension_helper.dart';
import '../widgets/audiopanel.dart';
import '../widgets/custom_popupmenu.dart';
import '../widgets/custom_search_delegate.dart';
import '../widgets/custom_widget.dart';
import '../widgets/episodegrid.dart';
import '../widgets/feature_discovery.dart';
import '../widgets/muiliselect_bar.dart';
import 'audioplayer.dart';
import 'download_list.dart';
import 'home_groups.dart';
import 'home_menu.dart';
import 'import_opml.dart';
import 'search_podcast.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<AudioPanelState> _playerKey = GlobalKey<AudioPanelState>();
  TabController? _controller;
  Decoration _getIndicator(BuildContext context) {
    return UnderlineTabIndicator(
        borderSide: BorderSide(color: context.accentColor, width: 3),
        insets: EdgeInsets.only(
          left: 10.0,
          right: 10.0,
          top: 10.0,
        ));
  }

  final _androidAppRetain = MethodChannel("android_app_retain");
  var feature1OverflowMode = OverflowMode.clipContent;
  var feature1EnablePulsingAnimation = false;

  @override
  void initState() {
    _controller = TabController(length: 3, vsync: this);
    //  FeatureDiscovery.hasPreviouslyCompleted(context, addFeature).then((value) {
    //   if (!value) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      FeatureDiscovery.discoverFeatures(
        context,
        const <String>{
          addFeature,
          menuFeature,
          playlistFeature,
          //groupsFeature,
          //podcastFeature,
        },
      );
    });
    //   }
    // });
    super.initState();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  double top = 0;
  @override
  Widget build(BuildContext context) {
    final height = (context.width - 20) / 3 + 140;
    final settings = Provider.of<SettingState>(context, listen: false);
    final s = context.s;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarIconBrightness: context.brightness,
        statusBarIconBrightness: context.iconBrightness,
        systemNavigationBarColor: context.onPrimary,
        statusBarColor: context.onPrimary,
      ),
      child: WillPopScope(
        onWillPop: () async {
          if (_playerKey.currentState != null &&
              _playerKey.currentState!.initSize! > 100) {
            _playerKey.currentState!.backToMini();
            return false;
          } else if (Platform.isAndroid) {
            _androidAppRetain.invokeMethod('sendToBackground');
            return false;
          } else {
            return true;
          }
        },
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: context.onPrimary,
          body: Stack(
            children: <Widget>[
              SafeArea(
                bottom: false,
                child: NestedScrollView(
                  innerScrollPositionKeyBuilder: () {
                    return Key('tab${_controller!.index}');
                  },
                  pinnedHeaderSliverHeightBuilder: () => 50,
                  headerSliverBuilder: (context, innerBoxScrolled) {
                    return <Widget>[
                      SliverToBoxAdapter(
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 50.0,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  featureDiscoveryOverlay(
                                    context,
                                    featureId: addFeature,
                                    tapTarget: Icon(Icons.add_circle_outline),
                                    title: s.featureDiscoverySearch,
                                    backgroundColor: Colors.cyan[600],
                                    buttonColor: Colors.cyan[500],
                                    description: s.featureDiscoverySearchDes,
                                    child: IconButton(
                                      tooltip: s.add,
                                      splashRadius: 20,
                                      icon: Icon(Icons.add_circle_outline),
                                      onPressed: () async {
                                        await showSearch<int?>(
                                          context: context,
                                          delegate: MyHomePageDelegate(
                                              searchFieldLabel:
                                                  s.searchPodcast),
                                        );
                                      },
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => {
                                      Theme.of(context).brightness ==
                                              Brightness.light
                                          ? settings.setTheme = ThemeMode.dark
                                          : settings.setTheme =
                                              ThemeMode.light
                                    },
                                    child: Text(
                                      'Tsacdop',
                                      style: GoogleFonts.quicksand(
                                          color: context.accentColor,
                                          textStyle: TextStyle(fontSize: 25)),
                                    ),
                                  ),
                                  featureDiscoveryOverlay(
                                    context,
                                    featureId: menuFeature,
                                    tapTarget: Icon(Icons.more_vert),
                                    backgroundColor: Colors.cyan[500],
                                    buttonColor: Colors.cyan[600],
                                    title: s.featureDiscoveryOMPL,
                                    description: s.featureDiscoveryOMPLDes,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(right: 5.0),
                                      child: PopupMenu(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Import(),
                          ],
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: height,
                          width: context.width,
                          child: ScrollPodcasts(),
                        ),
                      ),
                      SliverPersistentHeader(
                        delegate: _SliverAppBarDelegate(
                          TabBar(
                            indicator: _getIndicator(context),
                            isScrollable: true,
                            indicatorSize: TabBarIndicatorSize.tab,
                            controller: _controller,
                            tabs: <Widget>[
                              Tab(
                                child: Text(s.homeTabMenuRecent),
                              ),
                              Tab(
                                child: Text(s.homeTabMenuFavotite),
                              ),
                              Tab(
                                child: Text(s.download),
                              )
                            ],
                          ),
                        ),
                        pinned: true,
                      ),
                    ];
                  },
                  body: Column(
                    children: [
                      Expanded(
                        child: TabBarView(
                          controller: _controller,
                          children: <Widget>[
                            NestedScrollViewInnerScrollPositionKeyWidget(
                              Key('tab0'),
                              _RecentUpdate(),
                            ),
                            NestedScrollViewInnerScrollPositionKeyWidget(
                              Key('tab1'),
                              _MyFavorite(),
                            ),
                            NestedScrollViewInnerScrollPositionKeyWidget(
                              Key('tab2'),
                              _MyDownload(),
                            ),
                          ],
                        ),
                      ),
                      Selector<AudioPlayerNotifier, bool>(
                        selector: (_, audio) => audio.playerRunning,
                        builder: (_, data, __) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: data ? 60.0 : 0),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                child: PlayerWidget(playerKey: _playerKey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height + 2;
  @override
  double get maxExtent => _tabBar.preferredSize.height + 2;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final s = context.s;
    return Container(
      color: context.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              _tabBar,
              Spacer(),
              featureDiscoveryOverlay(context,
                  featureId: playlistFeature,
                  tapTarget: Icon(Icons.playlist_play),
                  backgroundColor: Colors.cyan[500],
                  title: s.featureDiscoveryPlaylist,
                  description: s.featureDiscoveryPlaylistDes,
                  buttonColor: Colors.cyan[600],
                  child: _PlaylistButton()),
            ],
          ),
          Container(height: 2, color: context.primaryColor),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return true;
  }
}

class _PlaylistButton extends StatefulWidget {
  _PlaylistButton({Key? key}) : super(key: key);

  @override
  __PlaylistButtonState createState() => __PlaylistButtonState();
}

class __PlaylistButtonState extends State<_PlaylistButton> {
  late bool _loadPlay;

  Future<void> _getPlaylist() async {
    await context.read<AudioPlayerNotifier>().initPlaylist();
    if (mounted) {
      setState(() {
        _loadPlay = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPlay = false;
    _getPlaylist();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(100),
      clipBehavior: Clip.hardEdge,
      child: MyPopupMenuButton<int>(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        elevation: 1,
        icon: Icon(Icons.playlist_play),
        color: context.priamryContainer,
        tooltip: s.menu,
        itemBuilder: (context) => [
          MyPopupMenuItem(
            height: 50,
            value: 1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0)),
              ),
              child: Selector<AudioPlayerNotifier,
                  Tuple3<bool, EpisodeBrief?, int>>(
                selector: (_, audio) => Tuple3(
                    audio.playerRunning, audio.episode, audio.lastPosition),
                builder: (_, data, __) => !_loadPlay
                    ? SizedBox(
                        height: 8.0,
                      )
                    : data.item1 || data.item2 == null
                        ? SizedBox(
                            height: 8.0,
                          )
                        : InkWell(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                topRight: Radius.circular(10.0)),
                            onTap: () {
                              context
                                  .read<AudioPlayerNotifier>()
                                  .playFromLastPosition();
                              Navigator.pop<int>(context);
                            },
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                ),
                                Stack(
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                    CircleAvatar(
                                        radius: 20,
                                        backgroundImage:
                                            data.item2!.avatarImage),
                                    Container(
                                      height: 40.0,
                                      width: 40.0,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.black12),
                                      child: Icon(
                                        Icons.play_arrow,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 2),
                                ),
                                SizedBox(
                                  height: 70,
                                  width: 140,
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        (data.item3 ~/ 1000).toTime,
                                        style:
                                            TextStyle(color: context.textColor),
                                      ),
                                      Text(
                                        data.item2!.title!,
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.fade,
                                        style:
                                            TextStyle(color: context.textColor),
                                        // style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  height: 1,
                                ),
                              ],
                            ),
                          ),
              ),
            ),
          ),
          PopupMenuItem(
            value: 0,
            child: Container(
              padding: EdgeInsets.only(left: 10),
              child: Row(
                children: <Widget>[
                  Icon(Icons.playlist_play),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.0),
                  ),
                  Text(
                    s.homeMenuPlaylist,
                    style: TextStyle(color: context.textColor),
                  ),
                ],
              ),
            ),
          ),
          //PopupMenuDivider(
          //  height: 1,
          //),
          // PopupMenuItem(
          //   value: 2,
          //   child: Container(
          //     padding: EdgeInsets.only(left: 10),
          //     child: Row(
          //       children: <Widget>[
          //         Icon(Icons.history),
          //         Padding(
          //           padding: const EdgeInsets.symmetric(horizontal: 5.0),
          //         ),
          //         Text(s.settingsHistory),
          //       ],
          //     ),
          //   ),
          // ),
          // PopupMenuDivider(
          //   height: 1,
          // ),
        ],
        onSelected: (value) {
          if (value == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PlaylistHome(),
              ),
            );
          }
        },
      ),
    );
  }
}

class _RecentUpdate extends StatefulWidget {
  @override
  _RecentUpdateState createState() => _RecentUpdateState();
}

class _RecentUpdateState extends State<_RecentUpdate>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  //final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  //    GlobalKey<RefreshIndicatorState>();
  final _dbHelper = DBHelper();

  /// Episodes loaded first time.
  int _top = 90;

  /// Load more episodes when scroll to bottom.
  late bool _loadMore;

  /// For group fliter.
  String? _groupName;
  List<String?>? _group;
  Layout? _layout;
  bool? _hideListened;
  late bool _scroll;

  ///Selected episode list.
  List<EpisodeBrief>? _selectedEpisodes;

  ///Toggle for multi-select.
  bool? _multiSelect;

  @override
  void initState() {
    super.initState();
    _loadMore = false;
    _groupName = 'All';
    _group = [];
    _scroll = false;
    _multiSelect = false;
  }

  Future<void> _updateRssItem() async {
    final refreshWorker = context.read<RefreshWorker>();
    refreshWorker.start(_group);
    await Future.delayed(Duration(seconds: 1));
    Fluttertoast.showToast(
      msg: context.s.refreshStarted,
      gravity: ToastGravity.BOTTOM,
    );
  }

  Future<List<EpisodeBrief>> _getRssItem(int top, List<String?> group,
      {bool? hideListened}) async {
    var storage = KeyValueStorage(recentLayoutKey);
    var hideListenedStorage = KeyValueStorage(hideListenedKey);
    var index = await storage.getInt(defaultValue: 1);
    if (_layout == null) _layout = Layout.values[index];
    if (_hideListened == null) {
      _hideListened = await hideListenedStorage.getBool(defaultValue: false);
    }

    List<EpisodeBrief> episodes;
    if (group.isEmpty) {
      episodes =
          await _dbHelper.getRecentRssItem(top, hideListened: _hideListened!);
    } else {
      episodes = await _dbHelper.getGroupRssItem(top, group,
          hideListened: _hideListened);
    }
    return episodes;
  }

  Future<int> _getUpdateCounts(List<String?> group) async {
    var episodes = <EpisodeBrief>[];

    if (group.isEmpty) {
      episodes = await _dbHelper.getRecentNewRssItem();
    } else {
      episodes = await _dbHelper.getGroupNewRssItem(group);
    }
    return episodes.length;
  }

  /// Load more episodes.
  Future<void> _loadMoreEpisode() async {
    if (mounted) setState(() => _loadMore = true);
    await Future.delayed(Duration(seconds: 3));
    if (mounted) {
      setState(() {
        _top = _top + 30;
        _loadMore = false;
      });
    }
  }

  /// Remove new mark.
  Future<void> _removeNewMark(List<String?> group) async {
    if (group.isEmpty) {
      _dbHelper.removeAllNewMark();
    } else {
      _dbHelper.removeGroupNewMark(group);
    }
  }

  Widget _switchGroupButton() {
    return Consumer<GroupList>(
      builder: (context, groupList, child) => PopupMenuButton<String>(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 1,
        tooltip: context.s.groupFilter,
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            height: 50,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(_groupName == 'All' ? context.s.all : _groupName!),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                ),
                Icon(
                  LineIcons.filter,
                  size: 18,
                )
              ],
            )),
        itemBuilder: (context) => [
          PopupMenuItem(
              child: Row(children: [
                Text(context.s.all),
                Spacer(),
                if (_groupName == 'All') DotIndicator()
              ]),
              value: 'All')
        ]..addAll(groupList.groups
            .map<PopupMenuEntry<String>>((e) => PopupMenuItem(
                value: e!.name,
                child: Row(
                  children: [
                    Text(e.name!),
                    Spacer(),
                    if (e.name == _groupName) DotIndicator()
                  ],
                )))
            .toList()),
        onSelected: (value) {
          if (value == 'All') {
            setState(() {
              _groupName = 'All';
              _group = [];
            });
          } else {
            for (var group in groupList.groups) {
              if (group!.name == value) {
                setState(() {
                  _groupName = value;
                  _group = group.podcastList;
                });
              }
            }
          }
        },
      ),
    );
  }

  Widget _addNewButton() {
    //  final audio = context.read<AudioPlayerNotifier>();
    final s = context.s;
    return FutureBuilder<int>(
      future: _getUpdateCounts(_group!),
      initialData: 0,
      builder: (context, snapshot) {
        return snapshot.data != 0
            ? Material(
                color: Colors.transparent,
                child: Row(
                  children: [
                    IconButton(
                        tooltip: s.removeNewMark,
                        icon: SizedBox(
                            height: 20,
                            width: 20,
                            child: CustomPaint(
                                painter: RemoveNewFlagPainter(
                                    context.textTheme.bodyText1!.color,
                                    Colors.red))),
                        onPressed: () async {
                          _removeNewMark(_group!);
                          if (mounted) {
                            setState(() {});
                          }
                        }),
                    //  IconButton(
                    //      tooltip: s.addNewEpisodeTooltip,
                    //      icon: SizedBox(
                    //          height: 15,
                    //          width: 20,
                    //          child: CustomPaint(
                    //              painter: AddToPlaylistPainter(
                    //                  context.textTheme.bodyText1.color,
                    //                  Colors.red))),
                    //      onPressed: () async {
                    //        await audio.addNewEpisode(_group);
                    //        if (mounted) {
                    //          setState(() {});
                    //        }
                    //        Fluttertoast.showToast(
                    //          msg: _groupName == 'All'
                    //              ? s.addNewEpisodeAll(snapshot.data)
                    //              : s.addEpisodeGroup(
                    //                  _groupName, snapshot.data),
                    //          gravity: ToastGravity.BOTTOM,
                    //        );
                    //      }),
                  ],
                ),
              )
            : Center();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final s = context.s;
    return Selector2<RefreshWorker, GroupList, Tuple2<bool, bool>>(
      selector: (_, refreshWorkder, groupWorker) =>
          Tuple2(refreshWorkder.created, groupWorker.created),
      builder: (_, data, __) {
        return FutureBuilder<List<EpisodeBrief>>(
          future: _getRssItem(_top, _group!, hideListened: _hideListened),
          builder: (context, snapshot) {
            return (snapshot.hasData)
                ? snapshot.data!.length == 0
                    ? Padding(
                        padding: EdgeInsets.only(top: 150),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(LineIcons.alternateCloudDownload,
                                size: 80, color: Colors.grey[500]),
                            Padding(
                                padding: EdgeInsets.symmetric(vertical: 10)),
                            Text(
                              s.noEpisodeRecent,
                              style: TextStyle(color: Colors.grey[500]),
                            )
                          ],
                        ),
                      )
                    : NotificationListener<ScrollNotification>(
                        onNotification: (scrollInfo) {
                          if (scrollInfo is ScrollStartNotification &&
                              mounted &&
                              !_scroll) {
                            setState(() => _scroll = true);
                          }
                          if (scrollInfo.metrics.pixels ==
                                  scrollInfo.metrics.maxScrollExtent &&
                              snapshot.data!.length == _top) {
                            if (!_loadMore) {
                              _loadMoreEpisode();
                            }
                          }
                          return true;
                        },
                        child: Stack(
                          children: [
                            ScrollConfiguration(
                              behavior: NoGrowBehavior(),
                              child: CustomScrollView(
                                  key: PageStorageKey<String>('update'),
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  slivers: <Widget>[
                                    SliverToBoxAdapter(
                                      child: SizedBox(
                                        height: 40,
                                      ),
                                    ),
                                    EpisodeGrid(
                                      episodes: snapshot.data,
                                      layout: _layout,
                                      initNum: _scroll ? 0 : 12,
                                      multiSelect: _multiSelect,
                                      openPodcast: true,
                                      selectedList: _selectedEpisodes ?? [],
                                      onSelect: (value) => setState(() {
                                        _selectedEpisodes = value;
                                      }),
                                    ),
                                    SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        (context, index) {
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
                                  ]),
                            ),
                            Column(
                              children: [
                                if (!_multiSelect!)
                                  Container(
                                      height: 40,
                                      color: context.primaryColor,
                                      child: Material(
                                        color: Colors.transparent,
                                        child: Row(
                                          children: <Widget>[
                                            _switchGroupButton(),
                                            Spacer(),
                                            Material(
                                              color: Colors.transparent,
                                              child: IconButton(
                                                  tooltip: context.s.refresh,
                                                  icon: Icon(
                                                      LineIcons.alternateRedo,
                                                      size: 16),
                                                  onPressed: () {
                                                    _updateRssItem();
                                                    Fluttertoast.showToast(
                                                      msg: s.refreshStarted,
                                                      gravity:
                                                          ToastGravity.BOTTOM,
                                                    );
                                                  }),
                                            ),
                                            _addNewButton(),
                                            Material(
                                              color: Colors.transparent,
                                              child: IconButton(
                                                tooltip: s.hideListenedSetting,
                                                icon: SizedBox(
                                                  width: 30,
                                                  height: 15,
                                                  child: HideListened(
                                                    hideListened:
                                                        _hideListened ?? false,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  setState(() => _hideListened =
                                                      !_hideListened!);
                                                },
                                              ),
                                            ),
                                            Material(
                                              color: Colors.transparent,
                                              child: LayoutButton(
                                                layout: _layout,
                                                onPressed: (layout) =>
                                                    setState(() {
                                                  _layout = layout;
                                                }),
                                              ),
                                            ),
                                            Material(
                                                color: Colors.transparent,
                                                child: IconButton(
                                                  icon: SizedBox(
                                                    width: 20,
                                                    height: 10,
                                                    child: CustomPaint(
                                                        painter:
                                                            MultiSelectPainter(
                                                                color: context
                                                                    .accentColor)),
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      _selectedEpisodes = [];
                                                      _multiSelect = true;
                                                    });
                                                  },
                                                )),
                                          ],
                                        ),
                                      )),
                                if (_multiSelect!)
                                  MultiSelectMenuBar(
                                    selectedList: _selectedEpisodes,
                                    onClose: (value) {
                                      setState(() {
                                        if (value) {
                                          _multiSelect = false;
                                        }
                                      });
                                    },
                                  ),
                              ],
                            ),
                          ],
                        ),
                      )
                : Center();
          },
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _MyFavorite extends StatefulWidget {
  @override
  _MyFavoriteState createState() => _MyFavoriteState();
}

class _MyFavoriteState extends State<_MyFavorite>
    with AutomaticKeepAliveClientMixin {
  Future<List<EpisodeBrief>> _getLikedRssItem(int top, int? sortBy,
      {bool? hideListened}) async {
    var storage = KeyValueStorage(favLayoutKey);
    var index = await storage.getInt(defaultValue: 1);
    var hideListenedStorage = KeyValueStorage(hideListenedKey);
    if (_layout == null) _layout = Layout.values[index];
    if (_hideListened == null) {
      _hideListened = await hideListenedStorage.getBool(defaultValue: false);
    }
    var dbHelper = DBHelper();
    var episodes = await dbHelper.getLikedRssItem(top, sortBy,
        hideListened: _hideListened!);
    return episodes;
  }

  Future<void> _loadMoreEpisode() async {
    if (mounted) setState(() => _loadMore = true);
    await Future.delayed(Duration(seconds: 3));
    if (mounted) {
      setState(() {
        _top = _top + 30;
        _loadMore = false;
      });
    }
  }

  int _top = 90;
  late bool _loadMore;
  Layout? _layout;
  int? _sortBy;
  bool? _hideListened;

  ///Selected episode list.
  List<EpisodeBrief>? _selectedEpisodes;

  ///Toggle for multi-select.
  bool? _multiSelect;

  @override
  void initState() {
    super.initState();
    _loadMore = false;
    _sortBy = 0;
    _multiSelect = false;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final s = context.s;
    return Selector<AudioPlayerNotifier, bool>(
        selector: (_, audio) => audio.episodeState,
        builder: (context, episodeState, child) {
          return FutureBuilder<List<EpisodeBrief>>(
            future:
                _getLikedRssItem(_top, _sortBy, hideListened: _hideListened),
            builder: (context, snapshot) {
              return (snapshot.hasData)
                  ? snapshot.data!.length == 0
                      ? Padding(
                          padding: EdgeInsets.only(top: 150),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(LineIcons.heartbeat,
                                  size: 80, color: Colors.grey[500]),
                              Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10)),
                              Text(
                                s.noEpisodeFavorite,
                                style: TextStyle(color: Colors.grey[500]),
                              )
                            ],
                          ),
                        )
                      : NotificationListener<ScrollNotification>(
                          onNotification: (scrollInfo) {
                            if (scrollInfo.metrics.pixels ==
                                    scrollInfo.metrics.maxScrollExtent &&
                                snapshot.data!.length == _top) {
                              if (!_loadMore) {
                                _loadMoreEpisode();
                              }
                            }
                            return true;
                          },
                          child: Stack(
                            children: [
                              ScrollConfiguration(
                                behavior: NoGrowBehavior(),
                                child: CustomScrollView(
                                  key: PageStorageKey<String>('favorite'),
                                  slivers: <Widget>[
                                    SliverToBoxAdapter(
                                        child: SizedBox(height: 40)),
                                    EpisodeGrid(
                                      episodes: snapshot.data,
                                      layout: _layout,
                                      initNum: 0,
                                      openPodcast: true,
                                      multiSelect: _multiSelect,
                                      selectedList: _selectedEpisodes ?? [],
                                      onSelect: (value) => setState(() {
                                        _selectedEpisodes = value;
                                      }),
                                    ),
                                    SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        (context, index) {
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
                                ),
                              ),
                              Column(
                                children: [
                                  if (!_multiSelect!)
                                    Container(
                                      height: 40,
                                      color: context.primaryColor,
                                      child: Row(
                                        children: <Widget>[
                                          Material(
                                            color: Colors.transparent,
                                            child: PopupMenuButton<int>(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(10))),
                                              elevation: 1,
                                              tooltip: s.homeSubMenuSortBy,
                                              child: Container(
                                                  height: 50,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 20),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: <Widget>[
                                                      Text(s.homeSubMenuSortBy),
                                                      Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 5),
                                                      ),
                                                      Icon(
                                                        LineIcons
                                                            .hourglassStart,
                                                        size: 18,
                                                      )
                                                    ],
                                                  )),
                                              itemBuilder: (context) => [
                                                PopupMenuItem(
                                                  value: 0,
                                                  child: Row(
                                                    children: [
                                                      Text(s.updateDate),
                                                      Spacer(),
                                                      if (_sortBy == 0)
                                                        DotIndicator()
                                                    ],
                                                  ),
                                                ),
                                                PopupMenuItem(
                                                  value: 1,
                                                  child: Row(
                                                    children: [
                                                      Text(s.likeDate),
                                                      Spacer(),
                                                      if (_sortBy == 1)
                                                        DotIndicator()
                                                    ],
                                                  ),
                                                )
                                              ],
                                              onSelected: (value) {
                                                if (value == 0) {
                                                  setState(() => _sortBy = 0);
                                                } else if (value == 1) {
                                                  setState(() => _sortBy = 1);
                                                }
                                              },
                                            ),
                                          ),
                                          Spacer(),
                                          Material(
                                            color: Colors.transparent,
                                            child: IconButton(
                                              icon: SizedBox(
                                                width: 30,
                                                height: 15,
                                                child: HideListened(
                                                  hideListened:
                                                      _hideListened ?? false,
                                                ),
                                              ),
                                              onPressed: () {
                                                setState(() => _hideListened =
                                                    !_hideListened!);
                                              },
                                            ),
                                          ),
                                          Material(
                                            color: Colors.transparent,
                                            child: LayoutButton(
                                              layout: _layout,
                                              onPressed: (layout) =>
                                                  setState(() {
                                                _layout = layout;
                                              }),
                                            ),
                                          ),
                                          Material(
                                              color: Colors.transparent,
                                              child: IconButton(
                                                icon: SizedBox(
                                                  width: 20,
                                                  height: 10,
                                                  child: CustomPaint(
                                                      painter:
                                                          MultiSelectPainter(
                                                              color: context
                                                                  .accentColor)),
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _selectedEpisodes = [];
                                                    _multiSelect = true;
                                                  });
                                                },
                                              )),
                                        ],
                                      ),
                                    ),
                                  if (_multiSelect!)
                                    MultiSelectMenuBar(
                                      selectedList: _selectedEpisodes,
                                      hideFavorite: true,
                                      onClose: (value) {
                                        setState(() {
                                          if (value) {
                                            _multiSelect = false;
                                          }
                                        });
                                      },
                                    ),
                                ],
                              ),
                            ],
                          ),
                        )
                  : Center();
            },
          );
        });
  }

  @override
  bool get wantKeepAlive => true;
}

class _MyDownload extends StatefulWidget {
  @override
  _MyDownloadState createState() => _MyDownloadState();
}

class _MyDownloadState extends State<_MyDownload>
    with AutomaticKeepAliveClientMixin {
  Layout? _layout;
  int? _sortBy;
  bool? _hideListened;
  Future<List<EpisodeBrief>> _getDownloadedEpisodes(int? sortBy,
      {bool? hideListened}) async {
    var storage = KeyValueStorage(downloadLayoutKey);
    var index = await storage.getInt(defaultValue: 1);
    var hideListenedStorage = KeyValueStorage(hideListenedKey);
    if (_layout == null) _layout = Layout.values[index];
    if (_hideListened == null) {
      _hideListened = await hideListenedStorage.getBool(defaultValue: false);
    }
    var dbHelper = DBHelper();
    var episodes = await dbHelper.getDownloadedEpisode(sortBy,
        hideListened: _hideListened!);
    return episodes;
  }

  @override
  void initState() {
    super.initState();
    _sortBy = 0;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final s = context.s;
    return Consumer<DownloadState>(
      builder: (_, data, __) => FutureBuilder<List<EpisodeBrief>>(
        future: _getDownloadedEpisodes(_sortBy, hideListened: _hideListened),
        builder: (context, snapshot) {
          var episodes = snapshot.data ?? [];
          return ScrollConfiguration(
            behavior: NoGrowBehavior(),
            child: CustomScrollView(
              key: PageStorageKey<String>('download_list'),
              slivers: <Widget>[
                DownloadList(),
                SliverToBoxAdapter(
                  child: Container(
                      height: 40,
                      color: context.primaryColor,
                      child: Row(
                        children: <Widget>[
                          Container(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Text(s.downloaded)),
                          Spacer(),
                          Material(
                            color: Colors.transparent,
                            child: IconButton(
                              icon: SizedBox(
                                width: 30,
                                height: 15,
                                child: HideListened(
                                  hideListened: _hideListened ?? false,
                                ),
                              ),
                              onPressed: () {
                                setState(() => _hideListened = !_hideListened!);
                              },
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: LayoutButton(
                              layout: _layout ?? Layout.one,
                              onPressed: (layout) => setState(() {
                                _layout = layout;
                              }),
                            ),
                          ),
                        ],
                      )),
                ),
                episodes.length == 0
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 110),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(LineIcons.download,
                                  size: 80, color: Colors.grey[500]),
                              Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10)),
                              Text(
                                s.noEpisodeDownload,
                                style: TextStyle(color: Colors.grey[500]),
                              )
                            ],
                          ),
                        ),
                      )
                    : EpisodeGrid(
                        episodes: episodes,
                        layout: _layout,
                        openPodcast: true,
                        initNum: 0,
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
