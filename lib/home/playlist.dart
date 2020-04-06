import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tsacdop/episodes/episodedetail.dart';
import 'package:tuple/tuple.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';

import 'package:tsacdop/class/audiostate.dart';
import 'package:tsacdop/class/episodebrief.dart';
import 'package:tsacdop/util/context_extension.dart';
import 'package:tsacdop/home/audioplayer.dart';

class PlaylistPage extends StatefulWidget {
  @override
  _PlaylistPageState createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  final textstyle = TextStyle(fontSize: 15.0, color: Colors.black);

  int _sumPlaylistLength(List<EpisodeBrief> episodes) {
    int sum = 0;
    if (episodes.length == 0) {
      return sum;
    } else {
      episodes.forEach((episode) {
        sum += episode.duration;
      });
      return sum;
    }
  }

  ScrollController _controller;
  _scrollListener() {
    double value = _controller.offset;
    setState(() => _topHeight = (100 - value) > 60 ? 100 - value : 60);
  }

  double _topHeight;

  @override
  void initState() {
    super.initState();
    _topHeight = 100;
    _controller = ScrollController()..addListener(_scrollListener);
  }

  @override
  void dispose() {
    _controller.removeListener(_scrollListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          title: _topHeight == 60 ? Text('Playlist') : Center(),
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: SafeArea(
          child: Selector<AudioPlayerNotifier, Tuple3<Playlist, bool, bool>>(
            selector: (_, audio) =>
                Tuple3(audio.queue, audio.playerRunning, audio.queueUpdate),
            builder: (_, data, __) {
              print('update');
              final List<EpisodeBrief> episodes = data.item1.playlist;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: _topHeight,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: _topHeight,
                            padding: EdgeInsets.only(
                              left: 60,
                            ),
                            alignment: Alignment.centerLeft,
                            child: RichText(
                              text: TextSpan(
                                text: _topHeight > 90 ? 'Playlist\n' : '',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .color,
                                  fontSize: 30,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: episodes.length.toString(),
                                    style: GoogleFonts.cairo(
                                      textStyle: TextStyle(
                                        color: Theme.of(context).accentColor,
                                        fontSize: 25,
                                      ),
                                    ),
                                  ),
                                  TextSpan(
                                      text: episodes.length < 2
                                          ? 'episode'
                                          : 'episodes',
                                      style: TextStyle(
                                        color: Theme.of(context).accentColor,
                                        fontSize: 15,
                                      )),
                                  TextSpan(
                                    text:
                                        _sumPlaylistLength(episodes).toString(),
                                    style: GoogleFonts.cairo(
                                        textStyle: TextStyle(
                                      color: Theme.of(context).accentColor,
                                      fontSize: 25,
                                    )),
                                  ),
                                  TextSpan(
                                      text: 'mins',
                                      style: TextStyle(
                                        color: Theme.of(context).accentColor,
                                        fontSize: 15,
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: EdgeInsets.all(5.0),
                            margin: EdgeInsets.only(right: 20.0, bottom: 5.0),
                            decoration: data.item2 ? BoxDecoration(
                              color: context.brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[200],
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                            ) :
                            BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.transparent
                            ),
                            child: data.item2
                                ? _topHeight < 90
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          CircleAvatar(
                                            radius: 12,
                                            backgroundImage: FileImage(File(
                                                "${episodes.first.imagePath}")),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 15),
                                            child: SizedBox(
                                                width: 20,
                                                height: 15,
                                                child: WaveLoader()),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          CircleAvatar(
                                            radius: 15,
                                            //backgroundColor: _c.withOpacity(0.5),
                                            backgroundImage: FileImage(File(
                                                "${episodes.first.imagePath}")),
                                          ),
                                          Container(
                                            width: 150,
                                            alignment: Alignment.center,
                                            child: Text(
                                              episodes.first.title,
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
                                                child: WaveLoader()),
                                          ),
                                        ],
                                      )
                                : IconButton(
                                  padding: EdgeInsets.all(0),
                                  alignment: Alignment.center,
                                    icon: Icon(Icons.play_circle_filled,
                                        size: 40,
                                        color: Theme.of(context).accentColor),
                                    onPressed: () {
                                      audio.playlistLoad();
                                      // setState(() {});
                                    }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 3,
                  ),
                  Expanded(
                    child: ReorderableListView(
                        scrollController: _controller,
                        onReorder: (int oldIndex, int newIndex) {
                          if (newIndex > oldIndex) {
                            newIndex -= 1;
                          }
                          final EpisodeBrief episodeRemove = episodes[oldIndex];
                          audio.delFromPlaylist(episodeRemove);
                          audio.addToPlaylistAt(episodeRemove, newIndex);
                          setState(() {});
                        },
                        scrollDirection: Axis.vertical,
                        children: data.item2
                            ? episodes.map<Widget>((episode) {
                                if (episode.enclosureUrl !=
                                    episodes.first.enclosureUrl)
                                  return DismissibleContainer(
                                    episode: episode,
                                    key: ValueKey(episode.enclosureUrl),
                                  );
                                else
                                  return Container(
                                    key: ValueKey('sd'),
                                  );
                              }).toList()
                            : episodes
                                .map<Widget>((episode) => DismissibleContainer(
                                      episode: episode,
                                      key: ValueKey(episode.enclosureUrl),
                                    ))
                                .toList()),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class DismissibleContainer extends StatefulWidget {
  final EpisodeBrief episode;
  DismissibleContainer({this.episode, Key key}) : super(key: key);

  @override
  _DismissibleContainerState createState() => _DismissibleContainerState();
}

class _DismissibleContainerState extends State<DismissibleContainer> {
  bool _delete;
  Widget _episodeTag(String text, Color color) {
    return Container(
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.all(Radius.circular(15.0))),
      height: 23.0,
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
    var audio = Provider.of<AudioPlayerNotifier>(context, listen: false);
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      alignment: Alignment.center,
      height: _delete ? 0 : 95.0,
      child: _delete
          ? Container(
              color: Colors.transparent,
            )
          : Dismissible(
              key: ValueKey(widget.episode.enclosureUrl + 't'),
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
                height: 50,
                color: Theme.of(context).accentColor,
              ),
              onDismissed: (direction) async {
                setState(() {
                  _delete = true;
                });
                int index = await audio.delFromPlaylist(widget.episode);
                final episodeRemove = widget.episode;
                 
                Fluttertoast.showToast(
                  msg: 'Removed From Playlist',
                  gravity: ToastGravity.BOTTOM,
                );
                Scaffold.of(context).showSnackBar(SnackBar(
                  backgroundColor: Colors.grey[800],
                  content: Text('Episode removed', style: TextStyle(color: Colors.white)),
                  action: SnackBarAction(
                      textColor: context.accentColor,
                      label: 'Undo',
                      onPressed: () {
                        audio.addToPlaylistAt(episodeRemove, index);
                      }),
                ));
              },
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Container(
                      padding: EdgeInsets.only(top: 10.0, bottom: 5.0),
                      child: Text(
                        widget.episode.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    leading: CircleAvatar(
                      //backgroundColor: _c.withOpacity(0.5),
                      backgroundImage:
                          FileImage(File("${widget.episode.imagePath}")),
                    ),
                    subtitle: Container(
                      padding: EdgeInsets.only(top: 5, bottom: 10),
                      child: Row(
                        children: <Widget>[
                          (widget.episode.explicit == 1)
                              ? Container(
                                  decoration: BoxDecoration(
                                      color: Colors.red[800],
                                      shape: BoxShape.circle),
                                  height: 20.0,
                                  width: 20.0,
                                  margin: EdgeInsets.only(right: 10.0),
                                  alignment: Alignment.center,
                                  child: Text('E',
                                      style: TextStyle(color: Colors.white)))
                              : Center(),
                          widget.episode.duration != 0
                              ? _episodeTag(
                                  (widget.episode.duration).toString() + 'mins',
                                  Colors.cyan[300])
                              : Center(),
                          widget.episode.enclosureLength != null
                              ? _episodeTag(
                                  ((widget.episode.enclosureLength) ~/ 1000000)
                                          .toString() +
                                      'MB',
                                  Colors.lightBlue[300])
                              : Center(),
                        ],
                      ),
                    ),
                    trailing: Icon(Icons.menu),
                  ),
                  // Divider(
                  //   height: 2,
                  // ),
                ],
              ),
            ),
    );
  }
}
