import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'hometab.dart';
import 'package:tsacdop/home/appbar/importompl.dart';
import 'package:tsacdop/home/audioplayer.dart';
import 'package:tsacdop/class/audiostate.dart';
import 'homescroll.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _loadPlay;

  static String _stringForSeconds(int seconds) {
    if (seconds == null) return null;
    return '${(seconds ~/ 60)}:${(seconds.truncate() % 60).toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _loadPlay = false;
    _getPlaylist();
  }

  _getPlaylist() async {
    await Provider.of<AudioPlayerNotifier>(context, listen: false).loadPlaylist();
    setState(() {
      _loadPlay = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    var audio = Provider.of<AudioPlayerNotifier>(context, listen: false);
    return Stack(children: <Widget>[
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Import(),
          Container(child: ScrollPodcasts()),
          Expanded(
            child: MainTab(),
          ),
        ],
      ),
      AnimatedPositioned(
        duration: Duration(milliseconds: 2000),
        curve: Curves.elasticOut,
        bottom: 50,
        right: _loadPlay ? 5 : -25,
        child: Container(
          child: Selector<AudioPlayerNotifier, Tuple3<bool, Playlist, int>>(
            selector: (_, audio) =>
                Tuple3(audio.playerRunning, audio.queue, audio.lastPositin),
            builder: (_, data, __) => !_loadPlay
                ? Center()
                : data.item1 || data.item2.playlist.length == 0
                    ? Center()
                    : InkWell(
                        onTap: () => audio.playlistLoad(),
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(left: 45, right: 10.0),
                              alignment: Alignment.centerRight,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).accentColor,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20.0),
                                      bottomLeft: Radius.circular(20.0),
                                      bottomRight: Radius.circular(10.0),
                                      topRight: Radius.circular(10.0)),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Colors.grey[400]
                                            : Colors.grey[800],
                                        blurRadius: 4,
                                        offset: Offset(1, 1)),
                                  ]),
                              height: 40,
                              child: Text(_stringForSeconds(data.item3~/1000) + '...',
                                  style: TextStyle(color: Colors.white)),
                            ),
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: FileImage(File(
                                  "${data.item2.playlist.first.imagePath}")),
                            ),
                            Container(
                              height: 40.0,
                              width: 40,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black12),
                              child: Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
        ),
      ),
      Container(child: PlayerWidget()),
    ]);
  }
}
