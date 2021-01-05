import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../local_storage/sqflite_localpodcast.dart';
import '../state/audio_state.dart';
import '../type/episodebrief.dart';
import '../type/play_histroy.dart';
import '../type/playlist.dart';
import '../util/extension_helper.dart';
import '../widgets/custom_widget.dart';
import '../widgets/dismissible_container.dart';
import 'playlist_page.dart';

class PlaylistHome extends StatefulWidget {
  PlaylistHome({Key key}) : super(key: key);

  @override
  _PlaylistHomeState createState() => _PlaylistHomeState();
}

class _PlaylistHomeState extends State<PlaylistHome> {
  Widget _body;
  String _selected;

  @override
  void initState() {
    super.initState();
    _selected = 'PlayNext';
    _body = _Queue();
  }

  Widget _tabWidget(
      {Widget icon,
      String label,
      Function onTap,
      bool isSelected,
      Color color}) {
    return OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
            side: BorderSide(color: context.scaffoldBackgroundColor),
            primary: color,
            backgroundColor:
                isSelected ? context.primaryColorDark : Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(100)))),
        icon: icon,
        label: isSelected ? Text(label) : Center(),
        onPressed: onTap);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarIconBrightness:
            Theme.of(context).accentColorBrightness,
        statusBarIconBrightness: Theme.of(context).accentColorBrightness,
        systemNavigationBarColor: Theme.of(context).primaryColor,
      ),
      child: Scaffold(
          appBar: AppBar(
            leading: CustomBackButton(),
            centerTitle: true,
            title: Selector<AudioPlayerNotifier, EpisodeBrief>(
              selector: (_, audio) => audio.episode,
              builder: (_, data, __) {
                return Text(data?.title ?? '', maxLines: 1);
              },
            ),
            backgroundColor: context.scaffoldBackgroundColor,
          ),
          body: Column(
            children: [
              SizedBox(
                height: 100,
                child: Selector<AudioPlayerNotifier,
                    Tuple4<Playlist, bool, bool, EpisodeBrief>>(
                  selector: (_, audio) => Tuple4(audio.playlist,
                      audio.playerRunning, audio.playing, audio.episode),
                  builder: (_, data, __) {
                    final running = data.item2;
                    final playing = data.item3;
                    final audio = context.read<AudioPlayerNotifier>();
                    return Row(
                      children: [
                        Expanded(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                IconButton(
                                    icon: Icon(Icons.fast_rewind),
                                    onPressed: () {
                                      if (running) {
                                        audio.rewind();
                                      }
                                    }),
                                SizedBox(width: 30),
                                IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: Icon(
                                        playing
                                            ? LineIcons.pause_solid
                                            : LineIcons.play_solid,
                                        size: 40),
                                    onPressed: () {
                                      if (running) {
                                        playing
                                            ? audio.pauseAduio()
                                            : audio.resumeAudio();
                                      } else {
                                        context
                                            .read<AudioPlayerNotifier>()
                                            .playFromLastPosition();
                                      }
                                    }),
                                SizedBox(width: 30),
                                IconButton(
                                    icon: Icon(Icons.fast_forward),
                                    onPressed: () {
                                      if (running) {
                                        audio.fastForward();
                                      }
                                    })
                              ],
                            ),
                            if (data.item2)
                              Selector<AudioPlayerNotifier,
                                  Tuple3<bool, double, String>>(
                                selector: (_, audio) => Tuple3(
                                    audio.buffering,
                                    (audio.backgroundAudioDuration -
                                            audio.backgroundAudioPosition) /
                                        1000,
                                    audio.remoteErrorMessage),
                                builder: (_, data, __) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: data.item3 != null
                                        ? Text(data.item3,
                                            style: const TextStyle(
                                                color: Color(0xFFFF0000)))
                                        : data.item1
                                            ? Text(
                                                s.buffering,
                                                style: TextStyle(
                                                    color: context.accentColor),
                                              )
                                            : Text(
                                                s.timeLeft((data.item2)
                                                        .toInt()
                                                        .toTime ??
                                                    ''),
                                                maxLines: 2,
                                              ),
                                  );
                                },
                              )
                          ],
                        )),
                        data.item4 != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: InkWell(
                                  onTap: () {
                                    if (running) {
                                      context
                                          .read<AudioPlayerNotifier>()
                                          .playNext();
                                    }
                                  },
                                  child: SizedBox(
                                      width: 80,
                                      height: 80,
                                      child:
                                          Image(image: data.item4.avatarImage)),
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                    color: context.accentColor.withAlpha(70),
                                    borderRadius: BorderRadius.circular(10)),
                                width: 80,
                                height: 80),
                        SizedBox(
                          width: 20,
                        ),
                      ],
                    );
                  },
                ),
              ),
              SizedBox(
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _tabWidget(
                        icon: Icon(Icons.queue_music_rounded),
                        label: s.playNext,
                        color: Colors.blue,
                        isSelected: _selected == 'PlayNext',
                        onTap: () => setState(() {
                              _body = _Queue();
                              _selected = 'PlayNext';
                            })),
                    _tabWidget(
                        icon: Icon(Icons.history),
                        label: s.settingsHistory,
                        color: Colors.green,
                        isSelected: _selected == 'History',
                        onTap: () => setState(() {
                              _body = _History();
                              _selected = 'History';
                            })),
                    _tabWidget(
                        icon: Icon(Icons.playlist_play),
                        label: s.playlists,
                        color: Colors.purple,
                        isSelected: _selected == 'Playlists',
                        onTap: () => setState(() {
                              _body = _Playlists();
                              _selected = 'Playlists';
                            })),
                  ],
                ),
              ),
              Divider(height: 1),
              Expanded(
                  child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 300), child: _body))
            ],
          )),
    );
  }
}

class _Queue extends StatefulWidget {
  const _Queue({Key key}) : super(key: key);

  @override
  __QueueState createState() => __QueueState();
}

class __QueueState extends State<_Queue> {
  @override
  Widget build(BuildContext context) {
    return Selector<AudioPlayerNotifier, Tuple3<Playlist, bool, EpisodeBrief>>(
        selector: (_, audio) =>
            Tuple3(audio.playlist, audio.playerRunning, audio.episode),
        builder: (_, data, __) {
          var episodes = data.item1.episodes.toSet().toList();
          var queue = data.item1;
          var running = data.item2;
          return queue.name == 'Queue'
              ? ReorderableListView(
                  onReorder: (oldIndex, newIndex) {
                    context
                        .read<AudioPlayerNotifier>()
                        .reorderPlaylist(oldIndex, newIndex);
                    setState(() {});
                  },
                  scrollDirection: Axis.vertical,
                  children: data.item2
                      ? episodes.map<Widget>((episode) {
                          if (episode.enclosureUrl !=
                              episodes.first.enclosureUrl) {
                            return DismissibleContainer(
                              episode: episode,
                              onRemove: (value) => setState(() {}),
                              key: ValueKey(episode.enclosureUrl),
                            );
                          } else {
                            return EpisodeCard(episode,
                                key: ValueKey('playing'),
                                isPlaying: true,
                                canReorder: true,
                                tileColor: context.primaryColorDark);
                          }
                        }).toList()
                      : episodes
                          .map<Widget>((episode) => DismissibleContainer(
                                episode: episode,
                                onRemove: (value) => setState(() {}),
                                key: ValueKey(episode.enclosureUrl),
                              ))
                          .toList())
              : ListView.builder(
                  itemCount: queue.episodeList.length,
                  itemBuilder: (context, index) {
                    final episode = queue.episodes[index];
                    final isPlaying =
                        data.item3 != null && data.item3 == episode;
                    return EpisodeCard(
                      episode,
                      isPlaying: isPlaying && running,
                      tileColor: isPlaying ? context.primaryColorDark : null,
                      onTap: () async {
                        if (!isPlaying) {
                          await context
                              .read<AudioPlayerNotifier>()
                              .loadEpisodeFromPlaylist(episode);
                        }
                      },
                    );
                  });
        });
  }
}

class _History extends StatefulWidget {
  const _History({Key key}) : super(key: key);

  @override
  __HistoryState createState() => __HistoryState();
}

class __HistoryState extends State<_History> {
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

  Future<void> _loadMoreData() async {
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
                          final c = episode?.backgroudColor(context);
                          return episode == null
                              ? Center()
                              : SizedBox(
                                  height: 90.0,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Expanded(
                                        child: Center(
                                          child: ListTile(
                                            contentPadding: EdgeInsets.fromLTRB(
                                                24, 8, 20, 8),
                                            onTap: () => audio.episodeLoad(
                                                episode,
                                                startPosition: seekValue < 0.9
                                                    ? (seconds * 1000).toInt()
                                                    : 0),
                                            leading: CircleAvatar(
                                                backgroundColor:
                                                    c?.withOpacity(0.5),
                                                backgroundImage:
                                                    episode.avatarImage),
                                            title: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 5.0),
                                              child: Text(
                                                snapshot.data[index].title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            subtitle: SizedBox(
                                              height: 40,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  if (seekValue < 0.9)
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 5.0),
                                                      child: Material(
                                                        color:
                                                            Colors.transparent,
                                                        child: InkWell(
                                                          onTap: () {
                                                            audio.episodeLoad(
                                                                episode,
                                                                startPosition:
                                                                    (seconds *
                                                                            1000)
                                                                        .toInt());
                                                          },
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                          child: Stack(
                                                              children: [
                                                                ShaderMask(
                                                                  shaderCallback:
                                                                      (bounds) {
                                                                    return LinearGradient(
                                                                      begin: Alignment
                                                                          .centerLeft,
                                                                      colors: <
                                                                          Color>[
                                                                        Colors
                                                                            .cyan[600]
                                                                            .withOpacity(0.8),
                                                                        Colors
                                                                            .white70
                                                                      ],
                                                                      stops: [
                                                                        seekValue,
                                                                        seekValue
                                                                      ],
                                                                      tileMode:
                                                                          TileMode
                                                                              .mirror,
                                                                    ).createShader(
                                                                        bounds);
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    height: 25,
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    padding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            20),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              20.0),
                                                                      color: context
                                                                          .accentColor,
                                                                    ),
                                                                    child: Text(
                                                                      seconds
                                                                          .toTime,
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.white),
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
                                                        List<EpisodeBrief>>(
                                                      selector: (_, audio) =>
                                                          audio.queue.episodes,
                                                      builder: (_, data, __) {
                                                        return data.contains(
                                                                episode)
                                                            ? IconButton(
                                                                icon: Icon(
                                                                    Icons
                                                                        .playlist_add_check,
                                                                    color: context
                                                                        .accentColor),
                                                                onPressed:
                                                                    () async {
                                                                  audio.delFromPlaylist(
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
                                                                            .grey[
                                                                        700]),
                                                                onPressed:
                                                                    () async {
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
                      child: CircularProgressIndicator()),
                );
        });
  }
}

class _Playlists extends StatefulWidget {
  const _Playlists({Key key}) : super(key: key);

  @override
  __PlaylistsState createState() => __PlaylistsState();
}

class __PlaylistsState extends State<_Playlists> {
  Future<EpisodeBrief> _getEpisode(String url) async {
    var dbHelper = DBHelper();
    return await dbHelper.getRssItemWithUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Selector<AudioPlayerNotifier, List<Playlist>>(
        selector: (_, audio) => audio.playlists,
        builder: (_, data, __) {
          return ScrollConfiguration(
            behavior: NoGrowBehavior(),
            child: ListView.builder(
                itemCount: data.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    final queue = data.first;
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              fullscreenDialog: true,
                              builder: (context) =>
                                  PlaylistDetail(data[index])),
                        ).then((value) => setState(() {}));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          children: [
                            Container(
                              height: 80,
                              width: 80,
                              color: context.primaryColorDark,
                              child: GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    childAspectRatio: 1,
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 0.0,
                                    crossAxisSpacing: 0.0,
                                  ),
                                  itemCount: math.min(queue.episodes.length, 4),
                                  itemBuilder: (_, index) {
                                    if (index < queue.episodeList.length) {
                                      return Image(
                                        image:
                                            queue.episodes[index].avatarImage,
                                      );
                                    }
                                    return Center();
                                  }),
                            ),
                            SizedBox(width: 15),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.queue,
                                  style: context.textTheme.headline6,
                                ),
                                Text('${queue.length} ${s.episode(queue.length).toLowerCase()}'),
                                TextButton(
                                    style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                            color: context.primaryColorDark),
                                        primary: context.accentColor,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(100)))),
                                    onPressed: () {
                                      context
                                          .read<AudioPlayerNotifier>()
                                          .playlistLoad(queue);
                                    },
                                    child: Text(s.play))
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  }
                  if (index < data.length) {
                    final episodeList = data[index].episodeList;
                    return ListTile(
                      onTap: () async {
                        await context
                            .read<AudioPlayerNotifier>()
                            .updatePlaylist(data[index], updateEpisodes: true);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              fullscreenDialog: true,
                              builder: (context) =>
                                  PlaylistDetail(data[index])),
                        );
                      },
                      leading: Container(
                        height: 50,
                        width: 50,
                        color: context.primaryColorDark,
                        child: episodeList.isEmpty
                            ? Center()
                            : FutureBuilder<EpisodeBrief>(
                                future: _getEpisode(episodeList.first),
                                builder: (_, snapshot) {
                                  if (snapshot.data != null) {
                                    return SizedBox(
                                        height: 50,
                                        width: 50,
                                        child: Image(
                                            image: snapshot.data.avatarImage));
                                  }
                                  return Center();
                                }),
                      ),
                      title: Text(data[index].name),
                      subtitle: Text(
                          '${data[index].length} ${s.episode(data[index].length).toLowerCase()}'),
                      trailing: IconButton(
                        splashRadius: 20,
                        icon: Icon(LineIcons.play_circle_solid, size: 30),
                        onPressed: () {
                          context
                              .read<AudioPlayerNotifier>()
                              .playlistLoad(data[index]);
                        },
                      ),
                    );
                  }
                  return ListTile(
                    onTap: () {
                      showGeneralDialog(
                          context: context,
                          barrierDismissible: true,
                          barrierLabel: MaterialLocalizations.of(context)
                              .modalBarrierDismissLabel,
                          barrierColor: Colors.black54,
                          transitionDuration: const Duration(milliseconds: 200),
                          pageBuilder:
                              (context, animaiton, secondaryAnimation) =>
                                  _NewPlaylist());
                    },
                    leading: Container(
                      height: 50,
                      width: 50,
                      color: context.primaryColorDark,
                      child: Center(child: Icon(Icons.add)),
                    ),
                    title: Text(s.createNewPlaylist),
                  );
                }),
          );
        });
  }
}

enum NewPlaylistOption { blank, randon10, latest10 }

class _NewPlaylist extends StatefulWidget {
  _NewPlaylist({Key key}) : super(key: key);

  @override
  __NewPlaylistState createState() => __NewPlaylistState();
}

class __NewPlaylistState extends State<_NewPlaylist> {
  final _dbHelper = DBHelper();
  String _playlistName = '';
  NewPlaylistOption _option;
  int _error;

  @override
  void initState() {
    super.initState();
    _option = NewPlaylistOption.blank;
  }

  Future<List<EpisodeBrief>> _random() async {
    return await _dbHelper.getRandomRssItem(10);
  }

  Future<List<EpisodeBrief>> _recent() async {
    return await _dbHelper.getRecentRssItem(10);
  }

  Widget _createOption(NewPlaylistOption option) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          setState(() => _option = option);
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: _option == option
                  ? context.accentColor
                  : context.primaryColorDark),
          height: 32,
          child: Center(
              child: Text(_optionLabel(option).first,
                  style: TextStyle(
                      color: _option == option
                          ? Colors.white
                          : context.textColor))),
        ),
      ),
    );
  }

  List<String> _optionLabel(NewPlaylistOption option) {
    switch (option) {
      case NewPlaylistOption.blank:
        return ['Empty', 'Add episodes later'];
        break;
      case NewPlaylistOption.randon10:
        return ['Randon 10', 'Add 10 random episodes to playlists'];
        break;
      case NewPlaylistOption.latest10:
        return ['Latest 10', 'Add 10 latest updated episodes to playlist'];
        break;
      default:
        return ['', ''];
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor:
            Theme.of(context).brightness == Brightness.light
                ? Color.fromRGBO(113, 113, 113, 1)
                : Color.fromRGBO(5, 5, 5, 1),
      ),
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 1,
        contentPadding: EdgeInsets.symmetric(horizontal: 20),
        titlePadding: EdgeInsets.all(20),
        actionsPadding: EdgeInsets.zero,
        actions: <Widget>[
          FlatButton(
            splashColor: context.accentColor.withAlpha(70),
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              s.cancel,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          FlatButton(
            splashColor: context.accentColor.withAlpha(70),
            onPressed: () async {
              if (_playlistName == '') {
                setState(() => _error = 0);
              } else if (context
                  .read<AudioPlayerNotifier>()
                  .playlistExisted(_playlistName)) {
                setState(() => _error = 1);
              } else {
                var playlist;
                switch (_option) {
                  case NewPlaylistOption.blank:
                    playlist = Playlist(
                      _playlistName,
                    );
                    break;
                  case NewPlaylistOption.latest10:
                    final recent = await _recent();
                    playlist = Playlist(
                      _playlistName,
                      episodeList: [for (var e in recent) e.enclosureUrl],
                    );
                    await playlist.getPlaylist();
                    break;
                  case NewPlaylistOption.randon10:
                    final random = await _random();
                    playlist = Playlist(
                      _playlistName,
                      episodeList: [for (var e in random) e.enclosureUrl],
                    );
                    await playlist.getPlaylist();
                    break;
                  default:
                    break;
                }
                context.read<AudioPlayerNotifier>().addPlaylist(playlist);
                Navigator.of(context).pop();
              }
            },
            child:
                Text(s.confirm, style: TextStyle(color: context.accentColor)),
          )
        ],
        title: SizedBox(
            width: context.width - 160, child: Text(s.createNewPlaylist)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                hintText: s.createNewPlaylist,
                hintStyle: TextStyle(fontSize: 18),
                filled: true,
                focusedBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: context.accentColor, width: 2.0),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: context.accentColor, width: 2.0),
                ),
              ),
              cursorRadius: Radius.circular(2),
              autofocus: true,
              maxLines: 1,
              onChanged: (value) {
                _playlistName = value;
              },
            ),
            Container(
                alignment: Alignment.centerLeft,
                child: _error != null
                    ? Text(
                        _error == 1 ? s.playlistExisted : s.playlistNameEmpty,
                        style: TextStyle(color: Colors.red[400]),
                      )
                    : Center()),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _createOption(NewPlaylistOption.blank),
                  _createOption(NewPlaylistOption.randon10),
                  _createOption(NewPlaylistOption.latest10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
