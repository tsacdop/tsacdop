import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../local_storage/sqflite_localpodcast.dart';
import '../state/audio_state.dart';
import '../type/episodebrief.dart';
import '../type/play_histroy.dart';
import '../type/playlist.dart';
import '../util/custom_widget.dart';
import '../util/extension_helper.dart';

enum InitPage { playlist, history }

class PlaylistPage extends StatefulWidget {
  final InitPage initPage;
  PlaylistPage({this.initPage, Key key}) : super(key: key);
  @override
  _PlaylistPageState createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  final textstyle = TextStyle(fontSize: 15.0, color: Colors.black);
  var _loadList;
  int _sumPlaylistLength(List<EpisodeBrief> episodes) {
    var sum = 0;
    if (episodes.length == 0) {
      return sum;
    } else {
      for (var episode in episodes) {
        sum += episode.duration ~/ 60;
      }
      return sum;
    }
  }

  Future<double> _getListenTime() async {
    var dbHelper = DBHelper();
    var listenTime = await dbHelper.listenMins(0);
    return listenTime;
  }

  bool _loadHistory = false;

  @override
  void initState() {
    super.initState();
    if (widget.initPage == InitPage.playlist) {
      _loadList = _ReorderablePlaylist();
    } else {
      _loadHistory = true;
      _loadList = _HistoryList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    var audio = Provider.of<AudioPlayerNotifier>(context, listen: false);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarIconBrightness:
            Theme.of(context).accentColorBrightness,
        statusBarIconBrightness: Theme.of(context).accentColorBrightness,
        systemNavigationBarColor: Theme.of(context).primaryColor,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: context.accentColor.withAlpha(70),
        ),
        body: SafeArea(
          child: Selector<AudioPlayerNotifier,
              Tuple4<Playlist, bool, bool, EpisodeBrief>>(
            selector: (_, audio) => Tuple4(audio.queue, audio.playerRunning,
                audio.queueUpdate, audio.episode),
            builder: (_, data, __) {
              var episodes = data.item1.playlist;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    color: context.accentColor.withAlpha(70),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: 100,
                            padding: EdgeInsets.only(
                              left: 60,
                            ),
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      _loadHistory
                                          ? s.settingsHistory
                                          : s.homeMenuPlaylist,
                                      style: TextStyle(
                                        color: context.textColor,
                                        fontSize: 30,
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    IconButton(
                                        icon: _loadHistory
                                            ? Icon(Icons.playlist_play)
                                            : Icon(Icons.history),
                                        onPressed: () => setState(() {
                                              _loadHistory = !_loadHistory;
                                              if (_loadHistory) {
                                                _loadList = _HistoryList();
                                              } else {
                                                _loadList =
                                                    _ReorderablePlaylist();
                                              }
                                            }))
                                  ],
                                ),
                                _loadHistory
                                    ? FutureBuilder<double>(
                                        future: _getListenTime(),
                                        initialData: 0.0,
                                        builder: (context, snapshot) =>
                                            RichText(
                                          text: TextSpan(
                                            text: 'Today ',
                                            style: GoogleFonts.cairo(
                                              textStyle: TextStyle(
                                                color: Theme.of(context)
                                                    .accentColor,
                                                fontSize: 20,
                                              ),
                                            ),
                                            children: <TextSpan>[
                                              TextSpan(
                                                text:
                                                    '${snapshot.data.toStringAsFixed(0)} ',
                                                style: GoogleFonts.cairo(
                                                    textStyle: TextStyle(
                                                  color: context.accentColor,
                                                  fontSize: 25,
                                                )),
                                              ),
                                              TextSpan(
                                                  text: 'mins',
                                                  style: TextStyle(
                                                    color: context.accentColor,
                                                    fontSize: 15,
                                                  )),
                                            ],
                                          ),
                                        ),
                                      )
                                    : RichText(
                                        text: TextSpan(
                                          text: episodes.length.toString(),
                                          style: GoogleFonts.cairo(
                                            textStyle: TextStyle(
                                              color:
                                                  Theme.of(context).accentColor,
                                              fontSize: 25,
                                            ),
                                          ),
                                          children: <TextSpan>[
                                            TextSpan(
                                                text: episodes.length < 2
                                                    ? 'episode'
                                                    : 'episodes',
                                                style: TextStyle(
                                                  color: context.accentColor,
                                                  fontSize: 15,
                                                )),
                                            TextSpan(
                                              text: _sumPlaylistLength(episodes)
                                                  .toString(),
                                              style: GoogleFonts.cairo(
                                                  textStyle: TextStyle(
                                                color: context.accentColor,
                                                fontSize: 25,
                                              )),
                                            ),
                                            TextSpan(
                                                text: 'mins',
                                                style: TextStyle(
                                                  color: context.accentColor,
                                                  fontSize: 15,
                                                )),
                                          ],
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(5.0),
                            margin: EdgeInsets.only(right: 20.0, bottom: 5.0),
                            decoration: data.item2
                                ? BoxDecoration(
                                    color: context.brightness == Brightness.dark
                                        ? Colors.grey[800]
                                        : Colors.grey[200],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                  )
                                : BoxDecoration(color: Colors.transparent),
                            child: data.item2
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      CircleAvatar(
                                          radius: 15,
                                          backgroundImage:
                                              data.item4.avatarImage),
                                      Container(
                                        width: 150,
                                        alignment: Alignment.center,
                                        child: Text(
                                          data.item4.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.fade,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 15),
                                        child: SizedBox(
                                            width: 20,
                                            height: 15,
                                            child: WaveLoader(
                                              color: context.accentColor,
                                            )),
                                      ),
                                    ],
                                  )
                                : IconButton(
                                    icon: Icon(Icons.play_circle_filled,
                                        size: 40, color: context.accentColor),
                                    onPressed: () {
                                      audio.playlistLoad();
                                      // setState(() {});
                                    }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                      child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          child: _loadList)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ReorderablePlaylist extends StatefulWidget {
  _ReorderablePlaylist({Key key}) : super(key: key);

  @override
  __ReorderablePlaylistState createState() => __ReorderablePlaylistState();
}

class __ReorderablePlaylistState extends State<_ReorderablePlaylist> {
  @override
  Widget build(BuildContext context) {
    var audio = Provider.of<AudioPlayerNotifier>(context, listen: false);
    return Selector<AudioPlayerNotifier, Tuple2<Playlist, bool>>(
        selector: (_, audio) => Tuple2(audio.queue, audio.playerRunning),
        builder: (_, data, __) {
          var episodes = data.item1.playlist;
          return ReorderableListView(
              onReorder: (oldIndex, newIndex) {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                audio.reorderPlaylist(oldIndex, newIndex);
                setState(() {});
              },
              scrollDirection: Axis.vertical,
              children: data.item2
                  ? episodes.map<Widget>((episode) {
                      if (episode.enclosureUrl != episodes.first.enclosureUrl) {
                        return _DismissibleContainer(
                          episode: episode,
                          onRemove: (value) => setState(() {}),
                          key: ValueKey(episode.enclosureUrl),
                        );
                      } else {
                        return Container(
                          key: ValueKey('sd'),
                        );
                      }
                    }).toList()
                  : episodes
                      .map<Widget>((episode) => _DismissibleContainer(
                            episode: episode,
                            onRemove: (value) => setState(() {}),
                            key: ValueKey(episode.enclosureUrl),
                          ))
                      .toList());
        });
  }
}

class _DismissibleContainer extends StatefulWidget {
  final EpisodeBrief episode;
  final ValueChanged<bool> onRemove;
  _DismissibleContainer({this.episode, this.onRemove, Key key})
      : super(key: key);

  @override
  __DismissibleContainerState createState() => __DismissibleContainerState();
}

class __DismissibleContainerState extends State<_DismissibleContainer> {
  bool _delete;
  Widget _episodeTag(String text, Color color) {
    if (text == '') {
      return Center();
    }
    return Container(
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(15.0)),
      height: 25.0,
      margin: EdgeInsets.only(right: 10.0),
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      alignment: Alignment.center,
      child: Text(text, style: TextStyle(fontSize: 14.0, color: Colors.black)),
    );
  }

  @override
  void initState() {
    _delete = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final audio = Provider.of<AudioPlayerNotifier>(context, listen: false);
    final s = context.s;
    final c = widget.episode.backgroudColor(context);
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInSine,
      alignment: Alignment.center,
      height: _delete ? 0 : 90.0,
      child: _delete
          ? Container(
              color: Colors.transparent,
            )
          : Dismissible(
              key: ValueKey('${widget.episode.enclosureUrl}t'),
              background: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.red),
                      padding: EdgeInsets.all(5),
                      alignment: Alignment.center,
                      child: Icon(
                        LineIcons.trash_alt_solid,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.red),
                      padding: EdgeInsets.all(5),
                      alignment: Alignment.center,
                      child: Icon(
                        LineIcons.trash_alt_solid,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                  ],
                ),
                height: 30,
                color: context.accentColor,
              ),
              onDismissed: (direction) async {
                setState(() {
                  _delete = true;
                });
                var index = await audio.delFromPlaylist(widget.episode);
                widget.onRemove(true);
                final episodeRemove = widget.episode;
                Scaffold.of(context).removeCurrentSnackBar();
                Scaffold.of(context).showSnackBar(SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.grey[800],
                  content: Text(s.toastRemovePlaylist,
                      style: TextStyle(color: Colors.white)),
                  action: SnackBarAction(
                      textColor: context.accentColor,
                      label: s.undo,
                      onPressed: () async {
                        await audio.addToPlaylistAt(episodeRemove, index);
                        widget.onRemove(false);
                      }),
                ));
              },
              child: SizedBox(
                height: 90.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                        onTap: () async {
                          await audio.episodeLoad(widget.episode);
                          widget.onRemove(true);
                        },
                        title: Container(
                          padding: EdgeInsets.fromLTRB(0, 5.0, 20.0, 5.0),
                          child: Text(
                            widget.episode.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        leading: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.unfold_more, color: c),
                            CircleAvatar(
                                backgroundColor: c.withOpacity(0.5),
                                backgroundImage: widget.episode.avatarImage),
                          ],
                        ),
                        subtitle: Container(
                          padding: EdgeInsets.only(top: 5, bottom: 5),
                          height: 35,
                          child: Row(
                            children: <Widget>[
                              if (widget.episode.explicit == 1)
                                Container(
                                    decoration: BoxDecoration(
                                        color: Colors.red[800],
                                        shape: BoxShape.circle),
                                    height: 25.0,
                                    width: 25.0,
                                    margin: EdgeInsets.only(right: 10.0),
                                    alignment: Alignment.center,
                                    child: Text('E',
                                        style: TextStyle(color: Colors.white))),
                              if (widget.episode.duration != 0)
                                _episodeTag(
                                    widget.episode.duration == 0
                                        ? ''
                                        : s.minsCount(
                                            widget.episode.duration ~/ 60),
                                    Colors.cyan[300]),
                              if (widget.episode.enclosureLength != null)
                                _episodeTag(
                                    widget.episode.enclosureLength == 0
                                        ? ''
                                        : '${(widget.episode.enclosureLength) ~/ 1000000}MB',
                                    Colors.lightBlue[300]),
                            ],
                          ),
                        ),
                        //trailing: Icon(Icons.menu),
                      ),
                    ),
                    Divider(
                      height: 2,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _HistoryList extends StatefulWidget {
  _HistoryList({Key key}) : super(key: key);

  @override
  __HistoryListState createState() => __HistoryListState();
}

class __HistoryListState extends State<_HistoryList> {
  var dbHelper = DBHelper();
  bool _loadMore = false;
  Future _getData;

  Future<List<PlayHistory>> getPlayRecords(int top) async {
    List<PlayHistory> playHistory;
    playHistory = await dbHelper.getPlayRecords(top);
    for (var record in playHistory) {
      await record.getEpisode();
    }
    return playHistory;
  }

  _loadMoreData() async {
    if (mounted) {
      setState(() {
        _loadMore = true;
      });
    }
    await Future.delayed(Duration(milliseconds: 500));
    _top = _top + 20;
    if (mounted) {
      setState(() {
        _getData = getPlayRecords(_top);
        _loadMore = false;
      });
    }
  }

  int _top;
  @override
  void initState() {
    super.initState();
    _top = 20;
    _getData = getPlayRecords(_top);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final audio = context.watch<AudioPlayerNotifier>();
    return FutureBuilder<List<PlayHistory>>(
        future: _getData,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    if (scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent &&
                        snapshot.data.length == _top) {
                      if (!_loadMore) {
                        _loadMoreData();
                      }
                    }
                    return true;
                  },
                  child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: snapshot.data.length + 1,
                      itemBuilder: (context, index) {
                        if (index == snapshot.data.length) {
                          return SizedBox(
                              height: 2,
                              child: _loadMore
                                  ? LinearProgressIndicator()
                                  : Center());
                        } else {
                          final seekValue = snapshot.data[index].seekValue;
                          final seconds = snapshot.data[index].seconds;
                          final date = snapshot
                              .data[index].playdate.millisecondsSinceEpoch;
                          final episode = snapshot.data[index].episode;
                          final c = episode.backgroudColor(context);
                          return SizedBox(
                            height: 90.0,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: Center(
                                    child: ListTile(
                                      contentPadding:
                                          EdgeInsets.fromLTRB(24, 8, 20, 8),
                                      onTap: () => audio.episodeLoad(episode),
                                      leading: CircleAvatar(
                                          backgroundColor: c.withOpacity(0.5),
                                          backgroundImage: episode.avatarImage),
                                      title: Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 5.0),
                                        child: Text(
                                          snapshot.data[index].title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      subtitle: Container(
                                        height: 35,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            if (seekValue < 0.9)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5.0),
                                                child: Material(
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    onTap: () async {
                                                      audio.episodeLoad(episode,
                                                          startPosition:
                                                              (seconds * 1000)
                                                                  .toInt());
                                                    },
                                                    child: Stack(children: [
                                                      ShaderMask(
                                                        shaderCallback:
                                                            (bounds) {
                                                          return LinearGradient(
                                                            begin: Alignment
                                                                .centerLeft,
                                                            colors: <Color>[
                                                              Colors.cyan[600]
                                                                  .withOpacity(
                                                                      0.8),
                                                              Colors.white70
                                                            ],
                                                            stops: [
                                                              seekValue,
                                                              seekValue
                                                            ],
                                                            tileMode:
                                                                TileMode.mirror,
                                                          ).createShader(
                                                              bounds);
                                                        },
                                                        child: Container(
                                                          height: 25,
                                                          alignment:
                                                              Alignment.center,
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      20),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                    Radius.circular(
                                                                        20.0)),
                                                            color: context
                                                                .accentColor,
                                                          ),
                                                          child: Text(
                                                            seconds.toTime,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                      ),
                                                    ]),
                                                  ),
                                                ),
                                              ),
                                            SizedBox(
                                              child: Selector<
                                                  AudioPlayerNotifier,
                                                  Tuple2<List<EpisodeBrief>,
                                                      bool>>(
                                                selector: (_, audio) => Tuple2(
                                                    audio.queue.playlist,
                                                    audio.queueUpdate),
                                                builder: (_, data, __) {
                                                  return data.item1
                                                          .contains(episode)
                                                      ? IconButton(
                                                          icon: Icon(
                                                              Icons
                                                                  .playlist_add_check,
                                                              color: context
                                                                  .accentColor),
                                                          onPressed: () async {
                                                            audio
                                                                .delFromPlaylist(
                                                                    episode);
                                                            Fluttertoast
                                                                .showToast(
                                                              msg: s
                                                                  .toastRemovePlaylist,
                                                              gravity:
                                                                  ToastGravity
                                                                      .BOTTOM,
                                                            );
                                                          })
                                                      : IconButton(
                                                          icon: Icon(
                                                              Icons
                                                                  .playlist_add,
                                                              color: Colors
                                                                  .grey[700]),
                                                          onPressed: () async {
                                                            audio.addToPlaylist(
                                                                episode);
                                                            Fluttertoast
                                                                .showToast(
                                                              msg: s
                                                                  .toastAddPlaylist,
                                                              gravity:
                                                                  ToastGravity
                                                                      .BOTTOM,
                                                            );
                                                          });
                                                },
                                              ),
                                            ),
                                            Spacer(),
                                            Text(
                                              date.toDate(context),
                                              style: TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Divider(height: 1)
                              ],
                            ),
                          );
                        }
                      }),
                )
              : Center(
                  child: SizedBox(
                      height: 25,
                      width: 25,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      )),
                );
        });
  }
}
