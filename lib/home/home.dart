import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'hometab.dart';
import 'package:tsacdop/home/appbar/importompl.dart';
import 'package:tsacdop/home/audioplayer.dart';
import 'homescroll.dart';

class Home extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
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
      Container(child: PlayerWidget()),
    ]);
  }
}
