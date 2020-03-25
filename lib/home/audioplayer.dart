import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marquee/marquee.dart';
import 'package:tuple/tuple.dart';
import 'package:audio_service/audio_service.dart';

import 'package:tsacdop/class/episodebrief.dart';
import 'package:tsacdop/class/audiostate.dart';
import 'package:tsacdop/episodes/episodedetail.dart';
import 'package:tsacdop/home/audiopanel.dart';
import 'package:tsacdop/util/pageroute.dart';
import 'package:tsacdop/util/colorize.dart';
import 'package:tsacdop/util/day_night_switch.dart';

class MyRectangularTrackShape extends RectangularSliderTrackShape {
  Rect getPreferredRect({
    @required RenderBox parentBox,
    Offset offset = Offset.zero,
    @required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft - 5, trackTop, trackWidth, trackHeight);
  }
}

class MyRoundSliderThumpShape extends SliderComponentShape {
  const MyRoundSliderThumpShape({
    this.enabledThumbRadius = 10.0,
    this.disabledThumbRadius,
    this.thumbCenterColor,
  });
  final Color thumbCenterColor;
  final double enabledThumbRadius;
  final double disabledThumbRadius;
  double get _disabledThumbRadius => disabledThumbRadius ?? enabledThumbRadius;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(
        isEnabled == true ? enabledThumbRadius : _disabledThumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    Animation<double> activationAnimation,
    @required Animation<double> enableAnimation,
    bool isDiscrete,
    TextPainter labelPainter,
    RenderBox parentBox,
    @required SliderThemeData sliderTheme,
    TextDirection textDirection,
    double value,
  }) {
    final Canvas canvas = context.canvas;
    final Tween<double> radiusTween = Tween<double>(
      begin: _disabledThumbRadius,
      end: enabledThumbRadius,
    );
    final ColorTween colorTween = ColorTween(
      begin: sliderTheme.disabledThumbColor,
      end: sliderTheme.thumbColor,
    );

    canvas.drawCircle(
      center,
      radiusTween.evaluate(enableAnimation),
      Paint()
        ..color = thumbCenterColor
        ..style = PaintingStyle.fill
        ..strokeWidth = 2,
    );

    // Path _path = Path();

    // _path.moveTo(center.dx - 12, center.dy + 10);
    // _path.lineTo(center.dx - 12, center.dy - 12);
    // _path.lineTo(center.dx -12, center.dy - 12);
    // canvas.drawShadow(_path, Colors.black, 4, false);

    // Path _pathLight = Path();
    // _pathLight.moveTo(center.dx + 12, center.dy - 12);
    // _pathLight.lineTo(center.dx + 12, center.dy + 10);
    //// _pathLight.lineTo(center.dx - 12, center.dy + 10);
    // canvas.drawShadow(_pathLight, Colors.black, 4, true);
    canvas.drawRect(
      Rect.fromLTRB(
          center.dx - 10, center.dy + 10, center.dx + 10, center.dy - 10),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill
        ..strokeWidth = 10,
    );

    canvas.drawLine(
      Offset(center.dx - 5, center.dy - 2),
      Offset(center.dx + 5, center.dy + 2),
      Paint()
        ..color = Colors.transparent
        ..style = PaintingStyle.fill
        ..strokeWidth = 2,
    );
  }
}

class PlayerWidget extends StatefulWidget {
  @override
  _PlayerWidgetState createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget> {
  static String _stringForSeconds(double seconds) {
    if (seconds == null) return null;
    return '${(seconds ~/ 60)}:${(seconds.truncate() % 60).toString().padLeft(2, '0')}';
  }

  List<BoxShadow> _customShadow = [
    BoxShadow(blurRadius: 26, offset: Offset(-6, -6), color: Colors.white),
    BoxShadow(
        blurRadius: 8,
        offset: Offset(2, 2),
        color: Colors.grey[600].withOpacity(0.4))
  ];

  List<BoxShadow> _customShadowNight = [
    BoxShadow(
        blurRadius: 6,
        offset: Offset(-1, -1),
        color: Colors.grey[100].withOpacity(0.3)),
    BoxShadow(blurRadius: 8, offset: Offset(2, 2), color: Colors.black)
  ];

  List minsToSelect = [1, 5, 10, 15, 20, 25, 30, 45, 60, 70, 80, 90, 99];
  int _minSelected;

  @override
  void initState() {
    super.initState();
    _minSelected = 30;
  }

  @override
  void didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  Widget _sleppMode(BuildContext context) {
    var audio = Provider.of<AudioPlayerNotifier>(context, listen: false);
    return Selector<AudioPlayerNotifier, Tuple3<bool, int, double>>(
      selector: (_, audio) =>
          Tuple3(audio.showStopWatch, audio.timeLeft, audio.switchValue),
      builder: (_, data, __) {
        return Container(
          height: 300,
          color: data.item3 > 0
              ? Colors.black.withOpacity(data.item3)
              : Theme.of(context).primaryColor,
          child: Stack(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(5),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: minsToSelect
                            .map((e) => InkWell(
                                  onTap: () => setState(() => _minSelected = e),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 10.0),
                                        decoration: BoxDecoration(
                                          boxShadow: !(e == _minSelected ||
                                                  data.item3 > 0)
                                              ? (Theme.of(context).brightness ==
                                                      Brightness.dark)
                                                  ? _customShadowNight
                                                  : _customShadow
                                              : [
                                                  BoxShadow(
                                                      color: Colors.black,
                                                      blurRadius: 0,
                                                      offset: Offset(0, 0)),
                                                ],
                                          color: (e == _minSelected)
                                              ? Theme.of(context).accentColor
                                              : Theme.of(context).primaryColor,
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
                                      Container(
                                        height: 30 * data.item3,
                                        width: 30 * data.item3,
                                        decoration: BoxDecoration(
                                            color: Colors.black
                                                .withOpacity(data.item3),
                                            shape: BoxShape.circle),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                  Container(
                    height: 100,
                    alignment: Alignment.center,
                    child: Transform.scale(
                      scale: 0.5,
                      child: DayNightSwitch(
                        height: 10,
                        value: data.item1,
                        sunColor: Colors.yellow[700],
                        moonColor: Colors.grey[600],
                        dayColor: Theme.of(context).primaryColorDark,
                        nightColor: Colors.black,
                        onDrag: (value) => audio.setSwitchValue = value,
                        onChanged: (value) {
                          if (value) {
                            audio.sleepTimer(_minSelected);
                          } else {
                            audio.cancelTimer();
                          }
                        },
                      ),
                    ),
                  ),
                  Container(
                    height: 70,
                    alignment: Alignment.center,
                    child: Column(
                      children: <Widget>[
                        Container(
                          alignment: Alignment.center,
                          height: 25,
                          width: 100,
                          decoration: BoxDecoration(),
                          child: Text(_stringForSeconds(data.item2.toDouble()),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color:
                                      (data.item3 > 0) ? Colors.white : null)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 50 + 20 * data.item3,
                left: MediaQuery.of(context).size.width / 2 - 100,
                width: 200,
                child: Container(
                  alignment: Alignment.center,
                  child: Text('Good Night',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white.withOpacity(data.item3))),
                ),
              ),
              Positioned(
                bottom: 100 * (1 - data.item3) - 30,
                left: MediaQuery.of(context).size.width / 2 - 100,
                width: 200,
                child: Container(
                  alignment: Alignment.center,
                  child: Text('Sleep Timer',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                ),
              ),
              data.item1 ? CustomPaint(painter: StarSky()) : Center(),
              data.item1 ? MeteorLoader() : Center(),
            ],
          ),
        );
      },
    );
  }

  Widget _controlPanel(BuildContext context) {
    var audio = Provider.of<AudioPlayerNotifier>(context, listen: false);
    return Container(
      color: Theme.of(context).primaryColor,
      height: 300,
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Consumer<AudioPlayerNotifier>(
              builder: (_, data, __) {
                Color _c = (Theme.of(context).brightness == Brightness.light)
                    ? data.episode.primaryColor.colorizedark()
                    : data.episode.primaryColor.colorizeLight();
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.black38
                                  : Colors.grey[400],
                          inactiveTrackColor:
                              Theme.of(context).primaryColorDark,
                          trackHeight: 20.0,
                          trackShape: MyRectangularTrackShape(),
                          thumbColor: Theme.of(context).accentColor,
                          thumbShape: MyRoundSliderThumpShape(
                              enabledThumbRadius: 10.0,
                              disabledThumbRadius: 10.0,
                              thumbCenterColor: _c),
                          overlayColor:
                              Theme.of(context).accentColor.withAlpha(32),
                          overlayShape:
                              RoundSliderOverlayShape(overlayRadius: 4.0),
                        ),
                        child: Slider(
                            value: data.seekSliderValue,
                            onChanged: (double val) {
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
                            _stringForSeconds(
                                    data.backgroundAudioPosition / 1000) ??
                                '',
                            style: TextStyle(fontSize: 10),
                          ),
                          Expanded(
                            child: Container(
                              alignment: Alignment.center,
                              child: data.remoteErrorMessage != null
                                  ? Text(data.remoteErrorMessage,
                                      style: const TextStyle(
                                          color: const Color(0xFFFF0000)))
                                  : Text(
                                      data.audioState ==
                                                  BasicPlaybackState
                                                      .buffering ||
                                              data.audioState ==
                                                  BasicPlaybackState.connecting
                                          ? 'Buffring...'
                                          : '',
                                      style: TextStyle(
                                          color: Theme.of(context).accentColor),
                                    ),
                            ),
                          ),
                          Text(
                            _stringForSeconds(
                                    data.backgroundAudioDuration / 1000) ??
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
            Container(
              height: 100,
              child: Selector<AudioPlayerNotifier, BasicPlaybackState>(
                selector: (_, audio) => audio.audioState,
                builder: (_, backplay, __) {
                  return Material(
                    color: Colors.transparent,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                            padding: EdgeInsets.symmetric(horizontal: 30.0),
                            onPressed: backplay == BasicPlaybackState.playing
                                ? () => audio.forwardAudio(-10)
                                : null,
                            iconSize: 32.0,
                            icon: Icon(Icons.replay_10),
                            color: Colors.grey[500]),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 30),
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.black12
                                      : Colors.white10,
                                  width: 1),
                              boxShadow: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? _customShadowNight
                                  : _customShadow),
                          child: backplay == BasicPlaybackState.playing
                              ? Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30)),
                                    onTap:
                                        backplay == BasicPlaybackState.playing
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
                                    onTap:
                                        backplay == BasicPlaybackState.playing
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
                                        color: Theme.of(context).accentColor,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                        IconButton(
                            padding: EdgeInsets.symmetric(horizontal: 30.0),
                            onPressed: backplay == BasicPlaybackState.playing
                                ? () => audio.forwardAudio(30)
                                : null,
                            iconSize: 32.0,
                            icon: Icon(Icons.forward_30),
                            color: Colors.grey[500]),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              height: 70.0,
              padding: EdgeInsets.all(20),
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
                            pauseAfterRound: Duration(seconds: 1),
                            startPadding: 30.0,
                            accelerationDuration: Duration(seconds: 1),
                            accelerationCurve: Curves.linear,
                            decelerationDuration: Duration(milliseconds: 500),
                            decelerationCurve: Curves.easeOut,
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
            Spacer(),
            Selector<AudioPlayerNotifier, Tuple3<EpisodeBrief, bool, bool>>(
              selector: (_, audio) => Tuple3(
                  audio.episode, audio.stopOnComplete, audio.showStopWatch),
              builder: (_, data, __) {
                return Container(
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(5.0),
                      ),
                      Container(
                        height: 30.0,
                        width: 30.0,
                        child: CircleAvatar(
                          backgroundImage:
                              FileImage(File("${data.item1.imagePath}")),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 5.0),
                        width: 200,
                        child: Text(data.item1.feedTitle, maxLines: 1, overflow: TextOverflow.fade,),
                      ),
                      Spacer(),
                      IconButton(
                        onPressed: () => Navigator.push(
                          context,
                          SlideUptRoute(
                              page: EpisodeDetail(
                                  episodeItem: data.item1,
                                  heroTag: 'playpanel')),
                        ),
                        icon: Icon(Icons.info),
                      ),
                    ],
                  ),
                );
              },
            ),
          ]),
    );
  }

  Widget _playlist(BuildContext context) {
    var audio = Provider.of<AudioPlayerNotifier>(context, listen: false);
    return Container(
      alignment: Alignment.bottomLeft,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 400),
        height: 300,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        // margin: EdgeInsets.all(20),
        //padding: EdgeInsets.only(bottom: 10.0),
        decoration: BoxDecoration(
          //   borderRadius: BorderRadius.all(Radius.circular(10.0)),
          color: Theme.of(context).primaryColor,
        ),
        child: Selector<AudioPlayerNotifier, List<EpisodeBrief>>(
          selector: (_, audio) => audio.queue.playlist,
          builder: (_, playlist, __) {
            return ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: playlist.length,
              itemBuilder: (BuildContext context, int index) {
                print(playlist.length);
                if (index == 0) {
                  return Container(
                    height: 60,
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'Playlist',
                          style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        Spacer(),
                        Container(
                          alignment: Alignment.center,
                          child: Container(
                            alignment: Alignment.center,
                            height: 40,
                            width: 80,
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                border: Border.all(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.black12
                                        : Colors.white10,
                                    width: 1),
                                boxShadow: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? _customShadowNight
                                    : _customShadow),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                onTap: () => audio.playNext(),
                                child: SizedBox(
                                  height: 40,
                                  width: 80,
                                  child: Icon(
                                    Icons.skip_next,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Column(
                    children: <Widget>[
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            audio.episodeLoad(playlist[index]);
                          },
                          child: Container(
                            height: 60,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.all(10.0),
                                  child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15.0)),
                                    child: Container(
                                        height: 30.0,
                                        width: 30.0,
                                        child: Image.file(File(
                                            "${playlist[index].imagePath}"))),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      playlist[index].title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Divider(height: 2),
                    ],
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget _expandedPanel(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 3,
      child: Stack(
        children: <Widget>[
          TabBarView(
            children: <Widget>[
              _sleppMode(context),
              _controlPanel(context),
              _playlist(context),
            ],
          ),
          Positioned(
            bottom: 10,
            left: MediaQuery.of(context).size.width / 2 - 25,
            child: Container(
              alignment: Alignment.center,
              width: 50.0,
              height: 10.0,
              //color: Colors.blue,
              child: TabBar(
                  labelPadding: EdgeInsets.only(top: 0),
                  indicatorPadding: EdgeInsets.all(0),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorWeight: 0,
                  indicator: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).accentColor,
                  ),
                  tabs: <Widget>[
                    Container(
                      // child: Text('p'),
                      height: 10.0,
                      width: 10.0,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                          border: Border.all(
                              color: Theme.of(context).accentColor,
                              width: 2.0)),
                    ),
                    Container(
                      height: 10.0,
                      width: 10.0,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                          border: Border.all(
                              color: Theme.of(context).accentColor,
                              width: 2.0)),
                    ),
                    Container(
                      height: 10.0,
                      width: 10.0,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                          border: Border.all(
                              color: Theme.of(context).accentColor,
                              width: 2.0)),
                    ),
                  ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniPanel(double width, BuildContext context) {
    var audio = Provider.of<AudioPlayerNotifier>(context, listen: false);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
      height: 60,
      child:
          Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
        Selector<AudioPlayerNotifier, Tuple2<String, double>>(
          selector: (_, audio) =>
              Tuple2(audio.episode?.primaryColor, audio.seekSliderValue),
          builder: (_, data, __) {
            Color _c = (Theme.of(context).brightness == Brightness.light)
                ? data.item1.colorizedark()
                : data.item1.colorizeLight();
            return SizedBox(
                height: 2,
                child: LinearProgressIndicator(
                  value: data.item2,
                  backgroundColor: Theme.of(context).primaryColor,
                  valueColor: AlwaysStoppedAnimation<Color>(_c),
                ));
          },
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.only(left: 15, right: 10),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: Selector<AudioPlayerNotifier, String>(
                    selector: (_, audio) => audio.episode.title,
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
                      Tuple2<BasicPlaybackState, double>>(
                    selector: (_, audio) => Tuple2(
                        audio.audioState,
                        (audio.backgroundAudioDuration -
                                audio.backgroundAudioPosition) /
                            1000),
                    builder: (_, data, __) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        alignment: Alignment.center,
                        child: data.item1 == BasicPlaybackState.buffering ||
                                data.item1 == BasicPlaybackState.connecting
                            ? Text(
                                'Buffring...',
                                style: TextStyle(
                                    color: Theme.of(context).accentColor),
                              )
                            : Row(
                                children: <Widget>[
                                  Text(
                                    _stringForSeconds(data.item2) ?? '',
                                  ),
                                  Text(
                                    '  Left',
                                  ),
                                ],
                              ),
                      );
                    },
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Selector<AudioPlayerNotifier, BasicPlaybackState>(
                      selector: (_, audio) => audio.audioState,
                      builder: (_, audioplay, __) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            audioplay == BasicPlaybackState.playing
                                ? InkWell(
                                    onTap:
                                        audioplay == BasicPlaybackState.playing
                                            ? () {
                                                audio.pauseAduio();
                                              }
                                            : null,
                                    child: ImageRotate(
                                        title: audio.episode.title,
                                        path: audio.episode.imagePath),
                                  )
                                : InkWell(
                                    onTap:
                                        audioplay == BasicPlaybackState.playing
                                            ? null
                                            : () {
                                                audio.resumeAudio();
                                              },
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: <Widget>[
                                        Container(
                                          padding: EdgeInsets.all(10.0),
                                          child: Container(
                                              height: 30.0,
                                              width: 30.0,
                                              child: CircleAvatar(
                                                backgroundImage: FileImage(File(
                                                    "${audio.episode.imagePath}")),
                                              )),
                                        ),
                                        Container(
                                          height: 50.0,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.black),
                                        ),
                                        Icon(
                                          Icons.play_arrow,
                                          color: Colors.white,
                                        )
                                      ],
                                    ),
                                  ),
                            IconButton(
                                onPressed: () => audio.playNext(),
                                iconSize: 25.0,
                                icon: Icon(Icons.skip_next),
                                color:
                                    Theme.of(context).tabBarTheme.labelColor),
                          ],
                        );
                      }),
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
    double _width = MediaQuery.of(context).size.width;
    return Selector<AudioPlayerNotifier, bool>(
      selector: (_, audio) => audio.playerRunning,
      builder: (_, playerrunning, __) {
        return !playerrunning
            ? Center()
            : AudioPanel(
                miniPanel: _miniPanel(_width, context),
                expandedPanel: _expandedPanel(context));
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
        if (mounted)
          setState(() {
            _value = _animation.value;
          });
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
        padding: EdgeInsets.all(10.0),
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

class StarSky extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final points = [
      Offset(50, 100),
      Offset(150, 75),
      Offset(250, 250),
      Offset(130, 200),
      Offset(270, 150),
    ];
    final pisces = [
      Offset(9, 4),
      Offset(11, 5),
      Offset(7, 6),
      Offset(10, 7),
      Offset(8, 8),
      Offset(9, 13),
      Offset(12, 17),
      Offset(5, 19),
      Offset(7, 19)
    ].map((e) => e * 10).toList();
    final orion = [
      Offset(3, 1),
      Offset(6, 1),
      Offset(1, 4),
      Offset(2, 4),
      Offset(2, 7),
      Offset(10, 8),
      Offset(3, 10),
      Offset(8, 10),
      Offset(19, 11),
      Offset(11, 13),
      Offset(18, 14),
      Offset(5, 19),
      Offset(7, 19),
      Offset(9, 18),
      Offset(15, 19),
      Offset(16, 18),
      Offset(2, 25),
      Offset(10, 26)
    ].map((e) => Offset(e.dx * 10 + 250, e.dy * 10)).toList();

    Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPoints(ui.PointMode.points, pisces, paint);
    canvas.drawPoints(ui.PointMode.points, points, paint);
    canvas.drawPoints(ui.PointMode.points, orion, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class Meteor extends CustomPainter {
  Paint _paint;
  Meteor() {
    _paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), _paint);
  }

  @override
  bool shouldRepaint(Meteor oldDelegate) {
    return false;
  }
}

class MeteorLoader extends StatefulWidget {
  @override
  _MeteorLoaderState createState() => _MeteorLoaderState();
}

class _MeteorLoaderState extends State<MeteorLoader>
    with SingleTickerProviderStateMixin {
  double _fraction = 0.0;
  double _move = 0.0;
  Animation animation;
  AnimationController controller;
  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    animation = Tween(begin: 0.0, end: 1.0).animate(controller)
      ..addListener(() {
        if (mounted)
          setState(() {
            _move = animation.value;
            if (animation.value <= 0.5) {
              _fraction = animation.value * 2;
            } else {
              _fraction = 2 - (animation.value) * 2;
            }
          });
      });
    controller.forward();
    //  controller.addStatusListener((status) {
    //    if (status == AnimationStatus.completed) {
    //      controller.reset();
    //    } else if (status == AnimationStatus.dismissed) {
    //      controller.forward();
    //    }
    //  });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 300 * _move + 10,
      left: 150 * _move + 50,
      child: SizedBox(
          width: 50 * _fraction,
          height: 100 * _fraction,
          child: CustomPaint(painter: Meteor())),
    );
  }
}
