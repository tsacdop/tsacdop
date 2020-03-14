import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:html/parser.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:fluttertoast/fluttertoast.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:tsacdop/class/podcastlocal.dart';
import 'package:tsacdop/class/episodebrief.dart';
import 'package:tsacdop/local_storage/sqflite_localpodcast.dart';
import 'package:tsacdop/util/episodegrid.dart';
import 'package:tsacdop/home/audioplayer.dart';
import 'package:tsacdop/class/fireside_data.dart';
import 'package:tsacdop/util/colorize.dart';

class PodcastDetail extends StatefulWidget {
  PodcastDetail({Key key, this.podcastLocal}) : super(key: key);
  final PodcastLocal podcastLocal;
  @override
  _PodcastDetailState createState() => _PodcastDetailState();
}

class _PodcastDetailState extends State<PodcastDetail> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  String backgroundImage;
  List<PodcastHost> hosts;
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
    var dbHelper = DBHelper();
    List<EpisodeBrief> episodes = await dbHelper.getRssItem(podcastLocal.id);
    if (podcastLocal.provider.contains('fireside')) {
      FiresideData data = FiresideData(podcastLocal.id, podcastLocal.link);
      await data.getData();
      backgroundImage = data.background;
      hosts = data.hosts;
    }
    return episodes;
  }

  _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Fluttertoast.showToast(
        msg: '$url Invalid Link',
        gravity: ToastGravity.TOP,
      );
    }
  }

  Widget podcastInfo(BuildContext context) {
    return Container(
      height: 170,
      padding: EdgeInsets.only(top: 40, left: 80, right: 120),
      alignment: Alignment.topLeft,
      child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Text(widget.podcastLocal.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .headline5
                  .copyWith(color: Colors.white))),
    );
  }

  Widget hostsList(BuildContext context, List<PodcastHost> hosts) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        hosts != null
            ? Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        //  colorFilter: ColorFilter.mode(_color, BlendMode.color),
                        image: CachedNetworkImageProvider(
                          backgroundImage,
                        ),
                        fit: BoxFit.cover)),
                alignment: Alignment.centerRight,
                child: Container(
                  color: Theme.of(context)
                      .scaffoldBackgroundColor
                      .withOpacity(0.5),
                  padding: EdgeInsets.symmetric(vertical: 5.0),
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.centerRight,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: hosts
                          .map((host) => Container(
                              padding: EdgeInsets.all(5.0),
                              width: 80.0,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  CircleAvatar(
                                      backgroundColor: Colors.grey[400],
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                        host.image,
                                      )),
                                  Padding(
                                    padding: EdgeInsets.all(2),
                                  ),
                                  Text(
                                    host.name,
                                    style: TextStyle(
                                      backgroundColor:
                                          Colors.black.withOpacity(0.5),
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.fade,
                                  ),
                                ],
                              )))
                          .toList()
                          .cast<Widget>(),
                    ),
                  ),
                ))
            : Center(),
        Padding(padding: EdgeInsets.all(10.0)),
        Container(
          padding: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 10.0),
          alignment: Alignment.topLeft,
          color: Theme.of(context).scaffoldBackgroundColor,
          child: AboutPodcast(podcastLocal: widget.podcastLocal),
        ),
      ],
    );
  }

  double top = 0;

  @override
  Widget build(BuildContext context) {
    
    Color _color = widget.podcastLocal.primaryColor.colorizedark();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Theme.of(context).primaryColor,
        statusBarColor: _color,
      ),
      child: SafeArea(
        child: Scaffold(
            body: RefreshIndicator(
          key: _refreshIndicatorKey,
          color: Theme.of(context).accentColor,
          onRefresh: () => _updateRssItem(widget.podcastLocal),
          child: Stack(
            children: <Widget>[
              FutureBuilder<List<EpisodeBrief>>(
                future: _getRssItem(widget.podcastLocal),
                builder: (context, snapshot) {
                  if (snapshot.hasError) print(snapshot.error);
                  return (snapshot.hasData)
                      ? CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          primary: true,
                          slivers: <Widget>[
                            SliverAppBar(
                              actions: <Widget>[
                                PopupMenuButton<String>(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  elevation: 2,
                                  tooltip: 'Menu',
                                  itemBuilder: (context) => [
                                    widget.podcastLocal.link != null
                                        ? PopupMenuItem(
                                            value: widget.podcastLocal.link,
                                            child: Container(
                                              padding:
                                                  EdgeInsets.only(left: 10),
                                              child: Row(
                                                children: <Widget>[
                                                  Icon(Icons.link,
                                                      color: Theme.of(context)
                                                          .tabBarTheme
                                                          .labelColor),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 5.0),
                                                  ),
                                                  Text('Visit Site'),
                                                ],
                                              ),
                                            ),
                                          )
                                        : Center(),
                                    PopupMenuItem(
                                      value: widget.podcastLocal.rssUrl,
                                      child: Container(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Row(
                                          children: <Widget>[
                                            Icon(
                                              Icons.rss_feed,
                                              color: Theme.of(context)
                                                  .tabBarTheme
                                                  .labelColor,
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 5.0),
                                            ),
                                            Text('View Rss Feed'),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                  onSelected: (url) {
                                    _launchUrl(url);
                                  },
                                )
                              ],
                              elevation: 0,
                              iconTheme: IconThemeData(color: Colors.white),
                              expandedHeight: 170,
                              backgroundColor: _color,
                              floating: true,
                              pinned: true,
                              flexibleSpace: LayoutBuilder(builder:
                                  (BuildContext context,
                                      BoxConstraints constraints) {
                                top = constraints.biggest.height;
                                return FlexibleSpaceBar(
                                  background: Stack(
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(top: 120),
                                        padding: EdgeInsets.only(
                                            left: 80, right: 120),
                                        color: Colors.white10,
                                        alignment: Alignment.centerLeft,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                                widget.podcastLocal.author ??
                                                    '',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                            widget.podcastLocal.provider
                                                    .isNotEmpty
                                                ? Text(
                                                    'Hosted on ' +
                                                        widget.podcastLocal
                                                            .provider,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  )
                                                : Center(),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.centerRight,
                                        padding: EdgeInsets.only(right: 10),
                                        child: SizedBox(
                                          height: 120,
                                          child: Image.file(File(
                                              "${widget.podcastLocal.imagePath}")),
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.center,
                                        child: podcastInfo(context),
                                      ),
                                    ],
                                  ),
                                  title: top < 70
                                      ? Text(widget.podcastLocal.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(color: Colors.white))
                                      : Center(),
                                );
                              }),
                            ),
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (BuildContext context, int index) {
                                  return hostsList(context, hosts);
                                },
                                childCount: 1,
                              ),
                            ),
                            SliverPadding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                sliver: EpisodeGrid(
                                  podcast: snapshot.data,
                                  showDownload: false,
                                  showFavorite: true,
                                  showNumber: true,
                                  heroTag: 'podcast',
                                )),
                          ],
                        )
                      : Center(child: CircularProgressIndicator());
                },
              ),
              Container(child: PlayerWidget()),
            ],
          ),
        )),
      ),
    );
  }
}

class AboutPodcast extends StatefulWidget {
  final PodcastLocal podcastLocal;
  AboutPodcast({this.podcastLocal, Key key}) : super(key: key);

  @override
  _AboutPodcastState createState() => _AboutPodcastState();
}

class _AboutPodcastState extends State<AboutPodcast> {
  String _description;
  bool _load;
  bool _expand;
  void getDescription(String id) async {
    var dbHelper = DBHelper();
    String description = await dbHelper.getFeedDescription(id);
    if (description == null || description.isEmpty) {
      _description = '';
    } else {
      var doc = parse(description);
      _description = parse(doc.body.text).documentElement.text;
    }
    setState(() => _load = true);
  }

  @override
  void initState() {
    super.initState();
    _load = false;
    _expand = false;
    getDescription(widget.podcastLocal.id);
  }

  @override
  Widget build(BuildContext context) {
    return !_load
        ? Center()
        : LayoutBuilder(
            builder: (context, size) {
              final span = TextSpan(text: _description);
              final tp = TextPainter(
                  text: span, maxLines: 3, textDirection: TextDirection.ltr);
              tp.layout(maxWidth: size.maxWidth);

              if (tp.didExceedMaxLines) {
                return GestureDetector(
                  onTap: () {
                    setState(() => _expand = !_expand);
                  },
                  child: !_expand
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              _description,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Container(
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.keyboard_arrow_down,
                              ),
                            ),
                          ],
                        )
                      : Text(_description),
                );
              } else {
                return SelectableText(
                  _description,
                  toolbarOptions: ToolbarOptions(copy: true),
                );
              }
            },
          );
  }
}
