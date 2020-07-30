import 'dart:async';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:webfeed/webfeed.dart';
import 'package:provider/provider.dart';

import '../service/api_search.dart';
import '../state/podcast_group.dart';
import '../type/searchepisodes.dart';
import '../type/searchpodcast.dart';
import '../util/extension_helper.dart';

class MyHomePageDelegate extends SearchDelegate<int> {
  final String searchFieldLabel;

  MyHomePageDelegate({this.searchFieldLabel})
      : super(
          searchFieldLabel: searchFieldLabel,
        );

  static Future getRss(String url) async {
    try {
      var options = BaseOptions(
        connectTimeout: 10000,
        receiveTimeout: 10000,
      );
      var response = await Dio(options).get(url);
      return RssFeed.parse(response.data);
    } catch (e) {
      rethrow;
    }
  }

  RegExp rssExp = RegExp(r'^(https?):\/\/(.*)');
  Widget invalidRss(BuildContext context) => Container(
        height: 50,
        alignment: Alignment.center,
        child: Text(context.s.searchInvalidRss),
      );

  @override
  ThemeData appBarTheme(BuildContext context) => Theme.of(context);

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: context.s.back,
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
    return Center(
        child: Container(
      padding: EdgeInsets.only(top: 100),
      child: Image(
        image: context.brightness == Brightness.light
            ? AssetImage('assets/listennotes.png')
            : AssetImage('assets/listennotes_light.png'),
        height: 20,
      ),
    ));
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      if (query.isEmpty)
        Center()
      else
        IconButton(
          tooltip: context.s.clear,
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
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
    } else if (rssExp.stringMatch(query) != null) {
      return FutureBuilder(
        future: getRss(rssExp.stringMatch(query)),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return invalidRss(context);
          } else if (snapshot.hasData) {
            return RssResult(
              url: rssExp.stringMatch(query),
              rssFeed: snapshot.data,
            );
          } else {
            return Container(
              padding: EdgeInsets.only(top: 200),
              alignment: Alignment.topCenter,
              child: CircularProgressIndicator(),
            );
          }
        },
      );
    } else {
      return SearchList(
        query: query,
      );
    }
  }
}

class RssResult extends StatefulWidget {
  RssResult({this.url, this.rssFeed, Key key}) : super(key: key);
  final RssFeed rssFeed;
  final String url;
  @override
  _RssResultState createState() => _RssResultState();
}

class _RssResultState extends State<RssResult> {
  OnlinePodcast _onlinePodcast;
  bool _isSubscribed = false;
  int _loadItems;

  @override
  void initState() {
    var p = widget.rssFeed;
    _loadItems = 10;
    _onlinePodcast = OnlinePodcast(
        rss: widget.url,
        title: p.title,
        publisher: p.author,
        description: p.description,
        image: p.itunes.image.href,
        count: p.items.length);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var subscribeWorker = Provider.of<GroupList>(context, listen: false);
    final s = context.s;
    _subscribePodcast(OnlinePodcast podcast) {
      var item = SubscribeItem(podcast.rss, podcast.title,
          imgUrl: podcast.image, group: 'Home');
      subscribeWorker.setSubscribeItem(item);
    }

    var items = widget.rssFeed.items;
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: 140,
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(_onlinePodcast.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.textTheme.headline5),
                            ),
                            !_isSubscribed
                                ? OutlineButton(
                                    highlightedBorderColor: context.accentColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                        side: BorderSide(
                                            color: context.accentColor)),
                                    splashColor:
                                        context.accentColor.withOpacity(0.5),
                                    child: Text(s.subscribe,
                                        style: TextStyle(
                                            color: context.accentColor)),
                                    onPressed: () {
                                      _subscribePodcast(_onlinePodcast);
                                      setState(() {
                                        _isSubscribed = true;
                                      });
                                      Fluttertoast.showToast(
                                        msg: s.podcastSubscribed,
                                        gravity: ToastGravity.BOTTOM,
                                      );
                                    })
                                : OutlineButton(
                                    color: context.accentColor.withOpacity(0.5),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                        side: BorderSide(
                                            color: Colors.grey[500])),
                                    highlightedBorderColor: Colors.grey[500],
                                    disabledTextColor: Colors.grey[500],
                                    child: Text(s.subscribe),
                                    disabledBorderColor: Colors.grey[500],
                                    onPressed: () {})
                          ],
                        ),
                      ),
                    ),
                    CachedNetworkImage(
                      height: 120.0,
                      width: 120.0,
                      fit: BoxFit.fitWidth,
                      alignment: Alignment.center,
                      imageUrl: _onlinePodcast.image,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) => Container(
                        height: 120,
                        width: 120,
                        alignment: Alignment.center,
                        color: context.primaryColorDark,
                        child: SizedBox(
                          width: 40,
                          height: 2,
                          child: LinearProgressIndicator(
                              value: downloadProgress.progress),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                          width: 120,
                          height: 120,
                          alignment: Alignment.center,
                          color: context.primaryColorDark,
                          child: Icon(Icons.error)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Container(
                height: 50,
                color: context.scaffoldBackgroundColor,
                child: TabBar(
                    indicatorColor: context.accentColor,
                    labelColor: context.textColor,
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: [
                      Text(s.homeToprightMenuAbout),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(s.episode(2)),
                          SizedBox(width: 2),
                          Container(
                              padding: const EdgeInsets.only(
                                  left: 5, right: 5, top: 2, bottom: 2),
                              decoration: BoxDecoration(
                                  color: context.accentColor,
                                  borderRadius: BorderRadius.circular(100)),
                              child: Text(_onlinePodcast.count.toString(),
                                  style: TextStyle(color: Colors.white)))
                        ],
                      )
                    ]),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(children: [
              ListView(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Html(
                      onLinkTap: (url) {
                        url.launchUrl;
                      },
                      linkStyle: TextStyle(
                          color: context.accentColor,
                          // decoration: TextDecoration.underline,
                          textBaseline: TextBaseline.ideographic),
                      shrinkToFit: true,
                      data: _onlinePodcast.description,
                      padding:
                          EdgeInsets.only(left: 20.0, right: 20, bottom: 20),
                      defaultTextStyle: TextStyle(
                        height: 1.8,
                      ),
                    ),
                  ),
                ],
              ),
              ListView.builder(
                  itemCount: math.min(_loadItems + 1, items.length),
                  itemBuilder: (context, index) {
                    if (index == _loadItems) {
                      return Container(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 100,
                          child: OutlineButton(
                            highlightedBorderColor: context.accentColor,
                            splashColor: context.accentColor.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(100))),
                            child: Text(context.s.loadMore),
                            onPressed: () => setState(
                              () => _loadItems += 10,
                            ),
                          ),
                        ),
                      );
                    }
                    return ListTile(
                      title: Text(items[index].title),
                      subtitle: Text('${items[index].pubDate}',
                          style: TextStyle(color: context.accentColor)),
                    );
                  })
            ]),
          )
        ],
      ),
    );
  }
}

class SearchList extends StatefulWidget {
  final String query;
  SearchList({this.query, Key key}) : super(key: key);

  @override
  _SearchListState createState() => _SearchListState();
}

class _SearchListState extends State<SearchList> {
  int _nextOffset = 0;
  final List<OnlinePodcast> _podcastList = [];
  int _offset;
  bool _loading;
  OnlinePodcast _selectedPodcast;
  Future _searchFuture;
  final List<OnlinePodcast> _subscribed = [];
  @override
  void initState() {
    super.initState();
    _searchFuture = _getList(widget.query, _nextOffset);
  }

  Future<List<OnlinePodcast>> _getList(
      String searchText, int nextOffset) async {
    var searchEngine = SearchEngine();
    var searchResult = await searchEngine.searchPodcasts(
        searchText: searchText, nextOffset: nextOffset);
    _offset = searchResult.nextOffset;
    _podcastList.addAll(searchResult.results.cast());
    _loading = false;
    return _podcastList;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        FutureBuilder<List>(
          future: _searchFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData && widget.query != null) {
              return Container(
                padding: EdgeInsets.only(top: 200),
                alignment: Alignment.topCenter,
                child: CircularProgressIndicator(),
              );
            }
            var content = snapshot.data;
            return CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return SearchResult(
                        onlinePodcast: content[index],
                        isSubscribed: _subscribed.contains(content[index]),
                        onSelect: (onlinePodcast) {
                          setState(() {
                            _selectedPodcast = onlinePodcast;
                          });
                        },
                        onSubscribe: (onlinePodcast) {
                          setState(() {
                            _subscribed.add(onlinePodcast);
                          });
                        },
                      );
                    },
                    childCount: content.length,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                        child: SizedBox(
                          height: 30,
                          child: OutlineButton(
                            highlightedBorderColor: context.accentColor,
                            splashColor: context.accentColor.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(100))),
                            child: _loading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ))
                                : Text(context.s.loadMore),
                            onPressed: () => _loading
                                ? null
                                : setState(
                                    () {
                                      _loading = true;
                                      _nextOffset = _offset;
                                      _searchFuture =
                                          _getList(widget.query, _nextOffset);
                                    },
                                  ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            );
          },
        ),
        if (_selectedPodcast != null)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPodcast = null),
              child: Container(
                color: context.scaffoldBackgroundColor.withOpacity(0.9),
              ),
            ),
          ),
        if (_selectedPodcast != null)
          LayoutBuilder(
            builder: (context, constrants) => SearchResultDetail(
              _selectedPodcast,
              maxHeight: constrants.maxHeight,
              onClose: (option) {
                setState(() => _selectedPodcast = null);
              },
              onSubscribe: (onlinePodcast) {
                setState(() {
                  _subscribed.add(onlinePodcast);
                });
              },
            ),
          ),
      ],
    );
  }
}

class SearchResult extends StatelessWidget {
  final OnlinePodcast onlinePodcast;
  final ValueChanged<OnlinePodcast> onSelect;
  final ValueChanged<OnlinePodcast> onSubscribe;
  final bool isSubscribed;
  SearchResult(
      {this.onlinePodcast,
      this.onSelect,
      this.onSubscribe,
      this.isSubscribed,
      Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var subscribeWorker = Provider.of<GroupList>(context, listen: false);
    final s = context.s;
    subscribePodcast(OnlinePodcast podcast) {
      var item = SubscribeItem(podcast.rss, podcast.title,
          imgUrl: podcast.image, group: 'Home');
      subscribeWorker.setSubscribeItem(item);
      onSubscribe(podcast);
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
              onSelect(onlinePodcast);
            },
            leading: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              child: CachedNetworkImage(
                height: 40.0,
                width: 40.0,
                fit: BoxFit.fitWidth,
                alignment: Alignment.center,
                imageUrl: onlinePodcast.image,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    Container(
                  height: 40,
                  width: 40,
                  alignment: Alignment.center,
                  color: context.primaryColorDark,
                  child: SizedBox(
                    width: 20,
                    height: 2,
                    child: LinearProgressIndicator(
                        value: downloadProgress.progress),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    color: context.primaryColorDark,
                    child: Icon(Icons.error)),
              ),
            ),
            title: Text(onlinePodcast.title),
            subtitle: Text(onlinePodcast.publisher ?? ''),
            trailing: !isSubscribed
                ? OutlineButton(
                    highlightedBorderColor: context.accentColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100.0),
                        side: BorderSide(color: context.accentColor)),
                    splashColor: context.accentColor.withOpacity(0.5),
                    child: Text(s.subscribe,
                        style: TextStyle(color: context.accentColor)),
                    onPressed: () {
                      subscribePodcast(onlinePodcast);
                      Fluttertoast.showToast(
                        msg: s.podcastSubscribed,
                        gravity: ToastGravity.BOTTOM,
                      );
                    })
                : OutlineButton(
                    color: context.accentColor.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100.0),
                        side: BorderSide(color: Colors.grey[500])),
                    highlightedBorderColor: Colors.grey[500],
                    disabledTextColor: Colors.grey[500],
                    child: Text(s.subscribe),
                    disabledBorderColor: Colors.grey[500],
                    onPressed: () {}),
          ),
        ],
      ),
    );
  }
}

class SearchResultDetail extends StatefulWidget {
  SearchResultDetail(this.onlinePodcast,
      {this.onClose,
      this.maxHeight,
      this.onSubscribe,
      this.episodeList,
      Key key})
      : super(key: key);
  final OnlinePodcast onlinePodcast;
  final ValueChanged<bool> onClose;
  final ValueChanged<OnlinePodcast> onSubscribe;
  final double maxHeight;
  final List<OnlineEpisode> episodeList;
  @override
  _SearchResultDetailState createState() => _SearchResultDetailState();
}

enum SlideDirection { up, down }

class _SearchResultDetailState extends State<SearchResultDetail>
    with SingleTickerProviderStateMixin {
  /// Animation value.
  double _initSize;

  /// Gesture tap start position.
  double _startdy;

  /// Height of first open.
  double _minHeight;

  /// Gesture move.
  double _move = 0;

  AnimationController _controller;
  Animation _animation;

  /// Gesture scroll direction.
  SlideDirection _slideDirection;

  /// Search offset.
  int _nextEpisdoeDate = DateTime.now().millisecondsSinceEpoch;

  /// Search result.
  final List<OnlineEpisode> _episodeList = [];

  Future _searchFuture;

  /// Subscribe indicator.
  bool _isSubscribed = false;

  /// Episodes list load more.
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _searchFuture = _getEpisodes(
        id: widget.onlinePodcast.id, nextEpisodeDate: _nextEpisdoeDate);
    _minHeight = widget.maxHeight / 2;
    _initSize = _minHeight;
    _slideDirection = SlideDirection.up;
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200))
          ..addListener(() {
            if (mounted) setState(() {});
          });
    _animation =
        Tween<double>(begin: 170, end: _minHeight).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<List<OnlineEpisode>> _getEpisodes(
      {String id, int nextEpisodeDate}) async {
    var searchEngine = SearchEngine();
    var searchResult = await searchEngine.fetchEpisode(
        id: id, nextEpisodeDate: nextEpisodeDate);
    _nextEpisdoeDate = searchResult.nextEpisodeDate;
    _episodeList.addAll(searchResult.episodes.cast());
    _loading = false;
    return _episodeList;
  }

  _start(DragStartDetails event) {
    setState(() {
      _startdy = event.localPosition.dy;
      _animation =
          Tween<double>(begin: _initSize, end: _initSize).animate(_controller);
    });
    _controller.forward();
  }

  _update(DragUpdateDetails event) {
    setState(() {
      _move = _startdy - event.localPosition.dy;
      _animation = Tween<double>(begin: _initSize, end: _initSize + _move)
          .animate(_controller);
      _slideDirection = _move > 0 ? SlideDirection.up : SlideDirection.down;
    });
    _controller.forward();
  }

  _end() {
    if (_slideDirection == SlideDirection.up) {
      if (_move > 20) {
        setState(() {
          _animation =
              Tween<double>(begin: _animation.value, end: widget.maxHeight)
                  .animate(_controller);
          _initSize = widget.maxHeight;
        });
        _controller.forward();
      } else {
        setState(() {
          _animation = Tween<double>(begin: _animation.value, end: _minHeight)
              .animate(_controller);
          _initSize = _minHeight;
        });
        _controller.forward();
      }
    } else if (_slideDirection == SlideDirection.down) {
      if (_move > -50) {
        setState(() {
          _animation = Tween<double>(
                  begin: _animation.value,
                  end: _animation.value > _minHeight
                      ? widget.maxHeight
                      : _minHeight)
              .animate(_controller);
          _initSize =
              _animation.value > _minHeight ? widget.maxHeight : _minHeight;
        });
        _controller.forward();
      } else {
        setState(() {
          _animation = Tween<double>(
                  begin: _animation.value,
                  end: _animation.value > _minHeight - 50 ? _minHeight : 1)
              .animate(_controller);
          _initSize = _animation.value > _minHeight - 50 ? _minHeight : 100;
        });
        _controller.forward();
        if (_animation.value < _minHeight - 50) widget.onClose(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var subscribeWorker = Provider.of<GroupList>(context, listen: false);
    final s = context.s;
    subscribePodcast(OnlinePodcast podcast) {
      var item = SubscribeItem(podcast.rss, podcast.title,
          imgUrl: podcast.image, group: 'Home');
      subscribeWorker.setSubscribeItem(item);
      widget.onSubscribe(podcast);
    }

    return GestureDetector(
      onVerticalDragStart: _start,
      onVerticalDragUpdate: _update,
      onVerticalDragEnd: (event) => _end(),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          boxShadow: [
            BoxShadow(
              offset: Offset(0, -0.5),
              blurRadius: 1,
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.grey[400].withOpacity(0.5)
                  : Colors.grey[800],
            ),
          ],
        ),
        height: _animation.value,
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              SizedBox(
                height: math.min(_animation.value, 120),
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: SizedBox(
                    height: 120,
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(widget.onlinePodcast.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.textTheme.headline5),
                                ),
                                Text(
                                  '${widget.onlinePodcast.interval.toInterval(context)} | '
                                  '${widget.onlinePodcast.latestPubDate.toDate(context)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.fade,
                                  style: TextStyle(color: context.accentColor),
                                ),
                                !_isSubscribed
                                    ? OutlineButton(
                                        highlightedBorderColor:
                                            context.accentColor,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(100.0),
                                            side: BorderSide(
                                                color: context.accentColor)),
                                        splashColor: context.accentColor
                                            .withOpacity(0.5),
                                        child: Text(s.subscribe,
                                            style: TextStyle(
                                                color: context.accentColor)),
                                        onPressed: () {
                                          subscribePodcast(
                                              widget.onlinePodcast);
                                          setState(() {
                                            _isSubscribed = true;
                                          });
                                          Fluttertoast.showToast(
                                            msg: s.podcastSubscribed,
                                            gravity: ToastGravity.BOTTOM,
                                          );
                                        })
                                    : OutlineButton(
                                        color: context.accentColor
                                            .withOpacity(0.5),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(100.0),
                                            side: BorderSide(
                                                color: Colors.grey[500])),
                                        highlightedBorderColor:
                                            Colors.grey[500],
                                        disabledTextColor: Colors.grey[500],
                                        child: Text(s.subscribe),
                                        disabledBorderColor: Colors.grey[500],
                                        onPressed: () {})
                              ],
                            ),
                          ),
                        ),
                        CachedNetworkImage(
                          height: 120.0,
                          width: 120.0,
                          fit: BoxFit.fitWidth,
                          alignment: Alignment.center,
                          imageUrl: widget.onlinePodcast.image,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) => Container(
                            height: 120,
                            width: 120,
                            alignment: Alignment.center,
                            color: context.primaryColorDark,
                            child: SizedBox(
                              width: 40,
                              height: 2,
                              child: LinearProgressIndicator(
                                  value: downloadProgress.progress),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                              width: 120,
                              height: 120,
                              alignment: Alignment.center,
                              color: context.primaryColorDark,
                              child: Icon(Icons.error)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_animation.value > 120)
                SizedBox(
                  height: math.min(_animation.value - 120, 50),
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: SizedBox(
                      height: 50,
                      child: TabBar(
                          indicatorColor: context.accentColor,
                          labelColor: context.textColor,
                          indicatorWeight: 3,
                          indicatorSize: TabBarIndicatorSize.label,
                          tabs: [
                            Text(s.homeToprightMenuAbout),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(s.episode(2)),
                                SizedBox(width: 2),
                                Container(
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 5, top: 2, bottom: 2),
                                    decoration: BoxDecoration(
                                        color: context.accentColor,
                                        borderRadius:
                                            BorderRadius.circular(100)),
                                    child: Text(
                                        widget.onlinePodcast.count.toString(),
                                        style: TextStyle(color: Colors.white)))
                              ],
                            )
                          ]),
                    ),
                  ),
                ),
              Expanded(
                child: TabBarView(children: [
                  ListView(
                    physics: _animation.value != widget.maxHeight
                        ? NeverScrollableScrollPhysics()
                        : null,
                    children: [
                      Html(
                        onLinkTap: (url) {
                          url.launchUrl;
                        },
                        linkStyle: TextStyle(
                            color: context.accentColor,
                            textBaseline: TextBaseline.ideographic),
                        shrinkToFit: true,
                        data: widget.onlinePodcast.description,
                        padding: const EdgeInsets.only(
                            left: 20.0, right: 20, bottom: 20),
                        defaultTextStyle: TextStyle(
                          height: 1.8,
                        ),
                      ),
                    ],
                  ),
                  FutureBuilder<List<OnlineEpisode>>(
                      future: _searchFuture,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          var content = snapshot.data;
                          return ListView.builder(
                            physics: _animation.value != widget.maxHeight
                                ? NeverScrollableScrollPhysics()
                                : null,
                            itemCount: content.length + 1,
                            itemBuilder: (context, index) {
                              if (index == content.length) {
                                return Container(
                                  padding: const EdgeInsets.only(
                                      top: 10.0, bottom: 20.0),
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    width: 100,
                                    child: OutlineButton(
                                      highlightedBorderColor:
                                          context.accentColor,
                                      splashColor:
                                          context.accentColor.withOpacity(0.5),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(100))),
                                      child: _loading
                                          ? SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ))
                                          : Text(context.s.loadMore),
                                      onPressed: () => _loading
                                          ? null
                                          : setState(
                                              () {
                                                _loading = true;
                                                _searchFuture = _getEpisodes(
                                                    id: widget.onlinePodcast.id,
                                                    nextEpisodeDate:
                                                        _nextEpisdoeDate);
                                              },
                                            ),
                                    ),
                                  ),
                                );
                              }
                              return ListTile(
                                title: Text(content[index].title),
                                subtitle: Text(
                                    '${content[index].length.toTime} | '
                                    '${content[index].pubDate.toDate(context)}',
                                    style:
                                        TextStyle(color: context.accentColor)),
                              );
                            },
                          );
                        }
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      })
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }
}
