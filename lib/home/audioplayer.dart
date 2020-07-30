import 'dart:io';
import 'dart:math' as math;

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../episodes/episode_detail.dart';
import '../local_storage/key_value_storage.dart';
import '../local_storage/sqflite_localpodcast.dart';
import '../state/audio_state.dart';
import '../type/episodebrief.dart';
import '../type/play_histroy.dart';
import '../util/audiopanel.dart';
import '../util/custom_slider.dart';
import '../util/custom_widget.dart';
import '../util/extension_helper.dart';
import '../util/pageroute.dart';
import 'playlist.dart';

final List<BoxShadow> _customShadow = [
  BoxShadow(blurRadius: 26, offset: Offset(-6, -6), color: Colors.white),
  BoxShadow(
      blurRadius: 8,
      offset: Offset(2, 2),
      color: Colors.grey[600].withOpacity(0.4))
];

final List<BoxShadow> _customShadowNight = [
  BoxShadow(
      blurRadius: 6,
      offset: Offset(-1, -1),
      color: Colors.grey[100].withOpacity(0.3)),
  BoxShadow(blurRadius: 8, offset: Offset(2, 2), color: Colors.black)
];

const List minsToSelect = [10, 15, 20, 25, 30, 45, 60, 70, 80, 90, 99];
const List speedToSelect = [0.5, 0.6, 0.8, 1.0, 1.2, 1.5, 2.0];

class PlayerWidget extends StatelessWidget {
  PlayerWidget({this.playerKey});
  final GlobalKey<AudioPanelState> playerKey;
  Widget _miniPanel(BuildContext context) {
    var audio = Provider.of<AudioPlayerNotifier>(context, listen: false);
    final s = context.s;
    return Container(
      color: context.primaryColor,
      height: 60,
      child:
          Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
        Selector<AudioPlayerNotifier, Tuple2<String, double>>(
          selector: (_, audio) =>
              Tuple2(audio.episode?.primaryColor, audio.seekSliderValue),
          builder: (_, data, __) {
            var _c = context.brightness == Brightness.light
                ? data.item1.colorizedark()
                : data.item1.colorizeLight();
            return SizedBox(
              height: 2,
              child: LinearProgressIndicator(
                value: data.item2,
                backgroundColor: context.primaryColor,
                valueColor: AlwaysStoppedAnimation<Color>(_c),
              ),
            );
          },
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: Selector<AudioPlayerNotifier, String>(
                    selector: (_, audio) => audio.episode?.title,
                    builder: (_, title, __) {
                      return Text(
                        title,
                        style: TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.clip,
                      );
                    },
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Selector<AudioPlayerNotifier,
                      Tuple3<bool, double, String>>(
                    selector: (_, audio) => Tuple3(
                        audio.buffering,
                        (audio.backgroundAudioDuration -
                                audio.backgroundAudioPosition) /
                            1000,
                        audio.remoteErrorMessage),
                    builder: (_, data, __) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: data.item3 != null
                            ? Text(data.item3,
                                style:
                                    const TextStyle(color: Color(0xFFFF0000)))
                            : data.item1
                                ? Text(
                                    s.buffering,
                                    style:
                                        TextStyle(color: context.accentColor),
                                  )
                                : Text(
                                    s.timeLeft(
                                        (data.item2).toInt().toTime ?? ''),
                                    maxLines: 2,
                                  ),
                      );
                    },
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Selector<AudioPlayerNotifier, Tuple2<bool, bool>>(
                    selector: (_, audio) =>
                        Tuple2(audio.buffering, audio.playing),
                    builder: (_, data, __) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          data.item1
                              ? Stack(
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10.0),
                                        child: SizedBox(
                                            height: 30.0,
                                            width: 30.0,
                                            child: CircleAvatar(
                                              backgroundImage: FileImage(File(
                                                  "${audio.episode.imagePath}")),
                                            )),
                                      ),
                                      Container(
                                        height: 40.0,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.black),
                                      ),
                                    ])
                              : data.item2
                                  ? InkWell(
                                      onTap: data.item2
                                          ? () => audio.pauseAduio()
                                          : null,
                                      child: ImageRotate(
                                          title: audio.episode?.title,
                                          path: audio.episode?.imagePath),
                                    )
                                  : InkWell(
                                      onTap: data.item2
                                          ? null
                                          : () => audio.resumeAudio(),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10.0),
                                            child: SizedBox(
                                                height: 30.0,
                                                width: 30.0,
                                                child: CircleAvatar(
                                                  backgroundImage: FileImage(File(
                                                      "${audio.episode.imagePath}")),
                                                )),
                                          ),
                                          Container(
                                            height: 40.0,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.black),
                                          ),
                                          if (!data.item1)
                                            Icon(
                                              Icons.play_arrow,
                                              color: Colors.white,
                                            )
                                        ],
                                      ),
                                    ),
                          IconButton(
                              onPressed: () => audio.playNext(),
                              iconSize: 20.0,
                              icon: Icon(Icons.skip_next),
                              color: context.textColor)
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Selector<AudioPlayerNotifier, bool>(
      selector: (_, audio) => audio.playerRunning,
      builder: (_, playerrunning, __) {
        return !playerrunning
            ? Center()
            : AudioPanel(
                key: playerKey,
                miniPanel: _miniPanel(context),
                expandedPanel: ControlPanel(onTap: () {
                  playerKey.currentState.scrollToTop();
                }));
      },
    );
  }
}

class LastPosition extends StatefulWidget {
  LastPosition({Key key}) : super(key: key);

  @override
  _LastPositionState createState() => _LastPositionState();
}

class _LastPositionState extends State<LastPosition> {
  Future<PlayHistory> getPosition(EpisodeBrief episode) async {
    var dbHelper = DBHelper();
    return await dbHelper.getPosition(episode);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    var audio = Provider.of<AudioPlayerNotifier>(context, listen: false);
    return Selector<AudioPlayerNotifier, EpisodeBrief>(
      selector: (_, audio) => audio.episode,
      builder: (context, episode, child) {
        return FutureBuilder<PlayHistory>(
            future: getPosition(episode),
            builder: (context, snapshot) {
              if (snapshot.hasError) print(snapshot.error);
              return snapshot.hasData
                  ? snapshot.data.seekValue > 0.90
                      ? Container(
                          height: 20.0,
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  width: 1, color: context.textColor),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0))),
                          child: Text(s.listened))
                      : snapshot.data.seconds < 10
                          ? Center()
                          : OutlineButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100.0),
                                  side: BorderSide(color: Colors.green[700])),
                              highlightedBorderColor: Colors.green[700],
                              onPressed: () => audio.seekTo(
                                  (snapshot.data.seconds * 1000).toInt()),
                              child: Text(snapshot.data.seconds.toTime),
                            )
                  : Center();
            });
      },
    );
  }
}

class ImageRotate extends StatefulWidget {
  final String title;
  final String path;
  ImageRotate({this.title, this.path, Key key}) : super(key: key);
  @override
  _ImageRotateState createState() => _ImageRotateState();
}

class _ImageRotateState extends State<ImageRotate>
    with SingleTickerProviderStateMixin {
  Animation _animation;
  AnimationController _controller;
  double _value;
  @override
  void initState() {
    super.initState();
    _value = 0;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        if (mounted) {
          setState(() {
            _value = _animation.value;
          });
        }
      });
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 2 * math.pi * _value,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
          child: Container(
            height: 30.0,
            width: 30.0,
            color: Colors.white,
            child: Image.file(File("${widget.path}")),
          ),
        ),
      ),
    );
  }
}

class PlaylistWidget extends StatefulWidget {
  const PlaylistWidget({Key key}) : super(key: key);

  @override
  _PlaylistWidgetState createState() => _PlaylistWidgetState();
}

class _PlaylistWidgetState extends State<PlaylistWidget> {
  final GlobalKey<AnimatedListState> miniPlaylistKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    var audio = Provider.of<AudioPlayerNotifier>(context, listen: false);
    return Container(
      alignment: Alignment.topLeft,
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.accentColor.withAlpha(70),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: <Widget>[
          Expanded(
            child:
                Selector<AudioPlayerNotifier, Tuple2<List<EpisodeBrief>, bool>>(
              selector: (_, audio) =>
                  Tuple2(audio.queue.playlist, audio.queueUpdate),
              builder: (_, data, __) {
                return ClipRRect(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                  child: AnimatedList(
                    key: miniPlaylistKey,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    initialItemCount: data.item1.length,
                    itemBuilder: (context, index, animation) => ScaleTransition(
                      alignment: Alignment.center,
                      scale: animation,
                      child: index == 0 || index > data.item1.length - 1
                          ? Center()
                          : Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            audio
                                                .episodeLoad(data.item1[index]);
                                            miniPlaylistKey.currentState
                                                .removeItem(
                                                    index,
                                                    (context, animation) =>
                                                        Center());
                                            miniPlaylistKey.currentState
                                                .insertItem(0);
                                          },
                                          child: Container(
                                            height: 60,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20),
                                            alignment: Alignment.centerLeft,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Container(
                                                  padding: EdgeInsets.all(10.0),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                15.0)),
                                                    child: Container(
                                                        height: 30.0,
                                                        width: 30.0,
                                                        child: Image.file(File(
                                                            "${data.item1[index].imagePath}"))),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      data.item1[index].title,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      child: Material(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        clipBehavior: Clip.hardEdge,
                                        color: context.primaryColor,
                                        child: InkWell(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15.0)),
                                          onTap: () async {
                                            await audio
                                                .moveToTop(data.item1[index]);
                                            miniPlaylistKey.currentState
                                                .removeItem(
                                              index,
                                              (context, animation) => Center(),
                                              duration:
                                                  Duration(milliseconds: 500),
                                            );
                                            miniPlaylistKey.currentState
                                                .insertItem(
                                                    1,
                                                    duration: Duration(
                                                        milliseconds: 200));
                                          },
                                          child: SizedBox(
                                            height: 30.0,
                                            width: 30.0,
                                            child: Transform.rotate(
                                              angle: math.pi,
                                              child: Icon(
                                                LineIcons.download_solid,
                                                size: 20.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(height: 2),
                              ],
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            height: 60.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: <Widget>[
                  Text(
                    context.s.homeMenuPlaylist,
                    style: TextStyle(
                        color: context.accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  Spacer(),
                  Material(
                    borderRadius: BorderRadius.circular(100),
                    color: context.primaryColor,
                    child: InkWell(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      onTap: () {
                        audio.playNext();
                        miniPlaylistKey.currentState
                            .removeItem(0, (context, animation) => Container());
                        miniPlaylistKey.currentState.insertItem(0);
                      },
                      child: SizedBox(
                        height: 30,
                        width: 60,
                        child: Icon(
                          Icons.skip_next,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Material(
                    borderRadius: BorderRadius.circular(100),
                    color: context.primaryColor,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15.0),
                      onTap: () {
                        Navigator.push(
                          context,
                          SlideLeftRoute(page: PlaylistPage()),
                        );
                      },
                      child: SizedBox(
                        height: 30.0,
                        width: 30.0,
                        child: Transform.rotate(
                          angle: math.pi,
                          child: Icon(
                            LineIcons.database_solid,
                            size: 20.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SleepMode extends StatefulWidget {
  SleepMode({Key key}) : super(key: key);

  @override
  SleepModeState createState() => SleepModeState();
}

class SleepModeState extends State<SleepMode>
    with SingleTickerProviderStateMixin {
  int _minSelected;
  AnimationController _controller;
  Animation<double> _animation;
  Future _getDefaultTime() async {
    var defaultSleepTimerStorage = KeyValueStorage(defaultSleepTimerKey);
    var defaultTime = await defaultSleepTimerStorage.getInt(defaultValue: 30);
    setState(() => _minSelected = defaultTime);
  }

  @override
  void initState() {
    super.initState();
    _minSelected = 30;
    _getDefaultTime();

    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Provider.of<AudioPlayerNotifier>(context, listen: false)
          ..sleepTimer(_minSelected)
          ..setSwitchValue = 1;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<BoxShadow> customShadow(double scale) => [
        BoxShadow(
            blurRadius: 26 * (1 - scale),
            offset: Offset(-6, -6) * (1 - scale),
            color: Colors.white),
        BoxShadow(
            blurRadius: 8 * (1 - scale),
            offset: Offset(2, 2) * (1 - scale),
            color: Colors.grey[600].withOpacity(0.4))
      ];
  List<BoxShadow> customShadowNight(double scale) => [
        BoxShadow(
            blurRadius: 6 * (1 - scale),
            offset: Offset(-1, -1) * (1 - scale),
            color: Colors.grey[100].withOpacity(0.3)),
        BoxShadow(
            blurRadius: 8 * (1 - scale),
            offset: Offset(2, 2) * (1 - scale),
            color: Colors.black)
      ];

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final _colorTween =
        ColorTween(begin: context.accentColor.withAlpha(60), end: Colors.black);
    var audio = Provider.of<AudioPlayerNotifier>(context, listen: false);
    return Selector<AudioPlayerNotifier, Tuple3<int, double, SleepTimerMode>>(
      selector: (_, audio) =>
          Tuple3(audio?.timeLeft, audio?.switchValue, audio.sleepTimerMode),
      builder: (_, data, __) {
        var fraction =
            data.item2 == 1 ? 1.0 : math.min(_animation.value * 2, 1.0);
        var move =
            data.item2 == 1 ? 1.0 : math.max(_animation.value * 2 - 1, 0.0);
        return LayoutBuilder(builder: (context, constraints) {
          var width = constraints.maxWidth;
          return Container(
            height: 300,
            decoration: BoxDecoration(
                color: _colorTween.transform(move),
                borderRadius: BorderRadius.circular(10)),
            child: Stack(
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: move == 1
                            ? Center()
                            : Wrap(
                                direction: Axis.horizontal,
                                children: minsToSelect
                                    .map((e) => InkWell(
                                          onTap: () =>
                                              setState(() => _minSelected = e),
                                          child: Container(
                                            margin: EdgeInsets.all(10.0),
                                            decoration: BoxDecoration(
                                              color: (e == _minSelected)
                                                  ? context.accentColor
                                                  : context.primaryColor,
                                              shape: BoxShape.circle,
                                            ),
                                            alignment: Alignment.center,
                                            height: 30,
                                            width: 30,
                                            child: Text(e.toString(),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: (e == _minSelected)
                                                        ? Colors.white
                                                        : null)),
                                          ),
                                        ))
                                    .toList(),
                              ),
                      ),
                    ),
                    Stack(
                      children: <Widget>[
                        SizedBox(
                          height: 100,
                          width: width,
                        ),
                        Positioned(
                          left: data.item3 == SleepTimerMode.timer
                              ? -width * (move) / 4
                              : width * (move) / 4,
                          child: SizedBox(
                            height: 100,
                            width: width,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Container(
                                  alignment: Alignment.center,
                                  height: 40,
                                  width: 120,
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: context.primaryColor),
                                    color: _colorTween.transform(move),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        audio.setSleepTimerMode =
                                            SleepTimerMode.endOfEpisode;
                                        if (fraction == 0) {
                                          _controller.forward();
                                        } else if (fraction == 1) {
                                          _controller.reverse();
                                          audio.cancelTimer();
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(20),
                                      child: SizedBox(
                                        height: 40,
                                        width: 120,
                                        child: Center(
                                          child: Text(
                                            s.endOfEpisode,
                                            style: TextStyle(
                                                color: (move > 0
                                                    ? Colors.white
                                                    : null)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 100 * (1 - fraction),
                                  width: 1,
                                  color: context.primaryColorDark,
                                ),
                                Container(
                                  height: 40,
                                  width: 120,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: context.primaryColor),
                                    color: _colorTween.transform(move),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        audio.setSleepTimerMode =
                                            SleepTimerMode.timer;
                                        if (fraction == 0) {
                                          _controller.forward();
                                        } else if (fraction == 1) {
                                          _controller.reverse();
                                          audio.cancelTimer();
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(20),
                                      child: SizedBox(
                                        height: 40,
                                        width: 120,
                                        child: Center(
                                          child: Text(
                                            data.item2 == 1
                                                ? data.item1.toTime
                                                : (_minSelected * 60).toTime,
                                            style: TextStyle(
                                                color: (move > 0
                                                    ? Colors.white
                                                    : null)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 60.0,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            context.s.sleepTimer,
                            style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                if (fraction > 0)
                  Positioned(
                    bottom: 120,
                    left: width / 2 - 100,
                    width: 200,
                    child: Center(
                      child: Transform.translate(
                        offset: Offset(0, -50 * fraction),
                        child: Text(s.goodNight,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white.withOpacity(fraction))),
                      ),
                    ),
                  ),
                if (data.item2 == 1) CustomPaint(painter: StarSky()),
                if (data.item2 == 1) MeteorLoader()
              ],
            ),
          );
        });
      },
    );
  }
}

class ControlPanel extends StatefulWidget {
  ControlPanel({this.onTap, Key key}) : super(key: key);
  final VoidCallback onTap;
  @override
  _ControlPanelState createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel>
    with TickerProviderStateMixin {
  double _speedSelected;
  double _setSpeed;
  AnimationController _controller;
  Animation<double> _animation;
  TabController _tabController;
  int _tabIndex = 0;
  List<BoxShadow> customShadow(double scale) => [
        BoxShadow(
            blurRadius: 26 * (1 - scale),
            offset: Offset(-6, -6) * (1 - scale),
            color: Colors.white),
        BoxShadow(
            blurRadius: 8 * (1 - scale),
            offset: Offset(2, 2) * (1 - scale),
            color: Colors.grey[600].withOpacity(0.4))
      ];
  List<BoxShadow> customShadowNight(double scale) => [
        BoxShadow(
            blurRadius: 6 * (1 - scale),
            offset: Offset(-1, -1) * (1 - scale),
            color: Colors.grey[100].withOpacity(0.3)),
        BoxShadow(
            blurRadius: 8 * (1 - scale),
            offset: Offset(2, 2) * (1 - scale),
            color: Colors.black)
      ];

  @override
  void initState() {
    _speedSelected = 0;
    _setSpeed = 0;
    _tabController = TabController(vsync: this, length: 2)
      ..addListener(() {
        setState(() => _tabIndex = _tabController.index);
      });
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() => _setSpeed = _animation.value);
      });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var audio = Provider.of<AudioPlayerNotifier>(context, listen: false);
    return LayoutBuilder(
      builder: (context, constraints) {
        var maxHeight = constraints.maxHeight;
        return Container(
          color: context.primaryColor,
          height: 300,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Consumer<AudioPlayerNotifier>(
                  builder: (_, data, __) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          padding:
                              EdgeInsets.only(top: 20, left: 10, right: 10),
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: maxHeight <= 300
                                  ? context.accentColor.withAlpha(70)
                                  : Colors.transparent,
                              inactiveTrackColor: maxHeight > 300
                                  ? Colors.transparent
                                  : context.primaryColorDark,
                              trackHeight: 8.0,
                              trackShape: MyRectangularTrackShape(),
                              thumbColor: context.accentColor,
                              thumbShape: RoundSliderThumbShape(
                                enabledThumbRadius: 6.0,
                                disabledThumbRadius: 6.0,
                              ),
                              overlayColor: context.accentColor.withAlpha(32),
                              overlayShape:
                                  RoundSliderOverlayShape(overlayRadius: 4.0),
                            ),
                            child: Slider(
                                value: data.seekSliderValue,
                                onChanged: (val) {
                                  audio.sliderSeek(val);
                                }),
                          ),
                        ),
                        Container(
                          height: 20.0,
                          padding: EdgeInsets.symmetric(horizontal: 30.0),
                          child: maxHeight > 300
                              ? Center()
                              : Row(
                                  children: <Widget>[
                                    Text(
                                      (data.backgroundAudioPosition ~/ 1000)
                                              .toTime ??
                                          '',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: data.remoteErrorMessage != null
                                            ? Text(data.remoteErrorMessage,
                                                style: const TextStyle(
                                                    color: Color(0xFFFF0000)))
                                            : Text(
                                                data.audioState ==
                                                            AudioProcessingState
                                                                .buffering ||
                                                        data.audioState ==
                                                            AudioProcessingState
                                                                .connecting ||
                                                        data.audioState ==
                                                            AudioProcessingState
                                                                .none ||
                                                        data.audioState ==
                                                            AudioProcessingState
                                                                .skippingToNext
                                                    ? context.s.buffering
                                                    : '',
                                                style: TextStyle(
                                                    color: context.accentColor),
                                              ),
                                      ),
                                    ),
                                    Text(
                                      (data.backgroundAudioDuration ~/ 1000)
                                              .toTime ??
                                          '',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(
                  height: 100,
                  child: Selector<AudioPlayerNotifier, bool>(
                    selector: (_, audio) => audio.playing,
                    builder: (_, playing, __) {
                      return Material(
                        color: Colors.transparent,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                                padding: EdgeInsets.only(right: 10, left: 30),
                                onPressed:
                                    playing ? () => audio.rewind() : null,
                                iconSize: 32.0,
                                icon: Icon(Icons.fast_rewind),
                                color: Colors.grey[500]),
                            Selector<AudioPlayerNotifier, int>(
                                selector: (_, audio) => audio.rewindSeconds,
                                builder: (_, seconds, __) => Padding(
                                      padding: const EdgeInsets.only(top: 5.0),
                                      child: Text('$seconds s',
                                          style: GoogleFonts.teko(
                                            textBaseline:
                                                TextBaseline.ideographic,
                                            textStyle: TextStyle(
                                                color: Colors.grey[500],
                                                fontSize: 20),
                                          )),
                                    )),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 30),
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                  color: context.primaryColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color:
                                          context.brightness == Brightness.dark
                                              ? Colors.black12
                                              : Colors.white10,
                                      width: 1),
                                  boxShadow:
                                      context.brightness == Brightness.dark
                                          ? _customShadowNight
                                          : _customShadow),
                              child: playing
                                  ? Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        onTap: playing
                                            ? () {
                                                audio.pauseAduio();
                                              }
                                            : null,
                                        child: SizedBox(
                                          height: 60,
                                          width: 60,
                                          child: Icon(
                                            Icons.pause,
                                            size: 40,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        onTap: playing
                                            ? null
                                            : () {
                                                audio.resumeAudio();
                                              },
                                        child: SizedBox(
                                          height: 60,
                                          width: 60,
                                          child: Icon(
                                            Icons.play_arrow,
                                            size: 40,
                                            color: context.accentColor,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                            Selector<AudioPlayerNotifier, int>(
                                selector: (_, audio) =>
                                    audio.fastForwardSeconds,
                                builder: (_, seconds, __) => Padding(
                                      padding: const EdgeInsets.only(top: 5.0),
                                      child: Text('$seconds s',
                                          style: GoogleFonts.teko(
                                            textStyle: TextStyle(
                                                color: Colors.grey[500],
                                                fontSize: 20),
                                          )),
                                    )),
                            IconButton(
                              padding: EdgeInsets.only(left: 10.0, right: 30),
                              onPressed:
                                  playing ? () => audio.fastForward() : null,
                              iconSize: 32.0,
                              icon: Icon(Icons.fast_forward),
                              color: Colors.grey[500],
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  height: 70.0,
                  padding:
                      EdgeInsets.only(left: 60, right: 60, bottom: 10, top: 10),
                  alignment: Alignment.center,
                  child: Selector<AudioPlayerNotifier, String>(
                    selector: (_, audio) => audio.episode.title,
                    builder: (_, title, __) {
                      return Container(
                        child: LayoutBuilder(
                          builder: (context, size) {
                            var span = TextSpan(
                                text: title,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20));
                            var tp = TextPainter(
                                text: span,
                                maxLines: 1,
                                textDirection: TextDirection.ltr);
                            tp.layout(maxWidth: size.maxWidth);
                            if (tp.didExceedMaxLines) {
                              return Marquee(
                                text: title,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                                scrollAxis: Axis.horizontal,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                blankSpace: 30.0,
                                velocity: 50.0,
                                pauseAfterRound: Duration.zero,
                                startPadding: 30.0,
                                accelerationDuration:
                                    Duration(milliseconds: 100),
                                accelerationCurve: Curves.linear,
                                decelerationDuration:
                                    Duration(milliseconds: 100),
                                decelerationCurve: Curves.linear,
                              );
                            } else {
                              return Text(
                                title,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
                if (constraints.maxHeight > 300)
                  SizedBox(
                    height: constraints.maxHeight - 300,
                    child: SingleChildScrollView(
                        physics: NeverScrollableScrollPhysics(),
                        child: SizedBox(
                            height: 300,
                            child: ScrollConfiguration(
                              behavior: NoGrowBehavior(),
                              child: TabBarView(
                                  controller: _tabController,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      child: PlaylistWidget(),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      child: SleepMode(),
                                    )
                                  ]),
                            ))),
                  ),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (maxHeight <= 300)
                        Selector<AudioPlayerNotifier,
                            Tuple3<EpisodeBrief, bool, bool>>(
                          selector: (_, audio) => Tuple3(audio.episode,
                              audio.stopOnComplete, audio.startSleepTimer),
                          builder: (_, data, __) {
                            return Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  if (_setSpeed == 0)
                                    Expanded(
                                      child: InkWell(
                                        onTap: () => Navigator.push(
                                            context,
                                            SlideUptRoute(
                                                page: EpisodeDetail(
                                                    episodeItem: data.item1,
                                                    heroTag: 'playpanel'))),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              height: 30.0,
                                              width: 30.0,
                                              child: CircleAvatar(
                                                backgroundImage: FileImage(File(
                                                    "${data.item1.imagePath}")),
                                              ),
                                            ),
                                            SizedBox(width: 5),
                                            SizedBox(
                                              width: 100,
                                              child: Text(
                                                data.item1.feedTitle,
                                                maxLines: 1,
                                                overflow: TextOverflow.fade,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  if (_setSpeed > 0)
                                    Expanded(
                                      child: SingleChildScrollView(
                                        padding: EdgeInsets.all(10.0),
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: speedToSelect
                                              .map<Widget>((e) => InkWell(
                                                    onTap: () {
                                                      if (_setSpeed == 1) {
                                                        setState(() =>
                                                            _speedSelected = e);
                                                        audio.setSpeed(e);
                                                      }
                                                    },
                                                    child: Container(
                                                      height: 30,
                                                      width: 30,
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 5),
                                                      decoration: e ==
                                                                  _speedSelected &&
                                                              _setSpeed > 0
                                                          ? BoxDecoration(
                                                              color: context
                                                                  .accentColor,
                                                              shape: BoxShape
                                                                  .circle,
                                                              boxShadow: context
                                                                          .brightness ==
                                                                      Brightness
                                                                          .light
                                                                  ? customShadow(
                                                                      1.0)
                                                                  : customShadowNight(
                                                                      1.0),
                                                            )
                                                          : BoxDecoration(
                                                              color: context
                                                                  .primaryColor,
                                                              shape: BoxShape
                                                                  .circle,
                                                              boxShadow: context
                                                                          .brightness ==
                                                                      Brightness
                                                                          .light
                                                                  ? customShadow(1 -
                                                                      _setSpeed)
                                                                  : customShadowNight(1 -
                                                                      _setSpeed)),
                                                      alignment:
                                                          Alignment.center,
                                                      child: _setSpeed > 0
                                                          ? Text(e.toString(),
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: e ==
                                                                          _speedSelected
                                                                      ? Colors
                                                                          .white
                                                                      : null))
                                                          : Center(),
                                                    ),
                                                  ))
                                              .toList(),
                                        ),
                                      ),
                                    ),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      if (_setSpeed == 0) {
                                        _controller.forward();
                                      } else {
                                        _controller.reverse();
                                      }
                                    },
                                    icon: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Transform.rotate(
                                            angle: math.pi * _setSpeed,
                                            child: Text('X')),
                                        Selector<AudioPlayerNotifier, double>(
                                          selector: (_, audio) =>
                                              audio.currentSpeed ?? 1.0,
                                          builder: (context, value, child) =>
                                              Text(value.toString()),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      if (_setSpeed == 0)
                        Positioned(
                          bottom: 15,
                          child: InkWell(
                              child: SizedBox(
                                height: 50,
                                width: 100,
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: CustomPaint(
                                      size: Size(100, 5),
                                      painter: TabIndicator(
                                          index: _tabIndex,
                                          indicatorSize: 20,
                                          fraction: (maxHeight - 300) / 300,
                                          accentColor: context.accentColor,
                                          color: context.textColor)),
                                ),
                              ),
                              onTap: widget.onTap),
                        ),
                      if (_setSpeed == 0 && maxHeight > 300)
                        Transform.translate(
                          offset: Offset(0, 5) * (maxHeight - 300) / 300,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: context.width / 2 - 80),
                            child: TabBar(
                              controller: _tabController,
                              indicatorSize: TabBarIndicatorSize.label,
                              labelColor: context.accentColor,
                              unselectedLabelColor: context.textColor,
                              indicator: BoxDecoration(),
                              tabs: [
                                Container(
                                    height: 20,
                                    width: 20,
                                    child: Icon(Icons.playlist_play)),
                                Container(
                                    height: 20,
                                    width: 20,
                                    child: Transform.rotate(
                                        angle: math.pi * 0.7,
                                        child: Icon(Icons.brightness_2,
                                            size: 18))),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ]),
        );
      },
    );
  }
}
