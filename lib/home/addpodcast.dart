import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:color_thief_flutter/color_thief_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../type/searchpodcast.dart';
import '../state/subscribe_podcast.dart';
import '../util/context_extension.dart';
import '../webfeed/webfeed.dart';
import '../.env.dart';

class MyHomePageDelegate extends SearchDelegate<int> {
  final String searchFieldLabel;
  MyHomePageDelegate({this.searchFieldLabel})
      : super(searchFieldLabel: searchFieldLabel);
  static Future<List> getList(String searchText) async {
    String apiKey = environment['apiKey'];
    String url =
        "https://listennotes.p.rapidapi.com/api/v1/search?only_in=title%2Cdescription&q=" +
            searchText +
            "&sort_by_date=0&type=podcast";
    Response response = await Dio().get(url,
        options: Options(headers: {
          'X-Mashape-Key': "$apiKey",
          'Accept': "application/json"
        }));
    Map searchResultMap = jsonDecode(response.toString());
    var searchResult = SearchPodcast.fromJson(searchResultMap);
    return searchResult.results;
  }

  static Future getRss(String url) async {
    try {
      BaseOptions options = new BaseOptions(
        connectTimeout: 10000,
        receiveTimeout: 10000,
      );
      Response response = await Dio(options).get(url);
      var p = RssFeed.parse(response.data);
      return OnlinePodcast(
          rss: url,
          title: p.title,
          publisher: p.author,
          description: p.description,
          image: p.itunes.image.href);
    } catch (e) {
      throw e;
    }
  }

  RegExp rssExp = RegExp(r'^(https?):\/\/(.*)');
  Widget invalidRss() => Container(
        height: 50,
        alignment: Alignment.center,
        child: Text('Invalid rss link'),
      );

  @override
  ThemeData appBarTheme(BuildContext context) => Theme.of(context);

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, 1);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty)
      return Center(
          child: Container(
        padding: EdgeInsets.only(top: 400),
        child: Image(
          image: Theme.of(context).brightness == Brightness.light
              ? AssetImage('assets/listennotes.png')
              : AssetImage('assets/listennotes_light.png'),
          height: 20,
        ),
      ));
    else if (rssExp.stringMatch(query) != null)
      return FutureBuilder(
        future: getRss(rssExp.stringMatch(query)),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return invalidRss();
          else if (snapshot.hasData)
            return SearchResult(
              onlinePodcast: snapshot.data,
            );
          else
            return Container(
              padding: EdgeInsets.only(top: 200),
              alignment: Alignment.topCenter,
              child: CircularProgressIndicator(),
            );
        },
      );
    else
      return FutureBuilder(
        future: getList(query),
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          if (!snapshot.hasData && query != null)
            return Container(
              padding: EdgeInsets.only(top: 200),
              alignment: Alignment.topCenter,
              child: CircularProgressIndicator(),
            );
          List content = snapshot.data;
          return ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: content.length,
            itemBuilder: (BuildContext context, int index) {
              return SearchResult(
                onlinePodcast: content[index],
              );
            },
          );
        },
      );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      if (query.isEmpty)
        Center()
      else
        IconButton(
          tooltip: 'Clear',
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty)
      return Container(
        height: 10,
        width: 10,
        margin: EdgeInsets.only(top: 400),
        child: SizedBox(
          height: 10,
          child: Image.asset(
            'assets/listennote.png',
            fit: BoxFit.fill,
          ),
        ),
      );
    else if (rssExp.stringMatch(query) != null)
      return FutureBuilder(
        future: getRss(rssExp.stringMatch(query)),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return invalidRss();
          else if (snapshot.hasData)
            return SearchResult(
              onlinePodcast: snapshot.data,
            );
          else
            return Container(
              padding: EdgeInsets.only(top: 200),
              alignment: Alignment.topCenter,
              child: CircularProgressIndicator(),
            );
        },
      );
    else
      return FutureBuilder(
        future: getList(query),
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          if (!snapshot.hasData && query != null)
            return Container(
              padding: EdgeInsets.only(top: 200),
              alignment: Alignment.topCenter,
              child: CircularProgressIndicator(),
            );
          List content = snapshot.data;
          return ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: content.length,
            itemBuilder: (BuildContext context, int index) {
              return SearchResult(
                onlinePodcast: content[index],
              );
            },
          );
        },
      );
  }
}

class SearchResult extends StatefulWidget {
  final OnlinePodcast onlinePodcast;
  SearchResult({this.onlinePodcast, Key key}) : super(key: key);
  @override
  _SearchResultState createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult>
    with SingleTickerProviderStateMixin {
  bool _issubscribe;
  bool _showDes;
  AnimationController _controller;
  Animation _animation;
  double _value;
  @override
  void initState() {
    super.initState();
    _issubscribe = false;
    _showDes = false;
    _value = 0;
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {
          _value = _animation.value;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<String> getColor(File file) async {
    final imageProvider = FileImage(file);
    var colorImage = await getImageFromProvider(imageProvider);
    var color = await getColorFromImage(colorImage);
    String primaryColor = color.toString();
    return primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    // var importOmpl = Provider.of<ImportOmpl>(context, listen: false);
    // var groupList = Provider.of<GroupList>(context, listen: false);
    var subscribeWorker = Provider.of<SubscribeWorker>(context, listen: false);

    savePodcast(OnlinePodcast podcast) async {
      SubscribeItem item = SubscribeItem(podcast.rss, podcast.title, imgUrl: podcast.image);
      subscribeWorker.setSubscribeItem(item);
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: Divider.createBorderSide(context),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
            onTap: () {
              setState(() {
                _showDes = !_showDes;
                if (_value == 0)
                  _controller.forward();
                else
                  _controller.reverse();
              });
            },
            leading: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              child: Image.network(
                widget.onlinePodcast.image,
                height: 40.0,
                width: 40.0,
                fit: BoxFit.fitWidth,
                alignment: Alignment.center,
              ),
            ),
            title: Text(widget.onlinePodcast.title),
            subtitle: Text(widget.onlinePodcast.publisher ?? ''),
            trailing: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Transform.rotate(
                  angle: math.pi * _value,
                  child: Icon(Icons.keyboard_arrow_down),
                ),
                Padding(padding: EdgeInsets.only(right: 10.0)),
                Container(
                  width: 100,
                  height: 35,
                  child: !_issubscribe
                      ? OutlineButton(
                          highlightedBorderColor: Theme.of(context).accentColor,
                          splashColor:
                              Theme.of(context).accentColor.withOpacity(0.8),
                          child: Text('Subscribe',
                              style: TextStyle(
                                  color: Theme.of(context).accentColor)),
                          onPressed: () {
                            savePodcast(widget.onlinePodcast);
                            setState(() => _issubscribe = true);
                            Fluttertoast.showToast(
                              msg: 'Podcast subscribed',
                              gravity: ToastGravity.BOTTOM,
                            );
                          })
                      : OutlineButton(
                          color: context.accentColor.withOpacity(0.8),
                          highlightedBorderColor: Colors.grey[500],
                          disabledTextColor: Colors.grey[500],
                          child: Text('Subscribe'),
                          disabledBorderColor: Colors.grey[500],
                          onPressed: () {}),
                ),
              ],
            ),
          ),
          _showDes
              ? Container(
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                      color: Theme.of(context).accentColor,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(15.0),
                        bottomLeft: Radius.circular(15.0),
                        bottomRight: Radius.circular(15.0),
                      )),
                  margin: EdgeInsets.only(left: 70, right: 50, bottom: 10.0),
                  padding: EdgeInsets.all(15.0),
                  child: Text(
                    widget.onlinePodcast.description.trim(),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        .copyWith(color: Colors.white),
                  ),
                )
              : Center(),
        ],
      ),
    );
  }
}
