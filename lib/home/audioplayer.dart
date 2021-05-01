import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math' as math;

import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../episodes/episode_detail.dart';
import '../local_storage/key_value_storage.dart';
import '../local_storage/sqflite_localpodcast.dart';
import '../playlists/playlist_home.dart';
import '../state/audio_state.dart';
import '../type/chapter.dart';
import '../type/episodebrief.dart';
import '../type/play_histroy.dart';
import '../type/playlist.dart';
import '../util/extension_helper.dart';
import '../util/pageroute.dart';
import '../widgets/audiopanel.dart';
import '../widgets/custom_slider.dart';
import '../widgets/custom_widget.dart';

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

const List kMinsToSelect = [10, 15, 20, 25, 30, 45, 60, 70, 80, 90, 99];
const List kMinPlayerHeight = <double>[70.0, 75.0, 80.0];
const List kMaxPlayerHeight = <double>[300.0, 325.0, 350.0];

class PlayerWidget extends StatelessWidget {
  PlayerWidget({this.playerKey, this.isPlayingPage = false});
  final GlobalKey<AudioPanelState> playerKey;
  final bool isPlayingPage;
  Widget _miniPanel(BuildContext context) {
    var audio = Provider.of<AudioPlayerNotifier>(context, listen: false);
    final s = context.s;
    return Container(
      color: context.primaryColor,
      height: 60,
      child:
          Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
        Selector<AudioPlayerNotifier, Tuple2<EpisodeBrief, double>>(
          selector: (_, audio) => Tuple2(audio.episode, audio.seekSliderValue),
          builder: (_, data, __) {
            final c = data.item1.backgroudColor(context);
            return SizedBox(
              height: 2,
              child: LinearProgressIndicator(
                value: data.item2,
                backgroundColor: context.primaryColor,
                valueColor: AlwaysStoppedAnimation<Color>(c),
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
                  child: Selector<AudioPlayerNotifier,
                      Tuple3<bool, bool, EpisodeBrief>>(
                    selector: (_, audio) =>
                        Tuple3(audio.buffering, audio.playing, audio.episode),
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
                                            backgroundColor: data.item3
                                                .backgroudColor(context),
                                            backgroundImage:
                                                data.item3.avatarImage,
                                          ),
                                        ),
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
                                      child:
                                          ImageRotate(episodeItem: data.item3),
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
                                                backgroundColor: data.item3
                                                    .backgroudColor(context),
                                                backgroundImage:
                                                    data.item3.avatarImage,
                                              ),
                                            ),
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
    return Selector<AudioPlayerNotifier, Tuple2<bool, PlayerHeight>>(
      selector: (_, audio) => Tuple2(audio.playerRunning, audio?.playerHeight),
      builder: (_, data, __) {
        if (!data.item1) {
          return Center();
        } else {
          final minHeight = kMinPlayerHeight[data.item2.index];
          final maxHeight = math.min(
              kMaxPlayerHeight[data.item2.index] as double,
              context.height - 20);
          return AudioPanel(
            minHeight: minHeight,
            maxHeight: maxHeight,
            expandHeight: context.height - context.paddingTop - 20,
            key: playerKey,
            miniPanel: _miniPanel(context),
            expandedPanel: ControlPanel(
              maxHeight: maxHeight,
              isPlayingPage: isPlayingPage,
              onExpand: () {
                playerKey.currentState.scrollToTop();
              },
              onClose: () {
                playerKey.currentState.backToMini();
              },
            ),
          );
        }
      },
    );
  }
}

class LastPosition extends StatelessWidget {
  LastPosition({Key key}) : super(key: key);

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
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Selector<AudioPlayerNotifier, bool>(
                  selector: (_, audio) => audio.skipSilence,
                  builder: (_, data, __) => FlatButton(
                      child: Row(
                        children: [
                          Icon(Icons.flash_on, size: 18),
                          SizedBox(width: 5),
                          Text(s.skipSilence),
                        ],
                      ),
                      color: data ? context.accentColor : Colors.transparent,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          side: BorderSide(
                              color: data
                                  ? context.accentColor
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.12))),
                      textColor: data ? Colors.white : null,
                      onPressed: () =>
                          audio.setSkipSilence(skipSilence: !data))),
              SizedBox(width: 10),
              Selector<AudioPlayerNotifier, bool>(
                  selector: (_, audio) => audio.boostVolume,
                  builder: (_, data, __) => FlatButton(
                      child: Row(
                        children: [
                          Icon(Icons.volume_up, size: 18),
                          SizedBox(width: 5),
                          Text(s.boostVolume),
                        ],
                      ),
                      color: data ? context.accentColor : Colors.transparent,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          side: BorderSide(
                              color: data
                                  ? context.accentColor
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.12))),
                      textColor: data ? Colors.white : null,
                      onPressed: () =>
                          audio.setBoostVolume(boostVolume: !data))),
              SizedBox(width: 10),
              FutureBuilder<PlayHistory>(
                  future: getPosition(episode),
                  builder: (context, snapshot) {
                    return snapshot.hasData
                        ? snapshot.data.seekValue > 0.90
                            ? Container(
                                height: 20,
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CustomPaint(
                                    painter: ListenedAllPainter(
                                        context.accentColor,
                                        stroke: 2.0),
                                  ),
                                ),
                              )
                            : snapshot.data.seconds < 10
                                ? Center()
                                : OutlineButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                        side: BorderSide(
                                            color: context.accentColor)),
                                    highlightedBorderColor: Colors.green[700],
                                    onPressed: () => audio.seekTo(
                                        (snapshot.data.seconds * 1000).toInt()),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CustomPaint(
                                            painter: ListenedPainter(
                                                context.textColor,
                                                stroke: 2.0),
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        Text(snapshot.data.seconds.toTime),
                                      ],
                                    ),
                                  )
                        : Center();
                  }),
              Selector<AudioPlayerNotifier, double>(
                selector: (_, audio) => audio.switchValue,
                builder: (_, data, __) => data == 1
                    ? Container(
                        height: 20,
                        width: 40,
                        child: Transform.rotate(
                            angle: math.pi * 0.7,
                            child: Icon(Icons.brightness_2,
                                size: 18, color: context.accentColor)))
                    : Center(),
              )
            ],
          ),
        );
      },
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        alignment: Alignment.topLeft,
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.accentColor.withAlpha(70),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Selector<AudioPlayerNotifier, Tuple2<Playlist, EpisodeBrief>>(
          selector: (_, audio) => Tuple2(audio.playlist, audio.episode),
          builder: (_, data, __) {
            var episodes = data.item1.episodes;
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: episodes.length,
                    itemBuilder: (context, index) {
                      final isPlaying = episodes[index] != null &&
                          episodes[index] == data.item2;
                      return InkWell(
                        onTap: () async {
                          if (!isPlaying) {
                            if (data.item1.name == 'Queue') {
                              audio.episodeLoad(episodes[index]);
                            } else {
                              await context
                                  .read<AudioPlayerNotifier>()
                                  .loadEpisodeFromPlaylist(episodes[index]);
                            }
                          }
                        },
                        child: Container(
                          color: isPlaying
                              ? context.accentColor
                              : Colors.transparent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.all(10.0),
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0)),
                                  child: SizedBox(
                                      height: 30.0,
                                      width: 30.0,
                                      child: Image(
                                          image: episodes[index].avatarImage)
                                      // Image.file(File(
                                      //     "${episodes[index].imagePath}"))
                                      ),
                                ),
                              ),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    episodes[index].title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              if (isPlaying)
                                Container(
                                    height: 20,
                                    width: 20,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    child: WaveLoader(
                                        color: context.primaryColor)),
                            ],
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
                          data.item1.name == 'Queue'
                              ? context.s.queue
                              : '${context.s.homeMenuPlaylist}${'-${data.item1.name}'}',
                          overflow: TextOverflow.fade,
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
                              miniPlaylistKey.currentState.removeItem(
                                  0, (context, animation) => Container());
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
                                SlideLeftRoute(page: PlaylistHome()),
                              );
                            },
                            child: SizedBox(
                              height: 30.0,
                              width: 30.0,
                              child: Transform.rotate(
                                angle: math.pi,
                                child: Icon(
                                  LineIcons.database,
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
            );
          },
        ),
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
  bool _openClock;
  AnimationController _controller;
  Animation<double> _animation;
  Future _getDefaultTime() async {
    var defaultSleepTimerStorage = KeyValueStorage(defaultSleepTimerKey);
    var defaultTime = await defaultSleepTimerStorage.getInt(defaultValue: 30);
    if (mounted) setState(() => _minSelected = defaultTime);
  }

  @override
  void initState() {
    super.initState();
    _minSelected = 30;
    _getDefaultTime();
    _openClock = false;
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
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
                            : _openClock
                                ? SleepTimerPicker(
                                    onChange: (duration) {
                                      setState(() {
                                        _minSelected = duration.inMinutes;
                                      });
                                    },
                                  )
                                : Wrap(
                                    direction: Axis.horizontal,
                                    children: kMinsToSelect
                                        .map((e) => InkWell(
                                              onTap: () => setState(
                                                  () => _minSelected = e),
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
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            (e == _minSelected)
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
                        child: Row(
                          children: [
                            Text(context.s.sleepTimer,
                                style: TextStyle(
                                    color: context.accentColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                            Spacer(),
                            Material(
                              borderRadius: BorderRadius.circular(100),
                              color: context.primaryColor,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(15.0),
                                onTap: () {
                                  setState(() {
                                    _openClock = !_openClock;
                                  });
                                },
                                child: SizedBox(
                                  height: 30.0,
                                  width: 30.0,
                                  child: Icon(
                                    _openClock
                                        ? LineIcons.stopwatch
                                        : LineIcons.clock,
                                    size: 20.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                if (move > 0)
                  Positioned(
                    bottom: 120,
                    left: width / 2 - 100,
                    width: 200,
                    child: Center(
                      child: Transform.translate(
                        offset: Offset(0, -50 * move),
                        child: Text(s.goodNight,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white.withOpacity(move))),
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

class ChaptersWidget extends StatefulWidget {
  ChaptersWidget({Key key}) : super(key: key);

  @override
  _ChaptersWidgetState createState() => _ChaptersWidgetState();
}

class _ChaptersWidgetState extends State<ChaptersWidget> {
  bool _showChapter;

  @override
  void initState() {
    super.initState();
    _showChapter = false;
  }

  Future<List<Chapters>> _getChapters(EpisodeBrief episode) async {
    if (episode.chapterLink == '' || episode.chapterLink == null) {
      return [];
    }
    try {
      final file =
          await DefaultCacheManager().getSingleFile(episode.chapterLink);
      final response = file.readAsStringSync();
      var chapterInfo = ChapterInfo.fromJson(jsonDecode(response));
      return chapterInfo.chapters;
    } catch (e) {
      developer.log('Download cahpter error', error: e);
      return [];
    }
  }

  Widget _chapterDetailWidget(Chapters chapters) {
    return Column(
      children: [
        Container(
          // height: 60,
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ButtonTheme(
                  height: 28,
                  padding: EdgeInsets.symmetric(horizontal: 0),
                  child: OutlineButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100.0),
                        side: BorderSide(color: context.accentColor)),
                    highlightedBorderColor: Colors.green[700],
                    onPressed: () {
                      context
                          .read<AudioPlayerNotifier>()
                          .seekTo(chapters.startTime * 1000);
                    },
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CustomPaint(
                            painter:
                                ListenedPainter(context.textColor, stroke: 2.0),
                          ),
                        ),
                        SizedBox(width: 5),
                        Text(
                          chapters.startTime.toTime,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15),
                  Text(chapters.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodyText1),
                  if (chapters.url != '')
                    Row(
                      children: [
                        Expanded(
                            child: Text(chapters.url,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: context.accentColor))),
                        TextButton(
                            style: ButtonStyle(
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  context.accentColor),
                              overlayColor: MaterialStateProperty.all<Color>(
                                  context.primaryColor.withOpacity(0.3)),
                            ),
                            onPressed: () => chapters.url.launchUrl,
                            child: Text('Visit')),
                      ],
                    ),
                  if (chapters.img != '')
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: _ChapterImage(chapters.img),
                    )
                ],
              )),
              SizedBox(width: 8)
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        alignment: Alignment.topLeft,
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.accentColor.withAlpha(70),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Selector<AudioPlayerNotifier, EpisodeBrief>(
          selector: (_, audio) => audio.episode,
          builder: (_, episode, __) => Scrollbar(
            child: Column(
              children: [
                Expanded(
                  child: _showChapter
                      ? FutureBuilder<List<Chapters>>(
                          future: _getChapters(episode),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final data = snapshot.data;
                              return ListView.builder(
                                  itemCount: data.length,
                                  padding: EdgeInsets.zero,
                                  itemBuilder: (context, index) {
                                    return _chapterDetailWidget(data[index]);
                                  });
                            }
                            return Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: Platform.isIOS
                                    ? CupertinoActivityIndicator()
                                    : CircularProgressIndicator(),
                              ),
                            );
                          })
                      : ListView(
                          padding: EdgeInsets.zero,
                          children: <Widget>[
                            if (episode.episodeImage != '')
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: CachedNetworkImage(
                                    width: 100,
                                    fit: BoxFit.fitWidth,
                                    alignment: Alignment.center,
                                    imageUrl: episode.episodeImage,
                                    placeholderFadeInDuration: Duration.zero,
                                    progressIndicatorBuilder: (context, url,
                                            downloadProgress) =>
                                        Container(
                                          height: 50,
                                          width: 50,
                                          alignment: Alignment.center,
                                          child: SizedBox(
                                            width: 20,
                                            height: 2,
                                            child: LinearProgressIndicator(
                                                value:
                                                    downloadProgress.progress),
                                          ),
                                        ),
                                    errorWidget: (context, url, error) =>
                                        Center()),
                              ),
                            ShowNote(episode: episode)
                          ],
                        ),
                ),
                SizedBox(
                  height: 60.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: <Widget>[
                        Text(
                          context.s.homeToprightMenuAbout,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                              color: context.accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        Spacer(),
                        SizedBox(width: 20),
                        if (episode.chapterLink != '')
                          Material(
                            borderRadius: BorderRadius.circular(100),
                            color: context.primaryColor,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(15.0),
                              onTap: () {
                                setState(() {
                                  _showChapter = !_showChapter;
                                });
                              },
                              child: SizedBox(
                                  height: 30.0,
                                  width: 30.0,
                                  child: !_showChapter
                                      ? Icon(Icons.bookmark_border_outlined,
                                          size: 18)
                                      : Icon(Icons.chrome_reader_mode_outlined,
                                          size: 18)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChapterImage extends StatefulWidget {
  final String url;
  _ChapterImage(this.url, {Key key}) : super(key: key);

  @override
  __ChapterImageState createState() => __ChapterImageState();
}

class __ChapterImageState extends State<_ChapterImage> {
  bool _openFullImage;
  @override
  void initState() {
    super.initState();
    _openFullImage = false;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => _openFullImage = !_openFullImage),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            CachedNetworkImage(
                width: double.infinity,
                height: _openFullImage ? null : 50,
                fit: BoxFit.fitWidth,
                alignment: Alignment.center,
                imageUrl: widget.url,
                placeholderFadeInDuration: Duration.zero,
                progressIndicatorBuilder: (contlext, url, downloadProgress) =>
                    Container(
                      height: 50,
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 20,
                        height: 2,
                        child: LinearProgressIndicator(
                            value: downloadProgress.progress),
                      ),
                    ),
                errorWidget: (context, url, error) => Center()),
            if (!_openFullImage)
              Container(
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(
                      color: Colors.black38,
                      offset: Offset(0, -5),
                      blurRadius: 20,
                      spreadRadius: 10)
                ]),
              )
          ],
        ),
      ),
    );
  }
}

class ControlPanel extends StatefulWidget {
  ControlPanel(
      {this.onExpand,
      this.onClose,
      this.maxHeight,
      this.isPlayingPage = false,
      Key key})
      : super(key: key);
  final VoidCallback onExpand;
  final VoidCallback onClose;
  final double maxHeight;
  final bool isPlayingPage;
  @override
  _ControlPanelState createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel>
    with TickerProviderStateMixin {
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

  Future<List<double>> _getSpeedList() async {
    var storage = KeyValueStorage('speedListKey');
    return await storage.getSpeedList();
  }

  @override
  void initState() {
    _setSpeed = 0;
    _tabController = TabController(vsync: this, length: 3)
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
        var height = constraints.maxHeight;
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
                        padding: EdgeInsets.only(top: 20, left: 30, right: 30),
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            //activeTrackColor: height <= widget.maxHeight
                            activeTrackColor: context.accentColor.withAlpha(70),
                            //   : Colors.transparent,
                            inactiveTrackColor: context.primaryColorDark,
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
                        child: Row(
                          children: <Widget>[
                            Text(
                              (data.backgroundAudioPosition ~/ 1000).toTime ??
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
                                                    AudioProcessingState.loading
                                            ? context.s.buffering
                                            : '',
                                        style: TextStyle(
                                            color: context.accentColor),
                                      ),
                              ),
                            ),
                            Text(
                              (data.backgroundAudioDuration ~/ 1000).toTime ??
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
                          FlatButton(
                            color: Colors.transparent,
                            padding: EdgeInsets.only(right: 10, left: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100.0),
                                side: BorderSide(color: Colors.transparent)),
                            onPressed: playing ? () => audio.rewind() : null,
                            child: Row(
                              children: [
                                Icon(Icons.fast_rewind,
                                    size: 32, color: Colors.grey[500]),
                                SizedBox(width: 5),
                                Selector<AudioPlayerNotifier, int>(
                                    selector: (_, audio) => audio.rewindSeconds,
                                    builder: (_, seconds, __) => Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5.0),
                                          child: Text('$seconds s',
                                              style: GoogleFonts.teko(
                                                textBaseline:
                                                    TextBaseline.ideographic,
                                                textStyle: TextStyle(
                                                    color: Colors.grey[500],
                                                    fontSize: 25),
                                              )),
                                        )),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 30),
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                                color: context.primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: context.brightness == Brightness.dark
                                        ? Colors.black12
                                        : Colors.white10,
                                    width: 1),
                                boxShadow: context.brightness == Brightness.dark
                                    ? _customShadowNight
                                    : _customShadow),
                            child: playing
                                ? Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(30)),
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
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(30)),
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
                          FlatButton(
                            padding: EdgeInsets.only(left: 10.0, right: 10),
                            onPressed:
                                playing ? () => audio.fastForward() : null,
                            color: Colors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100.0),
                                side: BorderSide(color: Colors.transparent)),
                            child: Row(
                              children: [
                                Selector<AudioPlayerNotifier, int>(
                                    selector: (_, audio) =>
                                        audio.fastForwardSeconds,
                                    builder: (_, seconds, __) => Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5.0),
                                          child: Text('$seconds s',
                                              style: GoogleFonts.teko(
                                                textStyle: TextStyle(
                                                    color: Colors.grey[500],
                                                    fontSize: 25),
                                              )),
                                        )),
                                SizedBox(width: 10),
                                Icon(Icons.fast_forward,
                                    size: 32.0, color: Colors.grey[500]),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 80.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Selector<AudioPlayerNotifier, String>(
                        selector: (_, audio) => audio.episode.title,
                        builder: (_, title, __) {
                          return Container(
                            padding: EdgeInsets.only(left: 60, right: 60),
                            child: LayoutBuilder(
                              builder: (context, size) {
                                var span = TextSpan(
                                    text: title,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20));
                                var tp = TextPainter(
                                    text: span,
                                    maxLines: 1,
                                    textDirection: TextDirection.ltr);
                                tp.layout(maxWidth: size.maxWidth);
                                if (tp.didExceedMaxLines) {
                                  return Marquee(
                                    text: title,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                    scrollAxis: Axis.horizontal,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    if (height <= widget.maxHeight) LastPosition()
                  ],
                ),
              ),
              if (height > widget.maxHeight)
                SizedBox(
                  height: height - widget.maxHeight,
                  child: SingleChildScrollView(
                      physics: NeverScrollableScrollPhysics(),
                      child: SizedBox(
                          height: context.height - context.paddingTop - 340,
                          child: ScrollConfiguration(
                            behavior: NoGrowBehavior(),
                            child: TabBarView(
                                controller: _tabController,
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      child: PlaylistWidget()),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0),
                                    child: SleepMode(),
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      child: ChaptersWidget()),
                                ]),
                          ))),
                ),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (height <= widget.maxHeight)
                      Selector<AudioPlayerNotifier,
                          Tuple4<EpisodeBrief, bool, bool, double>>(
                        selector: (_, audio) => Tuple4(
                            audio.episode,
                            audio.stopOnComplete,
                            audio.startSleepTimer,
                            audio.currentSpeed),
                        builder: (_, data, __) {
                          final currentSpeed = data.item4 ?? 1.0;
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                if (_setSpeed == 0)
                                  Expanded(
                                    child: InkWell(
                                      onTap: () async {
                                        widget.onClose();
                                        if (!widget.isPlayingPage) {
                                          Navigator.push(
                                              context,
                                              FadeRoute(
                                                  page: EpisodeDetail(
                                                      episodeItem: data.item1,
                                                      heroTag: 'playpanel')));
                                        }
                                      },
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            height: 30.0,
                                            width: 30.0,
                                            child: CircleAvatar(
                                              backgroundImage:
                                                  data.item1.avatarImage,
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
                                      child: FutureBuilder<List<double>>(
                                        future: _getSpeedList(),
                                        initialData: [],
                                        builder: (context, snapshot) => Row(
                                          children: snapshot.data
                                              .map<Widget>((e) => InkWell(
                                                    onTap: () {
                                                      if (_setSpeed == 1) {
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
                                                                  currentSpeed &&
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
                                                                          currentSpeed
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
                                      Text(currentSpeed.toStringAsFixed(1)),
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
                        bottom: widget.maxHeight == kMaxPlayerHeight[2]
                            ? 35.0
                            : widget.maxHeight == kMaxPlayerHeight[1]
                                ? 25.0
                                : 15.0,
                        child: InkWell(
                            child: SizedBox(
                              height: 50,
                              width: 115,
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: CustomPaint(
                                    size: Size(120, 5),
                                    painter: TabIndicator(
                                        index: _tabIndex,
                                        indicatorSize: 10,
                                        fraction:
                                            (height + 16 - widget.maxHeight) /
                                                (context.height -
                                                    context.paddingTop -
                                                    20 -
                                                    widget.maxHeight),
                                        accentColor: context.accentColor,
                                        color: context.textColor)),
                              ),
                            ),
                            onTap: widget.onExpand),
                      ),
                    if (_setSpeed == 0 && height > widget.maxHeight)
                      Transform.translate(
                        offset: Offset(0, 5) *
                            (height - widget.maxHeight) /
                            (context.height -
                                context.paddingTop -
                                20 -
                                widget.maxHeight),
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
                              SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: Icon(Icons.playlist_play)),
                              SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: Transform.rotate(
                                      angle: math.pi * 0.7,
                                      child:
                                          Icon(Icons.brightness_2, size: 18))),
                              SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: Icon(Icons.library_books, size: 18)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
