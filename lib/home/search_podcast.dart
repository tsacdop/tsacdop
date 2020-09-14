import 'dart:async';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:webfeed/webfeed.dart';

import '../local_storage/key_value_storage.dart';
import '../service/api_search.dart';
import '../state/podcast_group.dart';
import '../state/search_state.dart';
import '../type/searchepisodes.dart';
import '../type/searchpodcast.dart';
import '../util/extension_helper.dart';
import 'pocast_discovery.dart';

class MyHomePageDelegate extends SearchDelegate<int> {
  final String searchFieldLabel;
  final GlobalKey<DiscoveryPageState> _discoveryKey =
      GlobalKey<DiscoveryPageState>();
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
  void close(BuildContext context, int result) {
    final selectedPodcast = context.read<SearchState>().selectedPodcast;
    if (selectedPodcast != null) {
      context.read<SearchState>().clearSelect();
    } else {
      if (_discoveryKey.currentState?.selectedGenre != null) {
        _discoveryKey.currentState.backToHome();
      } else {
        context.read<SearchState>().clearList();
        super.close(context, result);
      }
    }
  }

  @override
  ThemeData appBarTheme(BuildContext context) => Theme.of(context);

  @override
  Widget buildLeading(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        close(context, null);
        return false;
      },
      child: IconButton(
        tooltip: context.s.back,
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,
        ),
        onPressed: () {
          close(context, 1);
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return DiscoveryPage(
      key: _discoveryKey,
      onTap: (history) {
        query = history;
        showResults(context);
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
          tooltip: context.s.clear,
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showResults(context);
          },
        ),
    ];
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return DiscoveryPage(
          key: _discoveryKey,
          onTap: (history) {
            query = history;
            showResults(context);
          });
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
    final s = context.s;
    var items = widget.rssFeed.items;
    return DefaultTabController(
      length: 2,
      child: Column(
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(_onlinePodcast.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.headline5),
                        ),
                        SubscribeButton(_onlinePodcast),
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
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      Container(
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
  Future _searchFuture;

  @override
  void initState() {
    super.initState();
    _searchFuture = _getList(widget.query, _nextOffset);
  }

  Future<void> _saveHistory(String query) async {
    final storage = KeyValueStorage(searchHistoryKey);
    final history = await storage.getStringList();
    if (!history.contains(query)) {
      if (history.length >= 6) {
        history.removeLast();
      }
      history.insert(0, query);
      await storage.saveStringList(history);
    }
  }

  Future<List<OnlinePodcast>> _getList(
      String searchText, int nextOffset) async {
    if (nextOffset == 0) _saveHistory(searchText);
    final searchEngine = SearchEngine();
    var searchResult = await searchEngine.searchPodcasts(
        searchText: searchText, nextOffset: nextOffset);
    _offset = searchResult.nextOffset;
    _podcastList.addAll(searchResult.results.cast());
    _loading = false;
    return _podcastList;
  }

  @override
  Widget build(BuildContext context) {
    return PodcastSlideup(
      child: FutureBuilder<List>(
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
                    return SearchResult(onlinePodcast: content[index]);
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
                    )
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

class SearchResult extends StatelessWidget {
  final OnlinePodcast onlinePodcast;
  SearchResult({this.onlinePodcast, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var searchState = context.watch<SearchState>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
            contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
            onTap: () {
              searchState.selectedPodcast = onlinePodcast;
              // onSelect(onlinePodcast);
            },
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(25.0),
              child: CachedNetworkImage(
                height: 50.0,
                width: 50.0,
                fit: BoxFit.fitWidth,
                alignment: Alignment.center,
                imageUrl: onlinePodcast.image,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    Container(
                  height: 50,
                  width: 50,
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
                    width: 50,
                    height: 50,
                    alignment: Alignment.center,
                    color: context.primaryColorDark,
                    child: Icon(Icons.error)),
              ),
            ),
            title: Text(onlinePodcast.title),
            subtitle: Text(onlinePodcast.publisher ?? ''),
            trailing: SubscribeButton(onlinePodcast)),
      ],
    );
  }
}

/// Search podcast detail widget
class SearchResultDetail extends StatefulWidget {
  SearchResultDetail(this.onlinePodcast,
      {this.maxHeight, this.episodeList, this.isSubscribed, Key key})
      : super(key: key);
  final OnlinePodcast onlinePodcast;
  final double maxHeight;
  final List<OnlineEpisode> episodeList;
  final bool isSubscribed;
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

  void _start(DragStartDetails event) {
    setState(() {
      _startdy = event.localPosition.dy;
      _animation =
          Tween<double>(begin: _initSize, end: _initSize).animate(_controller);
    });
    _controller.forward();
  }

  void _update(DragUpdateDetails event) {
    setState(() {
      _move = _startdy - event.localPosition.dy;
      _animation = Tween<double>(begin: _initSize, end: _initSize + _move)
          .animate(_controller);
      _slideDirection = _move > 0 ? SlideDirection.up : SlideDirection.down;
    });
    _controller.forward();
  }

  void _end() {
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
        if (_animation.value < _minHeight - 50) {
          context.read<SearchState>().clearSelect();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
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
                                SubscribeButton(widget.onlinePodcast),
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

class SubscribeButton extends StatelessWidget {
  SubscribeButton(this.onlinePodcast, {Key key}) : super(key: key);
  final OnlinePodcast onlinePodcast;

  @override
  Widget build(BuildContext context) {
    final subscribeWorker = context.watch<GroupList>();
    final searchState = context.watch<SearchState>();
    final s = context.s;
    void subscribePodcast(OnlinePodcast podcast) {
      var item = SubscribeItem(podcast.rss, podcast.title,
          imgUrl: podcast.image, group: 'Home');
      subscribeWorker.setSubscribeItem(item);
      searchState.addPodcast(podcast);
    }

    return Consumer<SearchState>(builder: (_, searchState, __) {
      final subscribed = searchState.isSubscribed(onlinePodcast);
      return !subscribed
          ? OutlineButton(
              highlightedBorderColor: context.accentColor,
              borderSide: BorderSide(color: context.accentColor),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.0),
                  side: BorderSide(color: context.accentColor)),
              splashColor: context.accentColor.withOpacity(0.5),
              child: Text(s.subscribe,
                  style: TextStyle(color: context.accentColor)),
              onPressed: () {
                Fluttertoast.showToast(
                  msg: s.podcastSubscribed,
                  gravity: ToastGravity.BOTTOM,
                );
                subscribePodcast(onlinePodcast);
                searchState.addPodcast(onlinePodcast);
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
              onPressed: () {});
    });
  }
}

class PodcastSlideup extends StatelessWidget {
  const PodcastSlideup({this.child, Key key}) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchState>(builder: (_, searchState, __) {
      final selectedPodcast = searchState.selectedPodcast;
      final subscribed = searchState.subscribedList;
      return Stack(
        alignment: Alignment.bottomCenter,
        children: [
          child,
          if (selectedPodcast != null)
            Positioned.fill(
              child: GestureDetector(
                onTap: searchState.clearSelect,
                child: Container(
                  color: context.scaffoldBackgroundColor.withOpacity(0.9),
                ),
              ),
            ),
          if (selectedPodcast != null)
            LayoutBuilder(
              builder: (context, constrants) => SearchResultDetail(
                selectedPodcast,
                maxHeight: constrants.maxHeight,
                isSubscribed: subscribed.contains(selectedPodcast),
              ),
            ),
        ],
      );
    });
  }
}

class PodcastAvatar extends StatelessWidget {
  const PodcastAvatar(this.podcast, {Key key}) : super(key: key);
  final OnlinePodcast podcast;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25.0),
        child: CachedNetworkImage(
          height: 50.0,
          width: 50.0,
          fit: BoxFit.fitWidth,
          alignment: Alignment.center,
          imageUrl: podcast.image,
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              Container(
            height: 50,
            width: 50,
            alignment: Alignment.center,
            color: context.primaryColorDark,
            child: SizedBox(
              width: 20,
              height: 2,
              child: LinearProgressIndicator(value: downloadProgress.progress),
            ),
          ),
          errorWidget: (context, url, error) => Container(
              width: 50,
              height: 50,
              alignment: Alignment.center,
              color: context.primaryColorDark,
              child: Icon(Icons.error)),
        ),
      ),
    );
  }
}
