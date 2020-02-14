import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tsacdop/class/audiostate.dart';
import 'package:provider/provider.dart';

import 'package:tsacdop/podcasts/podcastlist.dart';
import 'hometab.dart';
import 'package:tsacdop/home/appbar/importompl.dart';
import 'package:tsacdop/home/audio_player.dart';
import 'homescroll.dart';
import 'package:tsacdop/util/pageroute.dart';

class Home extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Import(),
          Container(
            height: 30,
            padding: EdgeInsets.symmetric(horizontal: 15),
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  SlideLeftRoute(page: Podcast()),
                );
              },
              child: Container(
                height: 30,
                padding: EdgeInsets.all(5.0),
                child: Text('See All',
                    style: TextStyle(
                      color: Colors.red[300],
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ),
          ),
          Container(child: ScrollPodcasts()),
          Expanded(
            child: MainTab(),
          ),
        ],
      ),
      Container(
        child: PlayerWidget()),
    ]);
  }
}
