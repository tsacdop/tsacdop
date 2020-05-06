import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';

import '../state/podcast_group.dart';
import '../type/podcastlocal.dart';
import '../local_storage/sqflite_localpodcast.dart';
import '../podcasts/podcastdetail.dart';
import '../util/pageroute.dart';

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
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      titlePadding: EdgeInsets.only(top: 20, left: 20, right: 200, bottom: 20),
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
        systemNavigationBarIconBrightness:
            Theme.of(context).accentColorBrightness,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Podcasts'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Container(
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
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
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
                                  showGeneralDialog(
                                      context: context,
                                      barrierDismissible: true,
                                      barrierLabel:
                                          MaterialLocalizations.of(context)
                                              .modalBarrierDismissLabel,
                                      barrierColor: Colors.black54,
                                      transitionDuration:
                                          const Duration(milliseconds: 200),
                                      pageBuilder: (BuildContext context,
                                              Animation animaiton,
                                              Animation secondaryAnimation) =>
                                          AnnotatedRegion<SystemUiOverlayStyle>(
                                            value: SystemUiOverlayStyle(
                                              statusBarIconBrightness:
                                                  Brightness.light,
                                              systemNavigationBarColor:
                                                  Theme.of(context)
                                                              .brightness ==
                                                          Brightness.light
                                                      ? Color.fromRGBO(
                                                          113, 113, 113, 1)
                                                      : Color.fromRGBO(
                                                          15, 15, 15, 1),
                                            ),
                                            child: AboutPodcast(
                                                podcastLocal:
                                                    snapshot.data[index]),
                                          ));
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
