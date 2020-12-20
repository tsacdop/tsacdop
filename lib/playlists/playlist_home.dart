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
                            data.item4 != null
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0),
                                    child: Text(data.item4.title, maxLines: 1),
                                  )
                                : Center(),
                          ],
                        )),
                        data.item3 != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                    width: 80,
                                    height: 80,
                                    child:
                                        Image(image: data.item4.avatarImage)),
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
                        label: 'Play Next',
                        color: Colors.blue,
                        isSelected: _selected == 'PlayNext',
                        onTap: () => setState(() {
                              _body = _Queue();
                              _selected = 'PlayNext';
                            })),
                    _tabWidget(
                        icon: Icon(Icons.history),
                        label: 'History',
                        color: Colors.green,
                        isSelected: _selected == 'Histtory',
                        onTap: () => setState(() {
                              _body = _History();
                              _selected = 'Histtory';
                            })),
                    _tabWidget(
                        icon: Icon(Icons.playlist_play),
                        label: 'Playlists',
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
    final s = context.s;
    return Selector<AudioPlayerNotifier, Tuple2<Playlist, bool>>(
        selector: (_, audio) => Tuple2(audio.playlist, audio.playerRunning),
        builder: (_, data, __) {
          var episodes = data.item1.episodes.toSet().toList();
          var queue = data.item1;
          return queue.name == 'Queue'
              ? ReorderableListView(
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
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
                            return Container(
                              key: ValueKey('sd'),
                            );
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
                    final c = episode.backgroudColor(context);
                    return SizedBox(
                      height: 90.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Expanded(
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                              onTap: () async {
                                await context
                                    .read<AudioPlayerNotifier>()
                                    .episodeLoad(episode);
                              },
                              title: Container(
                                padding: EdgeInsets.fromLTRB(0, 5.0, 20.0, 5.0),
                                child: Text(
                                  episode.title,
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
                                      backgroundImage: episode.avatarImage),
                                ],
                              ),
                              subtitle: Container(
                                padding: EdgeInsets.only(top: 5, bottom: 5),
                                height: 35,
                                child: Row(
                                  children: <Widget>[
                                    if (episode.explicit == 1)
                                      Container(
                                          decoration: BoxDecoration(
                                              color: Colors.red[800],
                                              shape: BoxShape.circle),
                                          height: 25.0,
                                          width: 25.0,
                                          margin: EdgeInsets.only(right: 10.0),
                                          alignment: Alignment.center,
                                          child: Text('E',
                                              style: TextStyle(
                                                  color: Colors.white))),
                                    if (episode.duration != 0)
                                      episodeTag(
                                          episode.duration == 0
                                              ? ''
                                              : s.minsCount(
                                                  episode.duration ~/ 60),
                                          Colors.cyan[300]),
                                    if (episode.enclosureLength != null)
                                      episodeTag(
                                          episode.enclosureLength == 0
                                              ? ''
                                              : '${(episode.enclosureLength) ~/ 1000000}MB',
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
                        );
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
                                  'Queue',
                                  style: context.textTheme.headline6,
                                ),
                                Text('${queue.episodes.length} episodes'),
                                OutlinedButton(
                                    onPressed: () {
                                      context
                                          .read<AudioPlayerNotifier>()
                                          .playlistLoad(queue);
                                    },
                                    child: Text('Play'))
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
                      subtitle: Text(episodeList.isNotEmpty
                          ? s.episode(data[index].episodeList.length)
                          : '0 episode'),
                      trailing: IconButton(
                        splashRadius: 20,
                        icon: Icon(Icons.play_arrow),
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
                    title: Text('Create new playlist'),
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
  String _playlistName = '';
  NewPlaylistOption _option;
  int _error;

  @override
  void initState() {
    super.initState();
    _option = NewPlaylistOption.blank;
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
              if (context
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
                  case NewPlaylistOption.randon10:
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
        title:
            SizedBox(width: context.width - 160, child: Text('New playlist')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                hintText: 'New playlist',
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
              child: (_error == 1)
                  ? Text(
                      'Playlist existed',
                      style: TextStyle(color: Colors.red[400]),
                    )
                  : Center(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _createOption(NewPlaylistOption.blank),
                _createOption(NewPlaylistOption.randon10),
                _createOption(NewPlaylistOption.latest10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
