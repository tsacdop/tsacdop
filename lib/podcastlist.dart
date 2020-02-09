import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'class/podcastlocal.dart';
import 'class/sqflite_localpodcast.dart';
import 'podcastdetail.dart';

Future<List<PodcastLocal>> getPodcastLocal() async {
  var dbHelper = DBHelper();
  Future<List<PodcastLocal>> podcastList = dbHelper.getPodcastLocal();
  return podcastList;
}

class AboutPodcast extends StatefulWidget {
  final PodcastLocal podcastLocal;
  AboutPodcast({this.podcastLocal, Key key}) : super(key: key);

  @override
  _AboutPodcastState createState() => _AboutPodcastState();
}

class _AboutPodcastState extends State<AboutPodcast> {
  void _unSubscribe(String t) async {
    var dbHelper = DBHelper();
    dbHelper.delPodcastLocal(t);
    print('Unsubscribe');
  }

  String _description;
  bool _load;

  void getDescription(String title) async {
    var dbHelper = DBHelper();
    String description = await dbHelper.getFeedDescription(title);
    _description = description;
    setState(() {
      _load = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _load = false;
    getDescription(widget.podcastLocal.title);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: <Widget>[
        FlatButton(
          padding: EdgeInsets.all(10.0),
          onPressed: () {
            _unSubscribe(widget.podcastLocal.title);
            Navigator.of(context).pop();
          },
          color: Colors.grey[200],
          textColor: Colors.red,
          child: Text(
            'UNSUBSCRIBE',
          ),
        ),
      ],
      title: Text(widget.podcastLocal.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          !_load
              ? Center()
              : _description != null ? Text(_description) : Center(),
          (widget.podcastLocal.author != null)
              ? Text(widget.podcastLocal.author,
                  style: TextStyle(color: Colors.blue))
              : Center(),
        ],
      ),
    );
  }
}

class PodcastList extends StatefulWidget {
  @override
  _PodcastListState createState() => _PodcastListState();
}

class _PodcastListState extends State<PodcastList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: FutureBuilder<List<PodcastLocal>>(
        future: getPodcastLocal(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return CustomScrollView(
              primary: false,
              slivers: <Widget>[
                SliverPadding(
                  padding: const EdgeInsets.all(10.0),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 0.8,
                      crossAxisCount: 3,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PodcastDetail(
                                        podcastLocal: snapshot.data[index],
                                      )),
                            );
                          },
                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) => AboutPodcast(
                                  podcastLocal: snapshot.data[index]),
                            ).then((_) => setState(() {}));
                          },
                          child: Container(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  height: 10.0,
                                ),
                                ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(60.0)),
                                  child: Container(
                                    height: 120.0,
                                    width: 120.0,
                                    child: CachedNetworkImage(
                                      imageUrl: snapshot.data[index].imageUrl,
                                      placeholder: (context, url) =>
                                          CircularProgressIndicator(),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(4.0),
                                  child: Text(
                                    snapshot.data[index].title,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: snapshot.data.length,
                    ),
                  ),
                ),
              ],
            );
          }
          return Text('NoData');
        },
      ),
    );
  }
}

class Podcast extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        title: Text('Podcasts'),
      ),
      body: Container(child: PodcastList()),
    );
  }
}
