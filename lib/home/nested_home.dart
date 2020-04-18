import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart' hide NestedScrollView;
import 'package:provider/provider.dart';
import 'package:tsacdop/class/download_state.dart';
import 'package:tsacdop/class/podcast_group.dart';
import 'package:tsacdop/home/playlist.dart';
import 'package:tuple/tuple.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:line_icons/line_icons.dart';

import 'package:tsacdop/class/audiostate.dart';
import 'package:tsacdop/class/episodebrief.dart';
import 'package:tsacdop/local_storage/sqflite_localpodcast.dart';
import 'package:tsacdop/util/episodegrid.dart';
import 'package:tsacdop/util/mypopupmenu.dart';
import 'package:tsacdop/util/context_extension.dart';
import 'package:tsacdop/util/custompaint.dart';

import 'package:tsacdop/home/appbar/importompl.dart';
import 'package:tsacdop/home/audioplayer.dart';
import 'home_groups.dart';
import 'download_list.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  TabController _controller;
  Decoration _getIndicator(BuildContext context) {
    return UnderlineTabIndicator(
        borderSide: BorderSide(color: Theme.of(context).accentColor, width: 3),
        insets: EdgeInsets.only(
          left: 10.0,
          right: 10.0,
          top: 10.0,
        ));
  }

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double top = 0;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = (width - 20) / 3 + 140;
    return SafeArea(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Import(),
              Expanded(
                child: NestedScrollView(
                  innerScrollPositionKeyBuilder: () {
                    return Key('tab' + _controller.index.toString());
                  },
                  pinnedHeaderSliverHeightBuilder: () => 50,
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxScrolled) {
                    return <Widget>[
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            return SizedBox(
                              height: height,
                              width: width,
                              child: ScrollPodcasts(),
                            );
                          },
                          childCount: 1,
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
                                child: Text('Recent Update'),
                              ),
                              Tab(
                                child: Text('Favorite'),
                              ),
                              Tab(
                                child: Text('Download'),
                              )
                            ],
                          ),
                        ),
                        pinned: true,
                      ),
                    ];
                  },
                  body: TabBarView(
                    controller: _controller,
                    children: <Widget>[
                      NestedScrollViewInnerScrollPositionKeyWidget(
                          Key('tab0'), _RecentUpdate()),
                      NestedScrollViewInnerScrollPositionKeyWidget(
                          Key('tab1'), _MyFavorite()),
                      NestedScrollViewInnerScrollPositionKeyWidget(
                          Key('tab2'), _MyDownload()),
                    ],
                  ),
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
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              _tabBar,
              Spacer(),
              PlaylistButton(),
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

class PlaylistButton extends StatefulWidget {
  PlaylistButton({Key key}) : super(key: key);

  @override
  PlaylistButtonState createState() => PlaylistButtonState();
}

class PlaylistButtonState extends State<PlaylistButton> {
  bool _loadPlay;
  static String _stringForSeconds(int seconds) {
    if (seconds == null) return null;
    return '${(seconds ~/ 60)}:${(seconds.truncate() % 60).toString().padLeft(2, '0')}';
  }

  _getPlaylist() async {
    await Provider.of<AudioPlayerNotifier>(context, listen: false)
        .loadPlaylist();
    setState(() {
      _loadPlay = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadPlay = false;
    _getPlaylist();
  }

  @override
  Widget build(BuildContext context) {
    var audio = Provider.of<AudioPlayerNotifier>(context, listen: false);
    return MyPopupMenuButton<int>(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      elevation: 1,
      icon: Icon(Icons.playlist_play),
      tooltip: "Menu",
      itemBuilder: (context) => [
        MyPopupMenuItem(
          height: 50,
          value: 1,
          child: Container(
            decoration: BoxDecoration(
              //  color: Theme.of(context).accentColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0)),
            ),
            child: Selector<AudioPlayerNotifier, Tuple3<bool, Playlist, int>>(
              selector: (_, audio) =>
                  Tuple3(audio.playerRunning, audio.queue, audio.lastPositin),
              builder: (_, data, __) => !_loadPlay
                  ? Container(
                      height: 8.0,
                    )
                  : data.item1 || data.item2.playlist.length == 0
                      ? Container(
                          height: 8.0,
                        )
                      : InkWell(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10.0),
                              topRight: Radius.circular(10.0)),
                          onTap: () {
                            audio.playlistLoad();
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
                                    backgroundImage: FileImage(File(
                                        "${data.item2.playlist.first.imagePath}")),
                                  ),
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
                              Container(
                                height: 70,
                                width: 140,
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      _stringForSeconds(data.item3 ~/ 1000),
                                      // style:
                                      // TextStyle(color: Colors.white)
                                    ),
                                    Text(
                                      data.item2.playlist.first.title,
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.fade,
                                      // style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(
                                height: 2,
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
                Text('Playlist'),
              ],
            ),
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 0) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => PlaylistPage()));
        } else if (value == 1) {}
      },
    );
  }
}

class _RecentUpdate extends StatefulWidget {
  @override
  _RecentUpdateState createState() => _RecentUpdateState();
}

class _RecentUpdateState extends State<_RecentUpdate>
    with AutomaticKeepAliveClientMixin , SingleTickerProviderStateMixin{
  Future<List<EpisodeBrief>> _getRssItem(int top, List<String> group) async {
    var dbHelper = DBHelper();
    List<EpisodeBrief> episodes;
    if (group.first == 'All')
      episodes = await dbHelper.getRecentRssItem(top);
    else
      episodes = await dbHelper.getGroupRssItem(top, group);
    return episodes;
  }

  _loadMoreEpisode() async {
    if (mounted) setState(() => _loadMore = true);
    await Future.delayed(Duration(seconds: 3));
    if (mounted)
      setState(() {
        _top = _top + 33;
        _loadMore = false;
      });
  }

  int _top = 99;
  bool _loadMore;
  String _groupName;
  List<String> _group;
  Layout _layout;
  @override
  void initState() {
    super.initState();
    _loadMore = false;
    _groupName = 'All';
    _group = ['All'];
    _layout = Layout.three;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<List<EpisodeBrief>>(
      future: _getRssItem(_top, _group),
      builder: (context, snapshot) {
        if (snapshot.hasError) print(snapshot.error);
        return (snapshot.hasData)
            ? NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent &&
                      snapshot.data.length == _top) _loadMoreEpisode();
                  return true;
                },
                child: CustomScrollView(
                    key: PageStorageKey<String>('update'),
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: <Widget>[
                      SliverToBoxAdapter(
                        child: Container(
                            height: 40,
                            color: context.primaryColor,
                            child: Row(
                              children: <Widget>[
                                Consumer<GroupList>(
                                  builder: (context, groupList, child) =>
                                      Material(
                                    color: Colors.transparent,
                                    child: PopupMenuButton<String>(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      elevation: 1,
                                      tooltip: 'Groups fliter',
                                      child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 20),
                                          height: 50,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text(_groupName),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 5),
                                              ),
                                              Icon(
                                                LineIcons.filter_solid,
                                                size: 18,
                                              )
                                            ],
                                          )),
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                            child: Text('All'), value: 'All')
                                      ]..addAll(groupList.groups
                                          .map<PopupMenuEntry<String>>((e) =>
                                              PopupMenuItem(
                                                  value: e.name,
                                                  child: Text(e.name)))
                                          .toList()),
                                      onSelected: (value) {
                                        if (value == 'All') {
                                          setState(() {
                                            _groupName = 'All';
                                            _group = ['All'];
                                          });
                                        } else {
                                          groupList.groups.forEach((group) {
                                            if (group.name == value) {
                                              setState(() {
                                                _groupName = value;
                                                _group = group.podcastList;
                                              });
                                            }
                                          });
                                        }
                                      },
                                    ),
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
                                                    context.textTheme.bodyText1
                                                        .color),
                                              ),
                                            )
                                          : SizedBox(
                                              height: 10,
                                              width: 30,
                                              child: CustomPaint(
                                                painter: LayoutPainter(
                                                    1,
                                                    context.textTheme.bodyText1
                                                        .color),
                                              ),
                                            ),
                                    )),
                              ],
                            )),
                      ),
                      EpisodeGrid(
                        episodes: snapshot.data,
                        layout: _layout,
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            return _loadMore
                                ? Container(
                                    height: 2, child: LinearProgressIndicator())
                                : Center();
                          },
                          childCount: 1,
                        ),
                      ),
                    ]),
              )
            : Center(child: CircularProgressIndicator());
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
  Future<List<EpisodeBrief>> _getLikedRssItem(int top, int sortBy) async {
    var dbHelper = DBHelper();
    List<EpisodeBrief> episodes = await dbHelper.getLikedRssItem(top, sortBy);
    return episodes;
  }

  _loadMoreEpisode() async {
    if (mounted) setState(() => _loadMore = true);
    await Future.delayed(Duration(seconds: 3));
    if (mounted)
      setState(() {
        _top = _top + 33;
        _loadMore = false;
      });
  }

  int _top = 99;
  bool _loadMore;
  Layout _layout;
  int _sortBy;
  @override
  void initState() {
    super.initState();
    _loadMore = false;
    _layout = Layout.three;
    _sortBy = 0;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<List<EpisodeBrief>>(
      future: _getLikedRssItem(_top, _sortBy),
      builder: (context, snapshot) {
        if (snapshot.hasError) print(snapshot.error);
        return (snapshot.hasData)
            ? NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent &&
                      snapshot.data.length == _top) _loadMoreEpisode();
                  return true;
                },
                child: CustomScrollView(
                  key: PageStorageKey<String>('favorite'),
                  slivers: <Widget>[
                    SliverToBoxAdapter(
                      child: Container(
                          height: 40,
                          color: context.primaryColor,
                          child: Row(
                            children: <Widget>[
                              Material(
                                color: Colors.transparent,
                                child: PopupMenuButton<int>(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  elevation: 1,
                                  tooltip: 'Sort By',
                                  child: Container(
                                      height: 50,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text('Sory by'),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 5),
                                          ),
                                          Icon(
                                            _sortBy == 0
                                                ? LineIcons
                                                    .cloud_download_alt_solid
                                                : LineIcons.heartbeat_solid,
                                            size: 18,
                                          )
                                        ],
                                      )),
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 0,
                                      child: Text('Update Date'),
                                    ),
                                    PopupMenuItem(
                                      value: 1,
                                      child: Text('Like Date'),
                                    )
                                  ],
                                  onSelected: (value) {
                                    if (value == 0)
                                      setState(() => _sortBy = 0);
                                    else if (value == 1)
                                      setState(() => _sortBy = 1);
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
                                                    .textTheme.bodyText1.color),
                                          ),
                                        )
                                      : SizedBox(
                                          height: 10,
                                          width: 30,
                                          child: CustomPaint(
                                            painter: LayoutPainter(
                                                1,
                                                context
                                                    .textTheme.bodyText1.color),
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          )),
                    ),
                    EpisodeGrid(
                      episodes: snapshot.data,
                      layout: _layout,
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          return _loadMore
                              ? Container(
                                  height: 2, child: LinearProgressIndicator())
                              : Center();
                        },
                        childCount: 1,
                      ),
                    ),
                  ],
                ),
              )
            : Center(child: CircularProgressIndicator());
      },
    );
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
  Layout _layout;
  @override
  void initState() {
    super.initState();
    _layout = Layout.three;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CustomScrollView(
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
                    child: Text('Downloaded')),
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
                                    0, context.textTheme.bodyText1.color),
                              ),
                            )
                          : SizedBox(
                              height: 10,
                              width: 30,
                              child: CustomPaint(
                                painter: LayoutPainter(
                                    1, context.textTheme.bodyText1.color),
                              ),
                            ),
                    ),
                  ),
                ],
              )),
        ),
        Consumer<DownloadState>(
          builder: (_, downloader, __) {
            var episodes = downloader.episodeTasks
                .where((task) => task.status.value == 3)
                .toList()
                .map((e) => e.episode)
                .toList()
                .reversed
                .toList();
            return EpisodeGrid(
              episodes: episodes,
              layout: _layout,
            );
          },
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}