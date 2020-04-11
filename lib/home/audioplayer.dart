import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marquee/marquee.dart';
import 'package:tsacdop/home/playlist.dart';
import 'package:tsacdop/local_storage/sqflite_localpodcast.dart';
import 'package:tuple/tuple.dart';
import 'package:audio_service/audio_service.dart';
import 'package:line_icons/line_icons.dart';

import 'package:tsacdop/class/episodebrief.dart';
import 'package:tsacdop/class/audiostate.dart';
import 'package:tsacdop/episodes/episodedetail.dart';
import 'package:tsacdop/home/audiopanel.dart';
import 'package:tsacdop/util/pageroute.dart';
import 'package:tsacdop/util/colorize.dart';
import 'package:tsacdop/util/context_extension.dart';
import 'package:tsacdop/util/day_night_switch.dart';
import 'package:tsacdop/util/custompaint.dart';

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
    // final ColorTween colorTween = ColorTween(
    //   begin: sliderTheme.disabledThumbColor,
    //   end: sliderTheme.thumbColor,
    // );

    canvas.drawCircle(
      center,
      radiusTween.evaluate(enableAnimation),
      Paint()
        ..color = thumbCenterColor
        ..style = PaintingStyle.fill
        ..strokeWidth = 2,
    );

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

String _stringForSeconds(double seconds) {
  if (seconds == null) return null;
  return '${(seconds ~/ 60)}:${(seconds.truncate() % 60).toString().padLeft(2, '0')}';
}

class PlayerWidget extends StatefulWidget {
  @override
  _PlayerWidgetState createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget> {
  final GlobalKey<AnimatedListState> miniPlaylistKey = GlobalKey();

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
                                                  BasicPlaybackState
                                                      .connecting ||
                                              data.audioState ==
                                                  BasicPlaybackState.none
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
                  audio.episode, audio.stopOnComplete, audio.startSleepTimer),
              builder: (_, data, __) {
                return Container(
                  padding: EdgeInsets.all(5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
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
                        width: 150,
                        child: Text(
                          data.item1.feedTitle,
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                      Spacer(),
                      LastPosition(),
                      IconButton(
                        padding: EdgeInsets.zero,
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
      alignment: Alignment.topLeft,
      height: 300,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            height: 60.0,
            // color: context.primaryColorDark,
            alignment: Alignment.centerLeft,
            child: Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  height: 20.0,
                  // color: context.primaryColorDark,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Queue',
                    style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
                Spacer(),
                Container(
                  height: 60,
                  alignment: Alignment.center,
                  child: Container(
                    alignment: Alignment.center,
                    height: 30,
                    width: 60,
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        border: Border.all(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.black12
                                    : Colors.white10,
                            width: 1),
                        boxShadow:
                            Theme.of(context).brightness == Brightness.dark
                                ? _customShadowNight
                                : _customShadow),
                    child: Material(
                      color: Colors.transparent,
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
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 20),
                  width: 30.0,
                  height: 30.0,
                  decoration: BoxDecoration(
                    boxShadow: (Theme.of(context).brightness == Brightness.dark)
                        ? _customShadowNight
                        : _customShadow,
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
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
                ),
              ],
            ),
          ),
          Expanded(
            child:
                Selector<AudioPlayerNotifier, Tuple2<List<EpisodeBrief>, bool>>(
              selector: (_, audio) =>
                  Tuple2(audio.queue.playlist, audio.queueUpdate),
              builder: (_, data, __) {
                return AnimatedList(
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
                                          audio.episodeLoad(data.item1[index]);
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
                                                child: Container(
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
                                  Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    width: 30.0,
                                    height: 30.0,
                                    decoration: BoxDecoration(
                                      boxShadow:
                                          (Theme.of(context).brightness ==
                                                  Brightness.dark)
                                              ? _customShadowNight
                                              : _customShadow,
                                      color: Theme.of(context).primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
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
                                              .insertItem(1,
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
                );
              },
            ),
          ),
        ],
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
              SleepMode(),
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
                      height: 8.0,
                      width: 8.0,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                          border: Border.all(
                              color: Theme.of(context).accentColor,
                              width: 2.0)),
                    ),
                    Container(
                      height: 8.0,
                      width: 8.0,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                          border: Border.all(
                              color: Theme.of(context).accentColor,
                              width: 2.0)),
                    ),
                    Container(
                      height: 8.0,
                      width: 8.0,
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Spacer(),
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
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10.0),
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

class LastPosition extends StatefulWidget {
  LastPosition({Key key}) : super(key: key);

  @override
  _LastPositionState createState() => _LastPositionState();
}

class _LastPositionState extends State<LastPosition> {
  static String _stringForSeconds(double seconds) {
    if (seconds == null) return null;
    return '${(seconds ~/ 60)}:${(seconds.truncate() % 60).toString().padLeft(2, '0')}';
  }

  Future<PlayHistory> getPosition(EpisodeBrief episode) async {
    var dbHelper = DBHelper();
    return await dbHelper.getPosition(episode);
  }

  @override
  Widget build(BuildContext context) {
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
                                  width: 1,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .color),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0))),
                          child: Text('Played before'))
                      : snapshot.data.seconds < 10
                          ? Center()
                          : Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                onTap: () => audio.seekTo(
                                    (snapshot.data.seconds * 1000).toInt()),
                                child: Container(
                                  width: 120.0,
                                  height: 20.0,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyText1
                                              .color),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0))),
                                  child: Text('Last time ' +
                                      _stringForSeconds(snapshot.data.seconds)),
                                ),
                              ),
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

class SleepMode extends StatefulWidget {
  SleepMode({Key key}) : super(key: key);

  @override
  SleepModeState createState() => SleepModeState();
}

class SleepModeState extends State<SleepMode>
    with SingleTickerProviderStateMixin {
  int _minSelected;
  List minsToSelect = [10, 15, 20, 25, 30, 45, 60, 70, 80, 90, 99];
  AnimationController _controller;
  Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _minSelected = 30;
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        Provider.of<AudioPlayerNotifier>(context, listen: false)
            .setSwitchValue = _animation.value;
      });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Provider.of<AudioPlayerNotifier>(context, listen: false)
            .sleepTimer(_minSelected);
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
    final ColorTween _colorTween =
        ColorTween(begin: context.primaryColor, end: Colors.black);
    var audio = Provider.of<AudioPlayerNotifier>(context, listen: false);
    return Selector<AudioPlayerNotifier, Tuple3<int, double, SleepTimerMode>>(
      selector: (_, audio) =>
          Tuple3(audio.timeLeft, audio.switchValue, audio.sleepTimerMode),
      builder: (_, data, __) {
        double fraction = data.item2 < 0.5 ? data.item2 * 2 : 1;
        double move = data.item2 > 0.5 ? data.item2 * 2 - 1 : 0;
        return Container(
          height: 300,
          color: _colorTween.transform(move),
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
                                                  fraction > 0)
                                              ? (Theme.of(context).brightness ==
                                                      Brightness.dark)
                                                  ? customShadowNight(fraction)
                                                  : customShadow(fraction)
                                              : null,
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
                                        height: 30 * move,
                                        width: 30 * move,
                                        decoration: BoxDecoration(
                                            color:
                                                _colorTween.transform(fraction),
                                            shape: BoxShape.circle),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                  Stack(
                    children: <Widget>[
                      Container(
                        height: 100,
                        alignment: Alignment.center,
                      ),
                      Positioned(
                        left: data.item3 == SleepTimerMode.timer
                            ? -context.width * (move) / 4
                            : context.width * (move) / 4,
                        child: Container(
                          height: 100,
                          width: context.width,
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
                                  boxShadow:
                                      context.brightness == Brightness.light
                                          ? customShadow(fraction)
                                          : customShadowNight(fraction),
                                  color: _colorTween.transform(move),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
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
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                    child: SizedBox(
                                        height: 40,
                                        width: 120,
                                        child: Center(
                                            child: Text(
                                          'End of episode',
                                          style: TextStyle(
                                              // fontWeight: FontWeight.bold,
                                              // fontSize: 20,
                                              color: (move > 0
                                                  ? Colors.white
                                                  : null)),
                                        ))),
                                  ),
                                ),
                              ),
                              Container(
                                height: 100 * (1 - fraction),
                                width: 2,
                                color: context.primaryColorDark,
                              ),
                              Container(
                                height: 40,
                                width: 120,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: context.primaryColor),
                                  boxShadow:
                                      context.brightness == Brightness.light
                                          ? customShadow(fraction)
                                          : customShadowNight(fraction),
                                  color: _colorTween.transform(move),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
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
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                    child: SizedBox(
                                      height: 40,
                                      width: 120,
                                      child: Center(
                                        child: Text(
                                          data.item2 == 1
                                              ? _stringForSeconds(
                                                  data.item1.toDouble())
                                              : _stringForSeconds(
                                                  (_minSelected * 60)
                                                      .toDouble()),
                                          style: TextStyle(
                                              // fontWeight: FontWeight.bold,
                                              // fontSize: 20,
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
                ],
              ),
              Positioned(
                bottom: 50 + 20 * data.item2,
                left: context.width / 2 - 100,
                width: 200,
                child: Container(
                  alignment: Alignment.center,
                  child: Text('Good Night',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white.withOpacity(fraction))),
                ),
              ),
              Positioned(
                bottom: 100 * (1 - data.item2) - 30,
                left: context.width / 2 - 100,
                width: 200,
                child: Container(
                  alignment: Alignment.center,
                  child: Text('Sleep Timer',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                ),
              ),
              data.item2 == 1 ? CustomPaint(painter: StarSky()) : Center(),
              data.item2 == 1 ? MeteorLoader() : Center(),
            ],
          ),
        );
      },
    );
  }
}
