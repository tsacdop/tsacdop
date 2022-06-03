import 'dart:async';

import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

import '../.env.dart';
import '../local_storage/key_value_storage.dart';
import '../service/search_api.dart';
import '../state/search_state.dart';
import '../type/search_api/search_genre.dart';
import '../type/search_api/searchpodcast.dart';
import '../util/extension_helper.dart';
import '../widgets/custom_widget.dart';
import 'search_podcast.dart';

class DiscoveryPage extends StatefulWidget {
  DiscoveryPage({this.onTap, Key? key}) : super(key: key);
  final ValueChanged<String?>? onTap;
  @override
  DiscoveryPageState createState() => DiscoveryPageState();
}

class DiscoveryPageState extends State<DiscoveryPage> {
  Genre? _selectedGenre;
  Genre? get selectedGenre => _selectedGenre;
  final List<OnlinePodcast> _podcastList = [];
  Future? _searchTopPodcast;
  Future? _getIfHideDiscovery;
  Future<List<String?>?> _getSearchHistory() {
    final storage = KeyValueStorage(searchHistoryKey);
    final history = storage.getStringList();
    return history;
  }

  void backToHome() {
    setState(() {
      _selectedGenre = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _searchTopPodcast = _getTopPodcasts(page: 1);
    _getIfHideDiscovery = _getHideDiscovery();
  }

  Widget _loadTopPodcasts() => Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: context.primaryColor),
      width: 120,
      margin: EdgeInsets.fromLTRB(10, 10, 0, 10),
      padding: EdgeInsets.all(4),
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.primaryColorDark,
                ),
                alignment: Alignment.center,
                child: SizedBox(
                  width: 20,
                  height: 2,
                  child: LinearProgressIndicator(value: 0),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: context.textTheme.bodyText1!.fontSize,
                  decoration: BoxDecoration(
                      color: context.primaryColorDark,
                      borderRadius: BorderRadius.circular(4)),
                ),
                SizedBox(height: 10),
                Container(
                  width: 40,
                  height: context.textTheme.bodyText1!.fontSize,
                  decoration: BoxDecoration(
                      color: context.primaryColorDark,
                      borderRadius: BorderRadius.circular(4)),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: SizedBox(
                height: 32,
                child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      primary: context.accentColor.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          side: BorderSide(color: Colors.grey[500]!)),
                      // highlightedBorderColor: Colors.grey[500],
                      // disabledTextColor: Colors.grey[500],
                      // disabledBorderColor: Colors.grey[500],
                    ),
                    child: Text(context.s.subscribe),
                    onPressed: () {}),
              ),
            ),
          ),
        ],
      ));

  Widget _historyList() => FutureBuilder<List<String?>?>(
      future: _getSearchHistory(),
      initialData: [],
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final history = snapshot.data!;
          return Wrap(
            direction: Axis.horizontal,
            children: history
                .map<Widget>((e) => Padding(
                      padding: const EdgeInsets.fromLTRB(8, 2, 0, 0),
                      child: FlatButton.icon(
                        color: Colors.accents[history.indexOf(e)].withAlpha(70),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                        onPressed: () => widget.onTap!(e),
                        label: Text(e!),
                        icon: Icon(
                          Icons.search,
                          size: 20,
                        ),
                      ),
                    ))
                .toList(),
          );
        }
        return SizedBox(
          height: 0,
        );
      });

  Widget _podcastCard(OnlinePodcast podcast, {VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: context.primaryColor,
          border:
              Border.all(color: context.textColor!.withOpacity(0.1), width: 1)),
      width: 120,
      margin: EdgeInsets.fromLTRB(10, 10, 0, 10),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(4.0),
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Center(child: PodcastAvatar(podcast)),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    podcast.title!,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.fade,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child:
                        SizedBox(height: 32, child: SubscribeButton(podcast)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<List<OnlinePodcast>> _getTopPodcasts({int? page}) async {
    if (environment['apiKey'] == '') return [];
    final searchEngine = ListenNotesSearch();
    try {
      var searchResult = await searchEngine.fetchBestPodcast(
        genre: '',
        page: page,
      );
      final podcastTopList = [
        for (final p in searchResult!.podcasts!) p.toOnlinePodcast
      ];
      _podcastList.addAll(podcastTopList.cast());
      return _podcastList;
    } catch (e) {
      return [];
    }
  }

  Future<bool> _getHideDiscovery() async {
    final storage = KeyValueStorage(hidePodcastDiscoveryKey);
    return await storage.getBool(defaultValue: false);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: _getIfHideDiscovery!.then((value) => value as bool),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center();
          } else if (snapshot.data! || environment['apiKey'] == '') {
            return ScrollConfiguration(
              behavior: NoGrowBehavior(),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _historyList(),
                    SizedBox(
                      height: 150,
                      child: Center(
                        child: Icon(
                          Icons.search,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LineIcons.microphone,
                            size: 30,
                            color: Colors.lightBlue,
                          ),
                          SizedBox(width: 50),
                          Icon(
                            LineIcons.broadcastTower,
                            size: 30,
                            color: Colors.deepPurple,
                          ),
                          SizedBox(width: 50),
                          Icon(
                            LineIcons.rssSquare,
                            size: 30,
                            color: Colors.blueGrey,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(50, 20, 50, 20),
                      child: Center(
                        child: Text(
                          context.s.searchHelper,
                          textAlign: TextAlign.center,
                          style: context.textTheme.headline6!
                              .copyWith(color: Colors.grey[400]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return PodcastSlideup(
              searchEngine: SearchEngine.listenNotes,
              child: Selector<SearchState, Genre?>(
                selector: (_, searchState) => searchState.genre,
                builder: (_, genre, __) => IndexedStack(
                  index: genre == null ? 0 : 1,
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _historyList(),
                          SizedBox(height: 8),
                          SizedBox(
                            height: 200,
                            child: FutureBuilder<List<OnlinePodcast>>(
                                future: _searchTopPodcast!.then(
                                    (value) => value as List<OnlinePodcast>),
                                builder: (context, snapshot) {
                                  return ScrollConfiguration(
                                    behavior: NoGrowBehavior(),
                                    child: ListView(
                                        addAutomaticKeepAlives: true,
                                        scrollDirection: Axis.horizontal,
                                        children: snapshot.hasData
                                            ? snapshot.data!
                                                .map<Widget>((podcast) {
                                                return _podcastCard(
                                                  podcast,
                                                  onTap: () {
                                                    context
                                                            .read<SearchState>()
                                                            .selectedPodcast =
                                                        podcast;
                                                    widget.onTap!('');
                                                  },
                                                );
                                              }).toList()
                                            : [
                                                _loadTopPodcasts(),
                                                _loadTopPodcasts(),
                                                _loadTopPodcasts(),
                                                _loadTopPodcasts(),
                                              ]),
                                  );
                                }),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(20, 10, 10, 4),
                            child: Text('Categories',
                                style: context.textTheme.headline6!
                                    .copyWith(color: context.accentColor)),
                          ),
                          ListView(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            children: genres
                                .map<Widget>((e) => ListTile(
                                      contentPadding:
                                          EdgeInsets.fromLTRB(20, 0, 20, 0),
                                      onTap: () {
                                        widget.onTap!('');
                                        context.read<SearchState>().setGenre =
                                            e;
                                      },
                                      title: Text(e.name!,
                                          style: context.textTheme.headline6),
                                    ))
                                .toList(),
                          ),
                          SizedBox(
                            height: 40,
                            child: Center(
                              child: Image(
                                image: context.brightness == Brightness.light
                                    ? AssetImage('assets/listennotes.png')
                                    : AssetImage(
                                        'assets/listennotes_light.png'),
                                height: 15,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    genre == null ? Center() : _TopPodcastList(genre: genre),
                  ],
                ),
              ),
            );
          }
        });
  }
}

class _TopPodcastList extends StatefulWidget {
  final Genre? genre;
  _TopPodcastList({this.genre, Key? key}) : super(key: key);

  @override
  __TopPodcastListState createState() => __TopPodcastListState();
}

class __TopPodcastListState extends State<_TopPodcastList> {
  final List<OnlinePodcast> _podcastList = [];
  Future? _searchFuture;
  late bool _loading;
  late int _page;
  Future<List<OnlinePodcast>> _getTopPodcasts(
      {required Genre genre, int? page}) async {
    final searchEngine = ListenNotesSearch();
    var searchResult = await searchEngine.fetchBestPodcast(
      genre: genre.id,
      page: page,
    );
    final podcastTopList = [
      for (final p in searchResult!.podcasts!) p?.toOnlinePodcast
    ];
    _podcastList.addAll(podcastTopList.cast());
    _loading = false;
    return _podcastList;
  }

  @override
  void initState() {
    _page = 1;
    try {
      _searchFuture = _getTopPodcasts(genre: widget.genre!, page: _page);
    } catch (e) {}
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: _searchFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            padding: EdgeInsets.only(top: 200),
            alignment: Alignment.topCenter,
            child: CircularProgressIndicator(),
          );
        }
        final content = snapshot.data;
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 10, 10, 4),
                child: Text(widget.genre!.name!,
                    style: context.textTheme.headline6!
                        .copyWith(color: context.accentColor)),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return SearchResult(
                    onlinePodcast: content[index],
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
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(100))),
                      ),
                      // highlightedBorderColor: context.accentColor,
                      // splashColor: context.accentColor.withOpacity(0.5),
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
                                _page++;
                                _searchFuture = _getTopPodcasts(
                                    genre: widget.genre!, page: _page);
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
    );
  }
}
