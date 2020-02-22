import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tsacdop/class/podcastlocal.dart';
import 'package:tsacdop/class/episodebrief.dart';
import 'package:tsacdop/local_storage/sqflite_localpodcast.dart';
import 'package:tsacdop/util/episodegrid.dart';

class PodcastDetail extends StatefulWidget {
  PodcastDetail({Key key, this.podcastLocal}) : super(key: key);
  final PodcastLocal podcastLocal;
  @override
  _PodcastDetailState createState() => _PodcastDetailState();
}

class _PodcastDetailState extends State<PodcastDetail> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Future _updateRssItem(PodcastLocal podcastLocal) async {
    var dbHelper = DBHelper();
    final result = await dbHelper.updatePodcastRss(podcastLocal);
    result == 0
        ? Fluttertoast.showToast(
            msg: 'No Update',
            gravity: ToastGravity.TOP,
          )
        : Fluttertoast.showToast(
            msg: 'Updated $result Episodes',
            gravity: ToastGravity.TOP,
          );
    if (mounted) setState(() {});
  }

  Future<List<EpisodeBrief>> _getRssItem(PodcastLocal podcastLocal) async {
    print(podcastLocal.id);
    var dbHelper = DBHelper();
    List<EpisodeBrief> episodes = await dbHelper.getRssItem(podcastLocal.id);
    return episodes;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
       statusBarIconBrightness: Theme.of(context).accentColorBrightness,
        systemNavigationBarColor: Theme.of(context).primaryColor,
        statusBarColor: Theme.of(context).primaryColor, 
      ),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              widget.podcastLocal.title,
            ),
            centerTitle: true,
          ),
          body: RefreshIndicator(
              key: _refreshIndicatorKey,
              color: Colors.blue[500],
              onRefresh: () => _updateRssItem(widget.podcastLocal),
              child: FutureBuilder<List<EpisodeBrief>>(
                future: _getRssItem(widget.podcastLocal),
                builder: (context, snapshot) {
                  if (snapshot.hasError) print(snapshot.error);
                  return (snapshot.hasData)
                      ? EpisodeGrid(
                          podcast: snapshot.data,
                          showDownload: true,
                          showFavorite: true,
                          showNumber: true,
                          heroTag: 'podcast',
                        )
                      : Center(child: CircularProgressIndicator());
                },
              )),
        ),
      ),
    );
  }
}
