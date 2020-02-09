import 'dart:ui';

import 'package:flutter/material.dart';
import 'class/episodebrief.dart';
import 'class/sqflite_localpodcast.dart';
import 'episodegrid.dart';

class MainTab extends StatefulWidget {
  @override
  _MainTabState createState() => _MainTabState();
}

class _MainTabState extends State<MainTab> with TickerProviderStateMixin {
  TabController _controller;
  Decoration getIndicator() {
      return const UnderlineTabIndicator(
        borderSide: BorderSide(color: Colors.red, width: 2),
        insets: EdgeInsets.only(left:20,top:10,)
      );}
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
        Container(
          height: 50,
          alignment: Alignment.centerLeft,
          child: TabBar(
            isScrollable: true,
            labelPadding:
                EdgeInsets.only(bottom:10.0,left: 20.0),
            controller: _controller,
            labelColor: Colors.red,
            unselectedLabelColor: Colors.black,
            indicator: getIndicator(),
            tabs: <Widget>[
              Text('Recent Update',style: TextStyle(fontWeight: FontWeight.bold),), 
              Text('Favorite',style: TextStyle(fontWeight: FontWeight.bold),),
              Text('Dowloads',style: TextStyle(fontWeight: FontWeight.bold),),
              ],
          ),
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
  Future<List<EpisodeBrief>> _getRssItem() async {
    var dbHelper = DBHelper();
    List<EpisodeBrief> episodes = await dbHelper.getRecentRssItem();
    return episodes;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EpisodeBrief>>(
      future: _getRssItem(),
      builder: (context, snapshot) {
        if (snapshot.hasError) print(snapshot.error);
        return (snapshot.hasData)
            ? EpisodeGrid(podcast: snapshot.data, showDownload: false, showFavorite: false, showNumber: false, heroTag: 'recent',) 
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
    List<EpisodeBrief> episodes =await dbHelper.getLikedRssItem();
    return episodes;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EpisodeBrief>>(
      future: _getLikedRssItem(),
      builder: (context, snapshot) {
        if (snapshot.hasError) print(snapshot.error);
        return (snapshot.hasData)
            ? EpisodeGrid(podcast: snapshot.data, showDownload: false, showFavorite: false, showNumber: false, heroTag: 'favorite',) 
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
    List<EpisodeBrief> episodes =await dbHelper.getDownloadedRssItem();
    return episodes;
  }
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EpisodeBrief>>(
      future: _getDownloadedRssItem(),
      builder: (context, snapshot) {
        if (snapshot.hasError) print(snapshot.error);
        return (snapshot.hasData)
            ? EpisodeGrid(podcast: snapshot.data, showDownload: true, showFavorite: false, showNumber: false, heroTag: 'download',)
            : Center(child: CircularProgressIndicator());
      },
    );
  }
}

