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
import '../service/search_api.dart';
import '../state/podcast_group.dart';
import '../state/search_state.dart';
import '../type/search_api/searchepisodes.dart';
import '../type/search_api/searchpodcast.dart';
import '../util/extension_helper.dart';
import '../widgets/custom_widget.dart';
import '../.env.dart';
import 'pocast_discovery.dart';

class MyHomePageDelegate extends SearchDelegate<int> {
  final String searchFieldLabel;
  final GlobalKey<DiscoveryPageState> _discoveryKey =
      GlobalKey<DiscoveryPageState>();
  MyHomePageDelegate({this.searchFieldLabel})
      : super(
          searchFieldLabel: searchFieldLabel,
        );
  var _searchEngine;
  static Future _getRss(String url) async {
    try {
      final options = BaseOptions(
        connectTimeout: 30000,
        receiveTimeout: 90000,
      );
      var response = await Dio(options).get(url);
      return RssFeed.parse(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<SearchEngine> _getSearchEngine() async {
    final storage = KeyValueStorage(searchEngineKey);
    final index = await storage.getInt();
    if (_searchEngine == null) {
      _searchEngine = SearchEngine.values[index];
    }
    return _searchEngine;
  }

  RegExp rssExp = RegExp(r'^(https?):\/\/(.*)');

  Widget _invalidRss(BuildContext context) => Container(
        padding: EdgeInsets.only(top: 200),
        alignment: Alignment.topCenter,
        child: Text(context.s.searchInvalidRss,
            style: context.textTheme.headline6.copyWith(color: Colors.red)),
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
        splashRadius: 20,
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
      if (query.isNotEmpty)
        IconButton(
          tooltip: context.s.clear,
          splashRadius: 20,
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showResults(context);
          },
        ),
      FutureBuilder<SearchEngine>(
        future: _getSearchEngine(),
        initialData: SearchEngine.podcastIndex,
        builder: (context, snapshot) => PopupMenuButton<SearchEngine>(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 1,
          icon: SizedBox(
            height: 30,
            width: 30,
            child: CircleAvatar(
              backgroundImage: snapshot.data == SearchEngine.podcastIndex
                  ? AssetImage('assets/podcastindex_logo.png')
                  : AssetImage('assets/listennotes_logo.png'),
              maxRadius: 25,
            ),
          ),
          onSelected: (value) {
            _searchEngine = value;
            showSuggestions(context);
            if (query != '') {
              showResults(context);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: SearchEngine.podcastIndex,
              child: Container(
                padding: EdgeInsets.only(left: 10),
                child: Row(
                  children: <Widget>[
                    Text('Podcastindex'),
                    Spacer(),
                    if (_searchEngine == SearchEngine.podcastIndex)
                      DotIndicator()
                  ],
                ),
              ),
            ),
            if(environment['apiKey'] != '')
            PopupMenuItem(
              value: SearchEngine.listenNotes,
              child: Container(
                padding: EdgeInsets.only(left: 10),
                child: Row(
                  children: <Widget>[
                    Text('ListenNotes'),
                    Spacer(),
                    if (_searchEngine == SearchEngine.listenNotes)
                      DotIndicator()
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      SizedBox(width: 10),
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
        future: _getRss(rssExp.stringMatch(query)),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _invalidRss(context);
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
      switch (_searchEngine) {
        case SearchEngine.listenNotes:
          return _ListenNotesSearch(query: query);
          break;
        case SearchEngine.podcastIndex:
          return _PodcastIndexSearch(query: query);
        default:
          return Center();
          break;
      }
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
        title: p?.title ?? widget.url,
        publisher: p?.author ?? "",
        description: p?.description ?? "No description for this podcast",
        image: p?.itunes?.image?.href ?? p?.image?.url ?? "",
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

class _ListenNotesSearch extends StatefulWidget {
  final String query;
  _ListenNotesSearch({this.query, Key key}) : super(key: key);

  @override
  __ListenNotesSearchState createState() => __ListenNotesSearchState();
}

class __ListenNotesSearchState extends State<_ListenNotesSearch> {
  final List<OnlinePodcast> _podcastList = [];
  int _nextOffset = 0;
  int _offset;
  bool _loading = false;
  bool _loadError = false;
  Future _searchFuture;

  @override
  void initState() {
    super.initState();
    _searchFuture = _getListenNotesList(widget.query, _nextOffset);
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

  Future<List<OnlinePodcast>> _getListenNotesList(
      String searchText, int nextOffset) async {
    if (nextOffset == 0) _saveHistory(searchText);
    final searchEngine = ListenNotesSearch();
    var searchResult;
    try {
      searchResult = await searchEngine.searchPodcasts(
          searchText: searchText, nextOffset: nextOffset);
    } catch (e) {
      _loadError = true;
      _loading = false;
      return [];
    }
    _offset = searchResult.nextOffset;
    var searchList = <OnlinePodcast>[...searchResult.results.cast().toList()];
    _podcastList.addAll(searchList);
    _loading = false;
    return _podcastList;
  }

  @override
  Widget build(BuildContext context) {
    return PodcastSlideup(
      searchEngine: SearchEngine.listenNotes,
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
          if (snapshot.data.isEmpty) {
            if (_loadError) {
              return Container(
                padding: EdgeInsets.only(top: 200),
                alignment: Alignment.topCenter,
                child: Text('Network error.',
                    style: context.textTheme.headline6
                        .copyWith(color: Colors.red)),
              );
            } else {
              return Container(
                padding: EdgeInsets.only(top: 200),
                alignment: Alignment.topCenter,
                child: Text('No result.',
                    style: context.textTheme.headline6
                        .copyWith(color: context.accentColor)),
              );
            }
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
                            borderRadius: BorderRadius.circular(100)),
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
                                  _searchFuture = _getListenNotesList(
                                      widget.query, _nextOffset);
                                },
                              ),
                      ),
                    )
                  ],
                ),
              ),
              SliverToBoxAdapter(
                  child: SizedBox(
                height: 20,
                child: Center(
                  child: Image(
                    image: context.brightness == Brightness.light
                        ? AssetImage('assets/listennotes.png')
                        : AssetImage('assets/listennotes_light.png'),
                    height: 15,
                  ),
                ),
              ))
            ],
          );
        },
      ),
    );
  }
}

class _PodcastIndexSearch extends StatefulWidget {
  final String query;
  _PodcastIndexSearch({this.query, Key key}) : super(key: key);

  @override
  __PodcastIndexSearchState createState() => __PodcastIndexSearchState();
}

class __PodcastIndexSearchState extends State<_PodcastIndexSearch> {
  int _limit;
  bool _loading;
  bool _loadError;
  Future _searchFuture;
  List _podcastList = [];
  final _searchEngine = PodcastsIndexSearch();

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

  @override
  void initState() {
    super.initState();
    _loading = false;
    _loadError = false;
    _limit = 10;
    _searchFuture = _getPodcatsIndexList(widget.query, limit: _limit);
  }

  Future<List<OnlinePodcast>> _getPodcatsIndexList(String searchText,
      {int limit}) async {
    if (_limit == 10) _saveHistory(searchText);
    var searchResult;
    try {
      searchResult = await _searchEngine.searchPodcasts(
          searchText: searchText, limit: limit);
    } catch (e) {
      _loadError = true;
      _loading = false;
      return [];
    }
    var list = searchResult.feeds.cast();
    _podcastList = <OnlinePodcast>[
      for (var podcast in list) podcast.toOnlinePodcast
    ];
    _loading = false;
    return _podcastList;
  }

  @override
  Widget build(BuildContext context) {
    return PodcastSlideup(
      searchEngine: SearchEngine.podcastIndex,
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
            if (snapshot.data.isEmpty) {
              if (_loadError) {
                return Container(
                  padding: EdgeInsets.only(top: 200),
                  alignment: Alignment.topCenter,
                  child: Text('Network error.',
                      style: context.textTheme.headline6
                          .copyWith(color: Colors.red)),
                );
              } else {
                return Container(
                  padding: EdgeInsets.only(top: 200),
                  alignment: Alignment.topCenter,
                  child: Text('No result found.',
                      style: context.textTheme.headline6
                          .copyWith(color: context.accentColor)),
                );
              }
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
                              borderRadius: BorderRadius.circular(100)),
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
                                    _limit += 10;
                                    _searchFuture = _getPodcatsIndexList(
                                        widget.query,
                                        limit: _limit);
                                  },
                                ),
                        ),
                      )
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                    child: SizedBox(
                  height: 20,
                  child: Center(
                    child: Image(
                      image: AssetImage('assets/podcastindex.png'),
                      height: 15,
                    ),
                  ),
                ))
              ],
            );
          }),
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
            subtitle: Text(
              onlinePodcast.publisher ?? '',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: SubscribeButton(onlinePodcast)),
      ],
    );
  }
}

/// Search podcast detail widget
class SearchResultDetail extends StatefulWidget {
  SearchResultDetail(this.onlinePodcast,
      {this.maxHeight, this.isSubscribed, this.searchEngine, Key key})
      : super(key: key);
  final OnlinePodcast onlinePodcast;
  final double maxHeight;
  final bool isSubscribed;
  final SearchEngine searchEngine;
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

    _searchFuture = widget.searchEngine == SearchEngine.listenNotes
        ? _getListenNotesEpisodes(
            id: widget.onlinePodcast.id, nextEpisodeDate: _nextEpisdoeDate)
        : _getIndexEpisodes(id: widget.onlinePodcast.rss);
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

  Future<List<OnlineEpisode>> _getListenNotesEpisodes(
      {String id, int nextEpisodeDate}) async {
    var searchEngine = ListenNotesSearch();
    var searchResult = await searchEngine.fetchEpisode(
        id: id, nextEpisodeDate: nextEpisodeDate);
    _nextEpisdoeDate = searchResult.nextEpisodeDate;
    _episodeList.addAll(searchResult.episodes.cast());
    _loading = false;
    return _episodeList;
  }

  Future<List<OnlineEpisode>> _getIndexEpisodes({String id}) async {
    var searchEngine = PodcastsIndexSearch();
    var searchResult = await searchEngine.fetchEpisode(rssUrl: id);
    var episodes = searchResult.items.cast();
    for (var episode in episodes) {
      _episodeList.add(episode.toOnlineWEpisode);
    }
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
          color: context.primaryColor,
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
                                  widget.onlinePodcast.interval
                                              .toInterval(context) !=
                                          ''
                                      ? '${widget.onlinePodcast.interval.toInterval(context)} | '
                                          '${widget.onlinePodcast.latestPubDate.toDate(context)}'
                                      : '${widget.onlinePodcast.latestPubDate.toDate(context)}',
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
                                if (widget.onlinePodcast.count > 0)
                                  Container(
                                      padding: const EdgeInsets.only(
                                          left: 5, right: 5, top: 2, bottom: 2),
                                      decoration: BoxDecoration(
                                          color: context.accentColor,
                                          borderRadius:
                                              BorderRadius.circular(100)),
                                      child: Text(
                                          widget.onlinePodcast.count.toString(),
                                          style:
                                              TextStyle(color: Colors.white)))
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
                                        splashColor: context.accentColor
                                            .withOpacity(0.5),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(100))),
                                        child: _loading
                                            ? SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                ))
                                            : Text(context.s.loadMore),
                                        onPressed: () {
                                          if (widget.searchEngine ==
                                              SearchEngine.listenNotes) {
                                            _loading
                                                ? null
                                                : setState(
                                                    () {
                                                      _loading = true;
                                                      _searchFuture =
                                                          _getListenNotesEpisodes(
                                                              id: widget
                                                                  .onlinePodcast
                                                                  .id,
                                                              nextEpisodeDate:
                                                                  _nextEpisdoeDate);
                                                    },
                                                  );
                                          }
                                        }),
                                  ),
                                );
                              }
                              return ListTile(
                                title: Text(content[index].title),
                                subtitle: Text(
                                    content[index].length == 0
                                        ? '${content[index].pubDate.toDate(context)}'
                                        : '${content[index].length.toTime} | '
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
          ? ButtonTheme(
              height: 32,
              child: OutlineButton(
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
                  }),
            )
          : ButtonTheme(
              height: 32,
              child: OutlineButton(
                  color: context.accentColor.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100.0),
                      side: BorderSide(color: Colors.grey[500])),
                  highlightedBorderColor: Colors.grey[500],
                  disabledTextColor: Colors.grey[500],
                  child: Text(s.subscribe),
                  disabledBorderColor: Colors.grey[500],
                  onPressed: () {}),
            );
    });
  }
}

class PodcastSlideup extends StatelessWidget {
  const PodcastSlideup({this.child, this.searchEngine, Key key})
      : super(key: key);
  final Widget child;
  final SearchEngine searchEngine;

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
