import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tsacdop/local_storage/key_value_storage.dart';
import 'package:tuple/tuple.dart';
import 'package:tsacdop/class/audiostate.dart';
import 'package:tsacdop/class/episodebrief.dart';
import 'package:tsacdop/home/playlist.dart';
import 'package:tsacdop/local_storage/sqflite_localpodcast.dart';
import 'package:tsacdop/util/episodegrid.dart';
import 'package:tsacdop/util/mypopupmenu.dart';

class MainTab extends StatefulWidget {
  @override
  _MainTabState createState() => _MainTabState();
}

class _MainTabState extends State<MainTab> with TickerProviderStateMixin {
  TabController _controller;
  bool _loadPlay;
  static String _stringForSeconds(int seconds) {
    if (seconds == null) return null;
    return '${(seconds ~/ 60)}:${(seconds.truncate() % 60).toString().padLeft(2, '0')}';
  }

  Decoration getIndicator(BuildContext context) {
    return UnderlineTabIndicator(
        borderSide: BorderSide(color: Theme.of(context).accentColor, width: 2),
        insets: EdgeInsets.only(
          left: 10.0,
          right: 10.0,
          top: 10.0,
        ));
  }

  _getPlaylist() async {
    await Provider.of<AudioPlayerNotifier>(context, listen: false)
        .loadPlaylist();
    setState(() {
      _loadPlay = true;
    });
  }

  Widget playlist(BuildContext context) {
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

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 3, vsync: this);
    _loadPlay = false;
    _getPlaylist();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              height: 50,
              alignment: Alignment.centerLeft,
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                isScrollable: true,
                labelPadding: EdgeInsets.all(10.0),
                controller: _controller,
                indicator: getIndicator(context),
                tabs: <Widget>[
                  Text(
                    'Recent Update',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Favorites',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Downloads',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Spacer(),
            playlist(context),
          ],
        ),
        Expanded(
          child: Container(
            child: TabBarView(
              controller: _controller,
              children: <Widget>[
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: RecentUpdate()),
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: MyFavorite()),
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: MyDownload()),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class RecentUpdate extends StatefulWidget {
  @override
  _RecentUpdateState createState() => _RecentUpdateState();
}

class _RecentUpdateState extends State<RecentUpdate> {
  int _updateCount = 0;
  Future<List<EpisodeBrief>> _getRssItem(int top) async {
    var dbHelper = DBHelper();
    List<EpisodeBrief> episodes = await dbHelper.getRecentRssItem(top);
    KeyValueStorage refreshcountstorage = KeyValueStorage('refreshcount');
    _updateCount = await refreshcountstorage.getInt();
    return episodes;
  }

  ScrollController _controller;
  int _top;
  bool _loadMore;
  _scrollListener() async {
    if (_controller.offset == _controller.position.maxScrollExtent) {
      if (mounted) setState(() => _loadMore = true);
      await Future.delayed(Duration(seconds: 3));
      if (mounted)
        setState(() {
          _top = _top + 33;
          _loadMore = false;
        });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMore = false;
    _top = 33;
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EpisodeBrief>>(
      future: _getRssItem(_top),
      builder: (context, snapshot) {
        if (snapshot.hasError) print(snapshot.error);
        return (snapshot.hasData)
            ? CustomScrollView(
                controller: _controller,
                physics: const AlwaysScrollableScrollPhysics(),
                primary: false,
                slivers: <Widget>[
                    EpisodeGrid(
                      podcast: snapshot.data,
                      showDownload: false,
                      showFavorite: false,
                      showNumber: false,
                      heroTag: 'recent',
                      updateCount: _updateCount,
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
                  ])
            : Center(child: CircularProgressIndicator());
      },
    );
  }
}

class MyFavorite extends StatefulWidget {
  @override
  _MyFavoriteState createState() => _MyFavoriteState();
}

class _MyFavoriteState extends State<MyFavorite> {
  Future<List<EpisodeBrief>> _getLikedRssItem() async {
    var dbHelper = DBHelper();
    List<EpisodeBrief> episodes = await dbHelper.getLikedRssItem();
    return episodes;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EpisodeBrief>>(
      future: _getLikedRssItem(),
      builder: (context, snapshot) {
        if (snapshot.hasError) print(snapshot.error);
        return (snapshot.hasData)
            ? CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                primary: false,
                slivers: <Widget>[
                  EpisodeGrid(
                    podcast: snapshot.data,
                    showDownload: false,
                    showFavorite: false,
                    showNumber: false,
                    heroTag: 'favorite',
                  )
                ],
              )
            : Center(child: CircularProgressIndicator());
      },
    );
  }
}

class MyDownload extends StatefulWidget {
  @override
  _MyDownloadState createState() => _MyDownloadState();
}

class _MyDownloadState extends State<MyDownload> {
  Future<List<EpisodeBrief>> _getDownloadedRssItem() async {
    var dbHelper = DBHelper();
    List<EpisodeBrief> episodes = await dbHelper.getDownloadedRssItem();
    return episodes;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EpisodeBrief>>(
      future: _getDownloadedRssItem(),
      builder: (context, snapshot) {
        if (snapshot.hasError) print(snapshot.error);
        return (snapshot.hasData)
            ? CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                primary: false,
                slivers: <Widget>[
                  EpisodeGrid(
                    podcast: snapshot.data,
                    showDownload: true,
                    showFavorite: false,
                    showNumber: false,
                    heroTag: 'download',
                  )
                ],
              )
            : Center(child: CircularProgressIndicator());
      },
    );
  }
}
