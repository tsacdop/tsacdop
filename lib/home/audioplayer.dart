import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marquee/marquee.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tuple/tuple.dart';
import 'package:audio_service/audio_service.dart';

import 'package:tsacdop/class/episodebrief.dart';
import 'package:tsacdop/class/audiostate.dart';
import 'package:tsacdop/episodes/episodedetail.dart';
import 'package:tsacdop/home/audiopanel.dart';
import 'package:tsacdop/util/pageroute.dart';
import 'package:tsacdop/util/colorize.dart';

//Custom slider 
class MyRoundSliderThumpShape extends SliderComponentShape {
  const MyRoundSliderThumpShape({
    this.enabledThumbRadius = 10.0,
    this.disabledThumbRadius,
    this.thumbCenterColor,
  });
  final Color thumbCenterColor;

  /// The preferred radius of the round thumb shape when the slider is enabled.
  ///
  /// If it is not provided, then the material default of 10 is used.
  final double enabledThumbRadius;

  /// The preferred radius of the round thumb shape when the slider is disabled.
  ///
  /// If no disabledRadius is provided, then it is equal to the
  /// [enabledThumbRadius]
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
    assert(context != null);
    assert(center != null);
    assert(enableAnimation != null);
    assert(sliderTheme != null);
    assert(sliderTheme.disabledThumbColor != null);
    assert(sliderTheme.thumbColor != null);

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
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(center.dx - 6, center.dy),
      Offset(center.dx + 6, center.dy),
      Paint()
        ..color = Colors.grey[300]
        ..style = PaintingStyle.fill
        ..strokeWidth = 2,
    );
    canvas.drawCircle(
      center,
      radiusTween.evaluate(enableAnimation) - 2,
      Paint()
        ..color = colorTween.evaluate(enableAnimation)
        ..style = PaintingStyle.fill
        ..strokeWidth = 2,
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

  List minsToSelect = [1, 5, 10, 15, 20, 25, 30, 45, 60, 70, 80, 90, 99];
  //Show playlist widget.
  bool _showlist;
  //Show timer choose widget.
  bool _showTimer;
  //Store selected timer mins.
  int _minSelected;
  //Left time after user setting timer.
  int _timeLeft;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _showlist = false;
    _showTimer = false;
    _minSelected = 5;
    _timeLeft = 0;
  }

  setTimer() {
    _timeLeft = _minSelected;
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      setState(() {
        if (_timeLeft < 1) {
          _timer.cancel();
        } else {
          _timeLeft = _timeLeft - 1;
        }
      });
    });
  }

  Widget _sleepTimer(BuildContext context) {
    var audio = Provider.of<AudioPlayerNotifier>(context);
    return Container(
      height: 50,
      margin: EdgeInsets.all(10.0),
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: minsToSelect
                    .map((e) => InkWell(
                          onTap: () => setState(() => _minSelected = e),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.elasticOut,
                            margin: EdgeInsets.symmetric(horizontal: 10.0),
                            decoration: BoxDecoration(
                              color: (e == _minSelected)
                                  ? Theme.of(context).accentColor
                                  : Colors.grey[400],
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            height: (e == _minSelected) ? 40 : 30,
                            width: (e == _minSelected) ? 40 : 30,
                            child: Text(e.toString(),
                                style: TextStyle(
                                    color: (e == _minSelected)
                                        ? Colors.white
                                        : Colors.black)),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
          Container(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Material(
                  color: Colors.transparent,
                  child: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      setState(() => _showTimer = false);
                    },
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: IconButton(
                    icon: Icon(Icons.done),
                    onPressed: () {
                      setState(() {
                        _showTimer = false;
                      });
                      audio.sleepTimer(_minSelected);
                      setTimer();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _expandedPanel(BuildContext context) {
    var audio = Provider.of<AudioPlayerNotifier>(context, listen: false);
    return Stack(
      children: <Widget>[
        Container(
          color: Theme.of(context).primaryColor,
          height: 300,
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  height: 80.0,
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
                                decelerationDuration:
                                    Duration(milliseconds: 500),
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
                Consumer<AudioPlayerNotifier>(
                  builder: (_, data, __) {
                    Color _c =
                        (Theme.of(context).brightness == Brightness.light)
                            ? data.episode.primaryColor.colorizedark()
                            : data.episode.primaryColor.colorizeLight();
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(left: 30, right: 30),
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: Theme.of(context)
                                  .accentColor
                                  .withOpacity(0.5),
                              inactiveTrackColor: Colors.grey[300],
                              trackHeight: 2.0,
                              thumbColor: Theme.of(context).accentColor,
                              thumbShape: MyRoundSliderThumpShape(
                                  enabledThumbRadius: 5.0,
                                  disabledThumbRadius: 5.0,
                                  thumbCenterColor: _c),
                              overlayColor:
                                  Theme.of(context).accentColor.withAlpha(32),
                              overlayShape:
                                  RoundSliderOverlayShape(overlayRadius: 14.0),
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
                          padding: EdgeInsets.symmetric(horizontal: 50.0),
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
                                                      BasicPlaybackState
                                                          .connecting
                                              ? 'Buffring...'
                                              : '',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .accentColor),
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
                                onPressed:
                                    backplay == BasicPlaybackState.playing
                                        ? () => audio.forwardAudio(-10)
                                        : null,
                                iconSize: 32.0,
                                icon: Icon(Icons.replay_10),
                                color:
                                    Theme.of(context).tabBarTheme.labelColor),
                            backplay == BasicPlaybackState.playing
                                ? IconButton(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 30.0),
                                    onPressed:
                                        backplay == BasicPlaybackState.playing
                                            ? () {
                                                audio.pauseAduio();
                                              }
                                            : null,
                                    iconSize: 40.0,
                                    icon: Icon(Icons.pause_circle_filled),
                                    color: Theme.of(context)
                                        .tabBarTheme
                                        .labelColor)
                                : IconButton(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 30.0),
                                    onPressed:
                                        backplay == BasicPlaybackState.playing
                                            ? null
                                            : () {
                                                audio.resumeAudio();
                                              },
                                    iconSize: 40.0,
                                    icon: Icon(Icons.play_circle_filled),
                                    color: Theme.of(context)
                                        .tabBarTheme
                                        .labelColor),
                            IconButton(
                                padding: EdgeInsets.symmetric(horizontal: 30.0),
                                onPressed:
                                    backplay == BasicPlaybackState.playing
                                        ? () => audio.forwardAudio(30)
                                        : null,
                                iconSize: 32.0,
                                icon: Icon(Icons.forward_30),
                                color:
                                    Theme.of(context).tabBarTheme.labelColor),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Spacer(),
                !_showTimer
                    // Setting sleep timer
                    ? Container(
                        height: 50.0,
                        margin: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        child: Selector<AudioPlayerNotifier,
                            Tuple3<EpisodeBrief, bool, bool>>(
                          selector: (_, audio) => Tuple3(audio.episode,
                              audio.stopOnComplete, audio.showStopWatch),
                          builder: (_, data, __) {
                            return Row(
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
                                    backgroundImage: FileImage(
                                        File("${data.item1.imagePath}")),
                                  ),
                                ),
                                Spacer(),
                                Material(
                                  color: Colors.transparent,
                                  child: !data.item3
                                      ? PopupMenuButton(
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10))),
                                          elevation: 1,
                                          tooltip: 'Sleep Timer',
                                          icon: Icon(
                                            Icons.brightness_2,
                                            color: data.item2
                                                ? Theme.of(context).accentColor
                                                : Theme.of(context)
                                                    .iconTheme
                                                    .color,
                                          ),
                                          itemBuilder: (context) => [
                                                PopupMenuItem(
                                                    value: 1,
                                                    child: Text(
                                                        'End of this episode')),
                                                PopupMenuItem(
                                                  value: 2,
                                                  child: Text('Timer'),
                                                ),
                                              ],
                                          onSelected: (value) {
                                            if (value == 1) {
                                              audio.sleepTimer(_minSelected);
                                              audio.setStopOnComplete = true;
                                            } else if (value == 2) {
                                              setState(() => _showTimer = true);
                                            }
                                          })
                                      : PopupMenuButton(
                                          tooltip: 'Time Left',
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10))),
                                          elevation: 1,
                                          icon: Container(
                                            alignment: Alignment.center,
                                            height: 25,
                                            width: 25,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color:
                                                  Theme.of(context).accentColor,
                                            ),
                                            child: Text(_timeLeft.toString(),
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          ),
                                          itemBuilder: (context) => [
                                            PopupMenuItem(
                                                value: 1,
                                                child: Text('Cancel')),
                                          ],
                                          onSelected: (value) {
                                            audio.cancelTimer();
                                            _timer.cancel();
                                            setState(() => _timeLeft = 0);
                                          },
                                        ),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  child: IconButton(
                                    onPressed: () => Navigator.push(
                                      context,
                                      SlideUptRoute(
                                          page: EpisodeDetail(
                                              episodeItem: data.item1,
                                              heroTag: 'playpanel')),
                                    ),
                                    icon: Icon(Icons.info),
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(10.0),
                                          bottomRight: Radius.circular(10.0)),
                                      child: Container(
                                          height: 50.0,
                                          width: 50.0,
                                          child: Icon(Icons.keyboard_arrow_up)),
                                      onTap: () =>
                                          setState(() => _showlist = true)),
                                ),
                              ],
                            );
                          },
                        ),
                      )
                    : _sleepTimer(context),
              ]),
        ),
        Container(
          alignment: Alignment.bottomLeft,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 400),
            height: _showlist ? 300 : 0,
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            // margin: EdgeInsets.all(20),
            //padding: EdgeInsets.only(bottom: 10.0),
            decoration: BoxDecoration(
              //   borderRadius: BorderRadius.all(Radius.circular(10.0)),
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'NEXT',
                          style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontWeight: FontWeight.bold),
                        ),
                        Spacer(),
                        Container(
                          height: 40.0,
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: Icon(Icons.keyboard_arrow_down),
                            onPressed: () => setState(() => _showlist = false),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Selector<AudioPlayerNotifier, List<EpisodeBrief>>(
                    selector: (_, audio) => audio.queue.playlist,
                    builder: (_, playlist, __) {
                      return ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: playlist.length,
                        itemBuilder: (BuildContext context, int index) {
                          print(playlist.length);
                          return index == 0
                              ? Center()
                              : Dismissible(
                                  background: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                                    color: Colors.grey[400],
                                  ),
                                  key: Key(playlist[index].enclosureUrl),
                                  onDismissed: (direction) async {
                                    await audio
                                        .delFromPlaylist(playlist[index]);
                                    Fluttertoast.showToast(
                                      msg: 'Removed From Playlist',
                                      gravity: ToastGravity.BOTTOM,
                                    );
                                  },
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        height: 50,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        alignment: Alignment.centerLeft,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            audio.episodeLoad(playlist[index]);
                                            setState(() => _showlist = false);
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                                                          "${playlist[index].imagePath}"))),
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    playlist[index].title,
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
                                      Divider(height: 2),
                                    ],
                                  ),
                                );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
                                onPressed:
                                    () => audio.playNext(),
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
