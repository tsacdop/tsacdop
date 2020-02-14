import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:color_thief_flutter/color_thief_flutter.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:fluttertoast/fluttertoast.dart';

import 'package:tsacdop/class/importompl.dart';
import 'package:tsacdop/class/searchpodcast.dart';
import 'package:tsacdop/class/podcastlocal.dart';
import 'package:tsacdop/class/sqflite_localpodcast.dart';
import 'package:tsacdop/home/home.dart';
import 'package:tsacdop/home/appbar/popupmenu.dart';
import 'package:tsacdop/util/pageroute.dart';
import 'package:tsacdop/webfeed/webfeed.dart';
import 'package:tsacdop/home/audiopanel.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _MyHomePageDelegate _delegate = _MyHomePageDelegate();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.grey[100],
          leading: IconButton(
            tooltip: 'Add',
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () async {
              await showSearch<int>(
                context: context,
                delegate: _delegate,
              );
            },
          ),
          title: Image(
            image: AssetImage('assets/text.png'),
            height: 30,
          ),
          actions: <Widget>[
            PopupMenu(),
          ],
        ),
        body: Home(),
    );
  }
}

class _MyHomePageDelegate extends SearchDelegate<int> {
  static Future<List> getList(String searchText) async {
    String url =
        "https://listennotes.p.mashape.com/api/v1/search?only_in=title&q=" +
            searchText +
            "&sort_by_date=0&type=podcast";
    Response response = await Dio().get(url,
        options: Options(headers: {
          'X-Mashape-Key': "UtSwKG4afSmshZfglwsXylLKJZHgp1aZHi2jsnSYK5mZi0A32T",
          'Accept': "application/json"
        }));
    Map searchResultMap = jsonDecode(response.toString());
    var searchResult = SearchPodcast.fromJson(searchResultMap);
    return searchResult.results;
  }

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
          image: AssetImage('assets/listennotes.png'),
          height: 20,
        ),
      ));
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

class _SearchResultState extends State<SearchResult> {
  bool _issubscribe;
  bool _adding;

  @override
  void initState() {
    super.initState();
    _issubscribe = false;
    _adding = false;
  }

  @override
  void dispose() {
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
    ImportOmpl importOmpl = Provider.of<ImportOmpl>(context);

    savePodcast(String rss) async {
      print(rss);
      if (mounted) setState(() => _adding = true);

      importOmpl.importState = ImportState.import;

      Response response = await Dio().get(rss);
      if (mounted) setState(() => _issubscribe = true);

      var _p = RssFeed.parse(response.data);

      print(_p.title);
      var dir = await getApplicationDocumentsDirectory();
      try {
        Response<List<int>> imageResponse = await Dio().get<List<int>>(
            _p.itunes.image.href,
            options: Options(responseType: ResponseType.bytes));

        img.Image image = img.decodeImage(imageResponse.data);
        img.Image thumbnail = img.copyResize(image, width: 300);
        File("${dir.path}/${_p.title}.png")
          ..writeAsBytesSync(img.encodePng(thumbnail));

        String _primaryColor =
            await getColor(File("${dir.path}/${_p.title}.png"));
        PodcastLocal podcastLocal = PodcastLocal(
            _p.title, _p.itunes.image.href, rss, _primaryColor, _p.author);
        podcastLocal.description = _p.description;
        var dbHelper = DBHelper();
        await dbHelper.savePodcastLocal(podcastLocal);

        importOmpl.importState = ImportState.parse;

        await dbHelper.savePodcastRss(_p);

        importOmpl.importState = ImportState.complete;
        importOmpl.importState = ImportState.stop;
        print('fatch data');
      } catch (e) {
        Fluttertoast.showToast(
          msg: 'Network error, Subscribe failed',
          gravity: ToastGravity.BOTTOM,
        );
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0),
      child: ListTile(
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
        subtitle: Text(widget.onlinePodcast.publisher),
        trailing: !_issubscribe
            ? !_adding
                ? OutlineButton(
                    child:
                        Text('Subscribe', style: TextStyle(color: Colors.blue)),
                    onPressed: () {
                      importOmpl.rssTitle = widget.onlinePodcast.title;
                      savePodcast(widget.onlinePodcast.rss);
                    })
                : OutlineButton(
                    child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.blue),
                        )),
                    onPressed: () {},
                  )
            : OutlineButton(child: Text('Subscribe'), onPressed: null),
      ),
    );
  }
}
