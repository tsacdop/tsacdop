import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marquee/marquee.dart';
import 'package:tsacdop/class/episodebrief.dart';
import 'package:tuple/tuple.dart';
import 'package:tsacdop/class/audiostate.dart';
import 'package:tsacdop/episodes/episodedetail.dart';
import 'package:tsacdop/home/audiopanel.dart';
import 'package:tsacdop/util/pageroute.dart';

class PlayerWidget extends StatefulWidget {
  @override
  _PlayerWidgetState createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget> {
  static String _stringForSeconds(double seconds) {
    if (seconds == null) return null;
    return '${(seconds ~/ 60)}:${(seconds.truncate() % 60).toString().padLeft(2, '0')}';
  }

  bool _showlist;

  @override
  void initState() {
    super.initState();
    _showlist = false;
  }

  Widget _expandedPanel(BuildContext context) {
    var audio = Provider.of<AudioPlayer>(context, listen: false);
    return !_showlist
        ? Container(
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
                    child: Selector<AudioPlayer, String>(
                      selector: (_, audio) => audio.episode.title,
                      builder: (_, title, __) {
                        return Container(
                          child: LayoutBuilder(
                            builder: (context, size) {
                              var span = TextSpan(text: title,style: TextStyle(
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
                  Consumer<AudioPlayer>(
                    builder: (_, data, __) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(left: 30, right: 30),
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: Colors.blue[100],
                                inactiveTrackColor: Colors.grey[300],
                                trackHeight: 3.0,
                                thumbColor: Colors.blue[400],
                                thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: 6.0),
                                overlayColor: Colors.blue.withAlpha(32),
                                overlayShape: RoundSliderOverlayShape(
                                    overlayRadius: 14.0),
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
                                          data.backgroundAudioPosition) ??
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
                                            data.remoteAudioLoading
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
                                          data.backgroundAudioDuration) ??
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
                    child: Selector<AudioPlayer, bool>(
                      selector: (_, audio) => audio.backgroundAudioPlaying,
                      builder: (_, backplay, __) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                                padding: EdgeInsets.symmetric(horizontal: 30.0),
                                onPressed: backplay
                                    ? () => audio.forwardAudio(-10)
                                    : null,
                                iconSize: 32.0,
                                icon: Icon(Icons.replay_10),
                                color:
                                    Theme.of(context).tabBarTheme.labelColor),
                            backplay
                                ? IconButton(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 30.0),
                                    onPressed: backplay
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
                                    onPressed: backplay
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
                                onPressed: backplay
                                    ? () => audio.forwardAudio(30)
                                    : null,
                                iconSize: 32.0,
                                icon: Icon(Icons.forward_30),
                                color:
                                    Theme.of(context).tabBarTheme.labelColor),
                          ],
                        );
                      },
                    ),
                  ),
                  Spacer(),
                  Container(
                    height: 50.0,
                    margin: EdgeInsets.symmetric(vertical: 10.0),
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: Selector<AudioPlayer, EpisodeBrief>(
                      selector: (_, audio) => audio.episode,
                      builder: (_, episode, __) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.start,
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
                                    child: Image.file(
                                        File("${episode.imagePath}"))),
                              ),
                            ),
                            Spacer(),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  SlideUptRoute(
                                      page: EpisodeDetail(
                                          episodeItem: episode,
                                          heroTag: 'playpanel')),
                                ),
                                child: Icon(Icons.info),
                              ),
                            ),
                            IconButton(
                                icon: Icon(Icons.keyboard_arrow_up),
                                onPressed: () =>
                                    setState(() => _showlist = true)),
                          ],
                        );
                      },
                    ),
                  ),
                ]),
          )
        : Container(
            height: 300,
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: Selector<AudioPlayer, List<EpisodeBrief>>(
              selector: (_, audio) => audio.queue.playlist,
              builder: (_, playlist, __) {
                print(playlist.first.title);
                double _width = MediaQuery.of(context).size.width;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      height: 30.0,
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(Icons.keyboard_arrow_down),
                        onPressed: () => setState(() => _showlist = false),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: ListView.builder(
                          itemCount: playlist.length,
                          itemBuilder: (BuildContext context, int index) {
                            print(playlist.length);
                            return Container(
                              height: 50,
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: Divider.createBorderSide(context),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.all(10.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(15.0)),
                                      child: Container(
                                          height: 30.0,
                                          width: 30.0,
                                          child: Image.file(File(
                                              "${playlist[index].imagePath}"))),
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    width: _width - 200,
                                    child: Text(
                                      playlist[index].title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Spacer(),
                                  IconButton(
                                      icon: Icon(Icons.play_arrow),
                                      onPressed: null),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
  }

  Widget _miniPanel(double width, BuildContext context) {
    var audio = Provider.of<AudioPlayer>(context, listen: false);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      //  boxShadow: [
      //    BoxShadow(
      //      offset: Offset(0, -1),
      //      blurRadius: 4,
      //      color: Colors.grey[400],
      //    ),
      //  ],
      ),
      height: 60,
      child:
          Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
        Selector<AudioPlayer, Tuple2<String, double>>(
          selector: (_, audio) =>
              Tuple2(audio.episode?.primaryColor, audio.seekSliderValue),
          builder: (_, data, __) {
            var color = json.decode(data.item1);
            Color _c;
            if (Theme.of(context).brightness == Brightness.light) {
              _c = (color[0] > 200 && color[1] > 200 && color[2] > 200)
                  ? Color.fromRGBO(
                      (255 - color[0]), 255 - color[1], 255 - color[2], 1.0)
                  : Color.fromRGBO(color[0], color[1], color[2], 1.0);
            } else {
              _c = (color[0] < 50 && color[1] < 50 && color[2] < 50)
                  ? Color.fromRGBO(
                      (255 - color[0]), 255 - color[1], 255 - color[2], 1.0)
                  : Color.fromRGBO(color[0], color[1], color[2], 1.0);
            }
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
                  child: Selector<AudioPlayer, String>(
                    selector: (_, audio) => audio.episode.title,
                    builder: (_, title, __) {
                      return LayoutBuilder(
                        builder: (context, size) {
                          var span = TextSpan(text: title, style: TextStyle(fontWeight: FontWeight.bold),);
                          var tp = TextPainter(
                              text: span,
                              maxLines: 2,
                              textDirection: TextDirection.ltr);
                          tp.layout(maxWidth: size.maxWidth);
                          if (tp.didExceedMaxLines) {
                            return Marquee(
                              text: title,
                              style: TextStyle(fontWeight: FontWeight.bold),
                              scrollAxis: Axis.vertical,
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
                              style: TextStyle(fontWeight: FontWeight.bold),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Selector<AudioPlayer, Tuple2<bool, double>>(
                    selector: (_, audio) => Tuple2(
                        audio.remoteAudioLoading,
                        (audio.backgroundAudioDuration -
                            audio.backgroundAudioPosition)),
                    builder: (_, data, __) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        alignment: Alignment.center,
                        child: data.item1
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
                  child: Selector<AudioPlayer, bool>(
                      selector: (_, audio) => audio.backgroundAudioPlaying,
                      builder: (_, audioplay, __) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            audioplay
                                ? InkWell(
                                    onTap: audioplay
                                        ? () {
                                            audio.pauseAduio();
                                          }
                                        : null,
                                    child: ImageRotate(
                                        title: audio.episode.title,
                                        path: audio.episode.imagePath),
                                  )
                                : InkWell(
                                    onTap: audioplay
                                        ? null
                                        : () {
                                            audio.resumeAudio();
                                          },
                                    child: Container(
                                      padding: EdgeInsets.all(10.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15.0)),
                                        child: Container(
                                            height: 30.0,
                                            width: 30.0,
                                            child: Image.file(File(
                                                "${audio.episode.imagePath}"))),
                                      ),
                                    ),
                                  ),
                            IconButton(
                                onPressed: audioplay
                                    ? () => audio.forwardAudio(30)
                                    : null,
                                iconSize: 25.0,
                                icon: Icon(Icons.forward_30),
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
    return Selector<AudioPlayer, bool>(
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
