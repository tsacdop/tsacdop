import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';

import '../local_storage/sqflite_localpodcast.dart';
import '../state/podcast_group.dart';
import '../type/podcastlocal.dart';
import '../util/extension_helper.dart';
import '../util/general_dialog.dart';
import '../util/pageroute.dart';
import 'podcast_detail.dart';
import 'podcast_settings.dart';

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
    var description = await dbHelper.getFeedDescription(id);
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
    final s = context.s;
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      titlePadding: EdgeInsets.only(
          top: 20, left: 20, right: context.width / 3, bottom: 20),
      actions: <Widget>[
        FlatButton(
          splashColor: context.accentColor.withAlpha(70),
          padding: EdgeInsets.all(10.0),
          onPressed: () {
            _groupList.removePodcast(widget.podcastLocal.id);
            Navigator.of(context).pop();
          },
          textColor: Colors.red,
          child: Text(
            s.remove,
          ),
        ),
      ],
      title: Text(widget.podcastLocal.title),
      content: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            !_load
                ? Center()
                : _description != null ? Html(data: _description) : Center(),
            if (widget.podcastLocal.author != null)
              Text(widget.podcastLocal.author,
                  style: TextStyle(color: Colors.blue))
          ],
        ),
      ),
    );
  }
}

class PodcastList extends StatefulWidget {
  @override
  _PodcastListState createState() => _PodcastListState();
}

class _PodcastListState extends State<PodcastList> {
  Future<List<PodcastLocal>> _getPodcastLocal() async {
    var dbHelper = DBHelper();
    var podcastList = await dbHelper.getPodcastLocalAll();
    return podcastList;
  }

  @override
  Widget build(BuildContext context) {
    final width = context.width;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Theme.of(context).accentColorBrightness,
        systemNavigationBarColor: context.primaryColor,
        systemNavigationBarIconBrightness:
            Theme.of(context).accentColorBrightness,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.s.podcast(2)),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Container(
            color: context.primaryColor,
            child: FutureBuilder<List<PodcastLocal>>(
              future: _getPodcastLocal(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return CustomScrollView(
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
                            (context, index) {
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
                                onLongPress: () async {
                                  generalSheet(
                                    context,
                                    title: snapshot.data[index].title,
                                    child: PodcastSetting(
                                        podcastLocal: snapshot.data[index]),
                                  ).then((value) {
                                    if (mounted) setState(() {});
                                  });
                                },
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(width / 8),
                                        child: Container(
                                          height: width / 4,
                                          width: width / 4,
                                          child: Image.file(File(
                                              "${snapshot.data[index].imagePath}")),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text(
                                          snapshot.data[index].title,
                                          textAlign: TextAlign.center,
                                          style: context.textTheme.bodyText1,
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
                return Center(
                  child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator()),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
