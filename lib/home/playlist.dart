import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tsacdop/episodes/episodedetail.dart';
import 'package:tuple/tuple.dart';
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
  Widget episodeTag(String text, Color color) {
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
        appBar: AppBar(
          title: Text('Playlist'),
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: SafeArea(
          child:
              Selector<AudioPlayerNotifier, Tuple2<List<EpisodeBrief>, bool>>(
            selector: (_, audio) =>
                Tuple2(audio.queue.playlist, audio.playerRunning),
            builder: (_, data, __) {
              return AnimatedList(
                  key: _playlistKey,
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  initialItemCount: data.item1.length,
                  itemBuilder: (context, index, animation) {
                    Color _c =
                        (Theme.of(context).brightness == Brightness.light)
                            ? data.item1[index].primaryColor.colorizedark()
                            : data.item1[index].primaryColor.colorizeLight();
                    return ScaleTransition(
                      alignment: Alignment.centerLeft,
                      scale: animation,
                      child: Dismissible(
                        background: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Icon(
                                Icons.delete,
                                color: Theme.of(context).accentColor,
                              ),
                              Icon(
                                Icons.delete,
                                color: Theme.of(context).accentColor,
                              ),
                            ],
                          ),
                          height: 50,
                          color: Colors.grey[500],
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
                              title: Text(
                                data.item1[index].title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: _c.withOpacity(0.5),
                                backgroundImage: FileImage(
                                    File("${data.item1[index].imagePath}")),
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
                                          onPressed: () => audio.playlistLoad())
                                  : IconButton(
                                      tooltip: 'Move to Top',
                                      icon:
                                          Icon(LineIcons.arrow_circle_up_solid),
                                      onPressed: () async {
                                        await audio
                                            .moveToTop(data.item1[index]);
                                        _playlistKey.currentState.removeItem(
                                            index,
                                            (context, animation) =>
                                                Container());
                                        data.item2
                                            ? _playlistKey.currentState
                                                .insertItem(1)
                                            : _playlistKey.currentState
                                                .insertItem(0);
                                      }),
                              subtitle: Container(
                                padding: EdgeInsets.symmetric(vertical: 5),
                                child: Row(
                                  children: <Widget>[
                                    (data.item1[index].explicit == 1)
                                        ? Container(
                                            decoration: BoxDecoration(
                                                color: Colors.red[800],
                                                shape: BoxShape.circle),
                                            height: 20.0,
                                            width: 20.0,
                                            margin:
                                                EdgeInsets.only(right: 10.0),
                                            alignment: Alignment.center,
                                            child: Text('E',
                                                style: TextStyle(
                                                    color: Colors.white)))
                                        : Center(),
                                    data.item1[index].duration != 0
                                        ? episodeTag(
                                            (data.item1[index].duration)
                                                    .toString() +
                                                'mins',
                                            Colors.cyan[300])
                                        : Center(),
                                    data.item1[index].enclosureLength != null
                                        ? episodeTag(
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
                  });
            },
          ),
        ),
      ),
    );
  }
}
