import 'dart:io';
import 'dart:math' as math;

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
import 'package:tsacdop/util/colorize.dart';

class PlaylistPage extends StatefulWidget {
  @override
  _PlaylistPageState createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  final GlobalKey<AnimatedListState> _playlistKey = GlobalKey();
  final textstyle = TextStyle(fontSize: 15.0, color: Colors.black);

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
    setState(() => _topHeight = (100 - value) > 0 ? 100 - value : 0);
  }

  double _topHeight;

  @override
  void initState() {
    super.initState();
    _topHeight = 100;
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
  }

  @override
  void dispose() {
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
          title: _topHeight == 0 ? Text('Playlist') : Center(),
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: SafeArea(
          child:
              Selector<AudioPlayerNotifier, Tuple2<List<EpisodeBrief>, bool>>(
            selector: (_, audio) =>
                Tuple2(audio.queue.playlist, audio.playerRunning),
            builder: (_, data, __) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Transform.scale(
                    alignment: Alignment.topLeft,
                    scale: _topHeight / 100,
                    child: Container(
                      height: _topHeight,
                      padding: EdgeInsets.only(
                          bottom: (_topHeight - 60) > 0 ? _topHeight - 60 : 0,
                          left: 60),
                      alignment: Alignment.bottomLeft,
                      child: RichText(
                        text: TextSpan(
                          text: 'Total  ',
                          style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontSize: 20,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                                text: data.item1.length.toString(),
                                style: TextStyle(
                                  color: Theme.of(context).accentColor,
                                  fontSize: 40,
                                )),
                            TextSpan(
                                text: data.item1.length < 2
                                    ? ' episode'
                                    : ' episodes ',
                                style: TextStyle(
                                  color: Theme.of(context).accentColor,
                                  fontSize: 20,
                                )),
                            TextSpan(
                              text: _sumPlaylistLength(data.item1).toString(),
                              style: GoogleFonts.teko(
                                  textStyle: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontSize: 60,
                              )),
                            ),
                            TextSpan(
                                text: ' mins',
                                style: TextStyle(
                                  color: Theme.of(context).accentColor,
                                  fontSize: 20,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: AnimatedList(
                        controller: _controller,
                        key: _playlistKey,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        initialItemCount: data.item1.length,
                        itemBuilder: (context, index, animation) {
                          Color _c = (Theme.of(context).brightness ==
                                  Brightness.light)
                              ? data.item1[index].primaryColor.colorizedark()
                              : data.item1[index].primaryColor.colorizeLight();
                          return ScaleTransition(
                            alignment: Alignment.centerLeft,
                            scale: animation,
                            child: Dismissible(
                              background: Container(
                                padding: EdgeInsets.symmetric(horizontal: 20.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.red),
                                      padding: EdgeInsets.all(5),
                                      child: Icon(
                                        LineIcons.trash_alt_solid,
                                        color: Colors.white,
                                        size: 15,
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.red),
                                      padding: EdgeInsets.all(5),
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
                              key: Key(data.item1[index].enclosureUrl),
                              onDismissed: (direction) async {
                                await audio.delFromPlaylist(data.item1[index]);
                                _playlistKey.currentState.removeItem(
                                    index, (context, animation) => Center());
                                Fluttertoast.showToast(
                                  msg: 'Removed From Playlist',
                                  gravity: ToastGravity.BOTTOM,
                                );
                              },
                              child: Column(
                                children: <Widget>[
                                  ListTile(
                                    title: Container(
                                      padding: EdgeInsets.only(
                                          top: 10.0, bottom: 5.0),
                                      child: Text(
                                        data.item1[index].title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    leading: CircleAvatar(
                                      backgroundColor: _c.withOpacity(0.5),
                                      backgroundImage: FileImage(File(
                                          "${data.item1[index].imagePath}")),
                                    ),
                                    trailing: index == 0
                                        ? data.item2
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 12.0),
                                                child: SizedBox(
                                                    width: 20,
                                                    height: 15,
                                                    child: WaveLoader()),
                                              )
                                            : IconButton(
                                                icon: Icon(Icons.play_arrow),
                                                onPressed: () =>
                                                    audio.playlistLoad())
                                        : Transform.rotate(
                                            angle: math.pi,
                                            child: IconButton(
                                                tooltip: 'Move to Top',
                                                icon: Icon(
                                                    LineIcons.download_solid),
                                                onPressed: () async {
                                                  await audio.moveToTop(
                                                      data.item1[index]);
                                                  _playlistKey.currentState
                                                      .removeItem(
                                                          index,
                                                          (context,
                                                                  animation) =>
                                                              Container());
                                                  data.item2
                                                      ? _playlistKey
                                                          .currentState
                                                          .insertItem(1)
                                                      : _playlistKey
                                                          .currentState
                                                          .insertItem(0);
                                                }),
                                          ),
                                    subtitle: Container(
                                      padding:
                                          EdgeInsets.only(top: 5, bottom: 10),
                                      child: Row(
                                        children: <Widget>[
                                          (data.item1[index].explicit == 1)
                                              ? Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.red[800],
                                                      shape: BoxShape.circle),
                                                  height: 20.0,
                                                  width: 20.0,
                                                  margin: EdgeInsets.only(
                                                      right: 10.0),
                                                  alignment: Alignment.center,
                                                  child: Text('E',
                                                      style: TextStyle(
                                                          color: Colors.white)))
                                              : Center(),
                                          data.item1[index].duration != 0
                                              ? _episodeTag(
                                                  (data.item1[index].duration)
                                                          .toString() +
                                                      'mins',
                                                  Colors.cyan[300])
                                              : Center(),
                                          data.item1[index].enclosureLength !=
                                                  null
                                              ? _episodeTag(
                                                  ((data.item1[index]
                                                                  .enclosureLength) ~/
                                                              1000000)
                                                          .toString() +
                                                      'MB',
                                                  Colors.lightBlue[300])
                                              : Center(),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Divider(
                                    height: 2,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
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
