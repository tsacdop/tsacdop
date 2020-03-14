import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tsacdop/class/episodebrief.dart';
import 'package:tsacdop/settings/history.dart';
import 'package:tsacdop/local_storage/sqflite_localpodcast.dart';
import 'package:tsacdop/util/episodegrid.dart';

class MainTab extends StatefulWidget {
  @override
  _MainTabState createState() => _MainTabState();
}

class _MainTabState extends State<MainTab> with TickerProviderStateMixin {
  TabController _controller;
  Decoration getIndicator(BuildContext context) {
    return UnderlineTabIndicator(
        borderSide: BorderSide(color: Theme.of(context).accentColor, width: 2),
        insets: EdgeInsets.only(
          left: 10.0,
          right: 10.0,
          top: 10.0,
        ));
  }

  Widget playHistory() {
    return PopupMenuButton<int>(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      elevation: 1,
      icon: Icon(Icons.history),
      tooltip: "Menu",
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 0,
          child: Container(
            padding: EdgeInsets.only(left: 10),
            child: Row(
              children: <Widget>[
                Icon(Icons.history),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.0),
                ),
                Text('Play History'),
              ],
            ),
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 0) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => PlayedHistory()));
        }
      },
    );
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
            playHistory(),
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
  Future<List<EpisodeBrief>> _getRssItem(int top) async {
    var dbHelper = DBHelper();
    List<EpisodeBrief> episodes = await dbHelper.getRecentRssItem(top);
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
