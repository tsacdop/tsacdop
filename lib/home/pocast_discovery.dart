import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../local_storage/key_value_storage.dart';
import '../service/search_api.dart';
import '../state/search_state.dart';
import '../type/search_api/search_genre.dart';
import '../type/search_api/searchpodcast.dart';
import '../util/custom_widget.dart';
import '../util/extension_helper.dart';
import 'search_podcast.dart';

class DiscoveryPage extends StatefulWidget {
  DiscoveryPage({this.onTap, Key key}) : super(key: key);
  final ValueChanged<String> onTap;
  @override
  DiscoveryPageState createState() => DiscoveryPageState();
}

class DiscoveryPageState extends State<DiscoveryPage> {
  Genre _selectedGenre;
  Genre get selectedGenre => _selectedGenre;
  final List<OnlinePodcast> _podcastList = [];
  Future _searchTopPodcast;
  Future<List<String>> _getSearchHistory() {
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
                  height: context.textTheme.bodyText1.fontSize,
                  decoration: BoxDecoration(
                      color: context.primaryColorDark,
                      borderRadius: BorderRadius.circular(4)),
                ),
                SizedBox(height: 10),
                Container(
                  width: 40,
                  height: context.textTheme.bodyText1.fontSize,
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
                child: OutlineButton(
                    color: context.accentColor.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100.0),
                        side: BorderSide(color: Colors.grey[500])),
                    highlightedBorderColor: Colors.grey[500],
                    disabledTextColor: Colors.grey[500],
                    child: Text(context.s.subscribe),
                    disabledBorderColor: Colors.grey[500],
                    onPressed: () {}),
              ),
            ),
          ),
        ],
      ));

  Widget _historyList() => FutureBuilder<List<String>>(
      future: _getSearchHistory(),
      initialData: [],
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data.isNotEmpty) {
          final history = snapshot.data;
          return SizedBox(
            child: Wrap(
              direction: Axis.horizontal,
              children: history
                  .map<Widget>((e) => Padding(
                        padding: const EdgeInsets.fromLTRB(8, 2, 0, 0),
                        child: FlatButton.icon(
                          color:
                              Colors.accents[history.indexOf(e)].withAlpha(70),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100.0),
                          ),
                          onPressed: () => widget.onTap(e),
                          label: Text(e),
                          icon: Icon(
                            Icons.search,
                            size: 20,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          );
        }
        return SizedBox(
          height: 0,
        );
      });

  Future<List<OnlinePodcast>> _getTopPodcasts({int page}) async {
    final searchEngine = ListenNotesSearch();
    var searchResult = await searchEngine.fetchBestPodcast(
      genre: '',
      page: page,
    );
    final podcastTopList =
        searchResult.podcasts.map((e) => e?.toOnlinePodcast).toList();
    _podcastList.addAll(podcastTopList.cast());
    return _podcastList;
  }

  Future<bool> _getHideDiscovery() async {
    final storage = KeyValueStorage(hidePodcastDiscoveryKey);
    return await storage.getBool(defaultValue: false);
  }

  @override
  Widget build(BuildContext context) {
    final searchState = context.watch<SearchState>();
    return FutureBuilder<bool>(
      future: _getHideDiscovery(),
      initialData: true,
      builder: (context, snapshot) => snapshot.data
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_historyList(), Spacer()],
            )
          : PodcastSlideup(
              searchEngine: SearchEngine.listenNotes,
              child: _selectedGenre == null
                  ? SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _historyList(),
                          Padding(
                            padding: EdgeInsets.fromLTRB(20, 10, 10, 4),
                            child: Text('Popular',
                                style: context.textTheme.headline6
                                    .copyWith(color: context.accentColor)),
                          ),
                          SizedBox(
                            height: 200,
                            child: FutureBuilder<List<OnlinePodcast>>(
                                future: _searchTopPodcast,
                                builder: (context, snapshot) {
                                  return ScrollConfiguration(
                                    behavior: NoGrowBehavior(),
                                    child: ListView(
                                        scrollDirection: Axis.horizontal,
                                        children: snapshot.hasData
                                            ? snapshot.data
                                                .map<Widget>((podcast) {
                                                return Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      color:
                                                          context.primaryColor),
                                                  width: 120,
                                                  margin: EdgeInsets.fromLTRB(
                                                      10, 10, 0, 10),
                                                  child: Material(
                                                    color: Colors.transparent,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    clipBehavior: Clip.hardEdge,
                                                    child: InkWell(
                                                      onTap: () {
                                                        searchState
                                                                .selectedPodcast =
                                                            podcast;
                                                        widget.onTap('');
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(4.0),
                                                        child: Column(
                                                          children: [
                                                            Expanded(
                                                              flex: 2,
                                                              child: Center(
                                                                  child: PodcastAvatar(
                                                                      podcast)),
                                                            ),
                                                            Expanded(
                                                              flex: 1,
                                                              child: Text(
                                                                podcast.title,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .fade,
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 1,
                                                              child: Center(
                                                                child: SizedBox(
                                                                    height: 32,
                                                                    child: SubscribeButton(
                                                                        podcast)),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
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
                                style: context.textTheme.headline6
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
                                        widget.onTap('');
                                        setState(() => _selectedGenre = e);
                                      },
                                      title: Text(e.name),
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
                    )
                  : _TopPodcastList(genre: _selectedGenre),
            ),
    );
  }
}

class _TopPodcastList extends StatefulWidget {
  final Genre genre;
  _TopPodcastList({this.genre, Key key}) : super(key: key);

  @override
  __TopPodcastListState createState() => __TopPodcastListState();
}

class __TopPodcastListState extends State<_TopPodcastList> {
  final List<OnlinePodcast> _podcastList = [];
  Future _searchFuture;
  bool _loading;
  int _page;
  Future<List<OnlinePodcast>> _getTopPodcasts({Genre genre, int page}) async {
    final searchEngine = ListenNotesSearch();
    var searchResult = await searchEngine.fetchBestPodcast(
      genre: genre.id,
      page: page,
    );
    final podcastTopList =
        searchResult.podcasts.map((e) => e?.toOnlinePodcast).toList();
    _podcastList.addAll(podcastTopList.cast());
    _loading = false;
    return _podcastList;
  }

  @override
  void initState() {
    _page = 1;
    _searchFuture = _getTopPodcasts(genre: widget.genre, page: _page);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
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
                child: Text(widget.genre.name,
                    style: context.textTheme.headline6
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
                    child: OutlineButton(
                      highlightedBorderColor: context.accentColor,
                      splashColor: context.accentColor.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(100))),
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
                                    genre: widget.genre, page: _page);
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
