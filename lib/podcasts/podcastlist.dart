import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:tsacdop/class/podcast_group.dart';

import 'package:tsacdop/class/podcastlocal.dart';
import 'package:tsacdop/local_storage/sqflite_localpodcast.dart';
import 'package:tsacdop/podcasts/podcastdetail.dart';
import 'package:tsacdop/util/pageroute.dart';

class AboutPodcast extends StatefulWidget {
  final PodcastLocal podcastLocal;
  AboutPodcast({this.podcastLocal, Key key}) : super(key: key);

  @override
  _AboutPodcastState createState() => _AboutPodcastState();
}

class _AboutPodcastState extends State<AboutPodcast> {
  String _description;
  bool _load;

  void getDescription(String id) async {
    var dbHelper = DBHelper();
    String description = await dbHelper.getFeedDescription(id);
    _description = description;
    setState(() {
      _load = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _load = false;
    getDescription(widget.podcastLocal.id);
  }

  @override
  Widget build(BuildContext context) {
    var _groupList = Provider.of<GroupList>(context, listen: false);
    return AlertDialog(
      actions: <Widget>[
        FlatButton(
          padding: EdgeInsets.all(10.0),
          onPressed: () {
            _groupList.removePodcast(widget.podcastLocal.id);
            Navigator.of(context).pop();
          },
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
              : _description != null ? Html(data: _description) : Center(),
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
  Future<List<PodcastLocal>> getPodcastLocal() async {
    var dbHelper = DBHelper();
    var podcastList = await dbHelper.getPodcastLocalAll();
    return podcastList;
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Theme.of(context).accentColorBrightness,
        systemNavigationBarColor: Theme.of(context).primaryColor,
        statusBarColor: Theme.of(context).primaryColor,
      ),
      child: SafeArea(
              child: Scaffold(
          appBar: AppBar(
            title: Text('Podcasts'),
            centerTitle: true,
          ),
          body: Container(
            color: Theme.of(context).primaryColor,
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
                                    ScaleRoute(
                                        page: PodcastDetail(
                                      podcastLocal: snapshot.data[index],
                                    )),
                                  );
                                },
                                onLongPress: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AboutPodcast(
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
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(_width / 8)),
                                        child: Container(
                                          height: _width / 4,
                                          width: _width / 4,
                                          child: Image.file(File(
                                              "${snapshot.data[index].imagePath}")),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(4.0),
                                        child: Text(
                                          snapshot.data[index].title,
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1,
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
          ),
        ),
      ),
    );
  }
}
