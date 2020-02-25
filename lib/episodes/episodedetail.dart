import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:tsacdop/home/audioplayer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:tuple/tuple.dart';
import 'package:tsacdop/class/audiostate.dart';
import 'package:tsacdop/class/episodebrief.dart';
import 'package:tsacdop/local_storage/sqflite_localpodcast.dart';
import 'episodedownload.dart';

class EpisodeDetail extends StatefulWidget {
  final EpisodeBrief episodeItem;
  final String heroTag;
  EpisodeDetail({this.episodeItem, this.heroTag, Key key}) : super(key: key);

  @override
  _EpisodeDetailState createState() => _EpisodeDetailState();
}

class _EpisodeDetailState extends State<EpisodeDetail> {
  final textstyle = TextStyle(fontSize: 15.0, color: Colors.black);
  double downloadProgress;
  bool _loaddes;
  String path;
  Future getSDescription(String url) async {
    var dbHelper = DBHelper();
    widget.episodeItem.description = await dbHelper.getDescription(url);
    if (mounted)
      setState(() {
        _loaddes = true;
      });
  }

  _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    super.initState();
    _loaddes = false;
    getSDescription(widget.episodeItem.enclosureUrl);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Theme.of(context).accentColorBrightness,
        systemNavigationBarColor: Theme.of(context).primaryColor,
        statusBarColor: Theme.of(context).primaryColor,
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          appBar: AppBar(
            title: Text(widget.episodeItem.feedTitle),
            centerTitle: true,
          ),
          body: Stack(
            children: <Widget>[
              Container(
                color: Theme.of(context).primaryColor,
                padding: EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.0),
                            alignment: Alignment.topLeft,
                            child: Text(
                              widget.episodeItem.title,
                              style: Theme.of(context).textTheme.headline5,
                            ),
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(horizontal: 12.0),
                            height: 30.0,
                            child: Text(
                                'Published ' +
                                    DateFormat.yMMMd().format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            widget.episodeItem.pubDate)),
                                style: TextStyle(color: Colors.blue[500])),
                          ),
                          Container(
                            padding: EdgeInsets.all(12.0),
                            height: 50.0,
                            child: Row(
                              children: <Widget>[
                                (widget.episodeItem.explicit == 1)
                                    ? Container(
                                        decoration: BoxDecoration(
                                            color: Colors.red[800],
                                            shape: BoxShape.circle),
                                        height: 25.0,
                                        width: 25.0,
                                        margin: EdgeInsets.only(right: 10.0),
                                        alignment: Alignment.center,
                                        child: Text('E',
                                            style:
                                                TextStyle(color: Colors.white)))
                                    : Center(),
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.cyan[300],
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(15.0))),
                                  height: 30.0,
                                  margin: EdgeInsets.only(right: 10.0),
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.0),
                                  alignment: Alignment.center,
                                  child: Text(
                                      (widget.episodeItem.duration).toString() +
                                          'mins',
                                      style: textstyle),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.lightBlue[300],
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(15.0))),
                                  height: 30.0,
                                  margin: EdgeInsets.only(right: 10.0),
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.0),
                                  alignment: Alignment.center,
                                  child: Text(
                                      ((widget.episodeItem.enclosureLength) ~/
                                                  1000000)
                                              .toString() +
                                          'MB',
                                      style: textstyle),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding:
                            EdgeInsets.only(left: 12.0, right: 12.0, top: 5.0),
                        child: SingleChildScrollView(
                          child: _loaddes
                              ? (widget.episodeItem.description.contains('<'))
                                  ? Html(
                                      data: widget.episodeItem.description,
                                      onLinkTap: (url) {
                                        _launchUrl(url);
                                      },
                                      useRichText: true,
                                    )
                                  : Container(
                                      alignment: Alignment.topLeft,
                                      child:
                                          Text(widget.episodeItem.description))
                              : Center(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Selector<AudioPlayer, bool>(
                  selector: (_, audio) => audio.playerRunning,
                  builder: (_, data, __) {
                    return Container(
                      alignment: Alignment.bottomCenter,
                      padding: EdgeInsets.only(
                          left: 5.0,
                          right: 5.0,
                          bottom: data == true ? 80.0 : 10.0),
                      child: MenuBar(
                        episodeItem: widget.episodeItem,
                        heroTag: widget.heroTag,
                      ),
                    );
                  }),
              Container(child: PlayerWidget()),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuBar extends StatefulWidget {
  final EpisodeBrief episodeItem;
  final String heroTag;
  MenuBar({this.episodeItem, this.heroTag, Key key}) : super(key: key);
  @override
  _MenuBarState createState() => _MenuBarState();
}

class _MenuBarState extends State<MenuBar> {
  bool _liked;
  int _like;

  Future<int> saveLiked(String url) async {
    var dbHelper = DBHelper();
    int result = await dbHelper.setLiked(url);
    if (result == 1 && mounted) setState(() => _liked = true);
    return result;
  }

  Future<int> setUnliked(String url) async {
    var dbHelper = DBHelper();
    int result = await dbHelper.setUniked(url);
    if (result == 1 && mounted)
      setState(() {
        _liked = false;
        _like = 0;
      });
    return result;
  }

  @override
  void initState() {
    super.initState();
    _liked = false;
    _like = widget.episodeItem.liked;
  }

  Widget _buttonOnMenu(Widget widget, VoidCallback onTap) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
              height: 50.0,
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: widget),
        ),
      );

  @override
  Widget build(BuildContext context) {
    var audio = Provider.of<AudioPlayer>(context, listen: false);
    return Container(
      height: 50.0,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.grey[200]
              : Theme.of(context).scaffoldBackgroundColor,
        ),
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Hero(
            tag: widget.episodeItem.enclosureUrl + widget.heroTag,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal:10.0),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
                child: Container(
                  height: 30.0,
                  width: 30.0,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Image.file(File("${widget.episodeItem.imagePath}")),
                ),
              ),
            ),
          ),
          (_like == 0 && !_liked)
              ? _buttonOnMenu(
                  Icon(
                    Icons.favorite_border,
                    color: Colors.grey[700],
                  ),
                  () => saveLiked(widget.episodeItem.enclosureUrl))
              : (_like == 1 && !_liked)
                  ? _buttonOnMenu(
                      Icon(
                        Icons.favorite,
                        color: Colors.red,
                      ),
                      () => setUnliked(widget.episodeItem.enclosureUrl))
                  : Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        LoveOpen(),
                        _buttonOnMenu(
                            Icon(
                              Icons.favorite,
                              color: Colors.red,
                            ),
                            () => setUnliked(widget.episodeItem.enclosureUrl)),
                      ],
                    ),
          DownloadButton(episodeBrief: widget.episodeItem),
          _buttonOnMenu(Icon(Icons.playlist_add, color: Colors.grey[700]), () {
            Fluttertoast.showToast(
              msg: 'Added to playlist',
              gravity: ToastGravity.BOTTOM,
            );
            audio.addToPlaylist(widget.episodeItem);
          }),
          Spacer(),
          // Text(audio.audioState.toString()),
          Selector<AudioPlayer, Tuple2<EpisodeBrief, bool>>(
            selector: (_, audio) =>
                Tuple2(audio.episode, audio.backgroundAudioPlaying),
            builder: (_, data, __) {
              return (widget.episodeItem.title != data.item1?.title)
                  ? Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(5.0),
                            bottomRight: Radius.circular(5.0)),
                        onTap: () {
                          audio.episodeLoad(widget.episodeItem);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 50.0,
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            children: <Widget>[
                              Text('Play Now',
                                  style: TextStyle(
                                    color: Theme.of(context).accentColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  )),
                              Icon(
                                Icons.play_arrow,
                                color: Theme.of(context).accentColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : (widget.episodeItem.title == data.item1?.title &&
                          data.item2 == true)
                      ? Container(
                          padding: EdgeInsets.only(right: 30),
                          child: SizedBox(
                              width: 20, height: 15, child: WaveLoader()))
                      : Container(
                          padding: EdgeInsets.only(right: 30),
                          child: SizedBox(
                            width: 20,
                            height: 15,
                            child: LineLoader(),
                          ),
                        );
            },
          ),
        ],
      ),
    );
  }
}

class LinePainter extends CustomPainter {
  double _fraction;
  Paint _paint;
  LinePainter(this._fraction) {
    _paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(Offset(0, size.height / 2.0),
        Offset(size.width * _fraction, size.height / 2.0), _paint);
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) {
    return oldDelegate._fraction != _fraction;
  }
}

class LineLoader extends StatefulWidget {
  @override
  _LineLoaderState createState() => _LineLoaderState();
}

class _LineLoaderState extends State<LineLoader>
    with SingleTickerProviderStateMixin {
  double _fraction = 0.0;
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
            _fraction = animation.value;
          });
      });
    controller.forward();
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reset();
      } else if (status == AnimationStatus.dismissed) {
        controller.forward();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: LinePainter(_fraction));
  }
}

class WavePainter extends CustomPainter {
  double _fraction;
  double _value;
  WavePainter(this._fraction);
  @override
  void paint(Canvas canvas, Size size) {
    if (_fraction < 0.5) {
      _value = _fraction;
    } else {
      _value = 1 - _fraction;
    }
    Path _path = Path();
    Paint _paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    _path.moveTo(0, size.height / 2);
    _path.lineTo(0, size.height / 2 + size.height * _value * 0.2);
    _path.moveTo(0, size.height / 2);
    _path.lineTo(0, size.height / 2 - size.height * _value * 0.2);
    _path.moveTo(size.width / 4, size.height / 2);
    _path.lineTo(size.width / 4, size.height / 2 + size.height * _value * 0.8);
    _path.moveTo(size.width / 4, size.height / 2);
    _path.lineTo(size.width / 4, size.height / 2 - size.height * _value * 0.8);
    _path.moveTo(size.width / 2, size.height / 2);
    _path.lineTo(size.width / 2, size.height / 2 + size.height * _value * 0.5);
    _path.moveTo(size.width / 2, size.height / 2);
    _path.lineTo(size.width / 2, size.height / 2 - size.height * _value * 0.5);
    _path.moveTo(size.width * 3 / 4, size.height / 2);
    _path.lineTo(
        size.width * 3 / 4, size.height / 2 + size.height * _value * 0.6);
    _path.moveTo(size.width * 3 / 4, size.height / 2);
    _path.lineTo(
        size.width * 3 / 4, size.height / 2 - size.height * _value * 0.6);
    _path.moveTo(size.width, size.height / 2);
    _path.lineTo(size.width, size.height / 2 + size.height * _value * 0.2);
    _path.moveTo(size.width, size.height / 2);
    _path.lineTo(size.width, size.height / 2 - size.height * _value * 0.2);
    canvas.drawPath(_path, _paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return oldDelegate._fraction != _fraction;
  }
}

class WaveLoader extends StatefulWidget {
  @override
  _WaveLoaderState createState() => _WaveLoaderState();
}

class _WaveLoaderState extends State<WaveLoader>
    with SingleTickerProviderStateMixin {
  double _fraction = 0.0;
  Animation animation;
  AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    animation = Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        if (mounted)
          setState(() {
            _fraction = animation.value;
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
    return CustomPaint(painter: WavePainter(_fraction));
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

class LovePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path _path = Path();
    Paint _paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    _path.moveTo(size.width / 2, size.height / 6);
    _path.quadraticBezierTo(size.width / 4, 0, size.width / 8, size.height / 6);
    _path.quadraticBezierTo(
        0, size.height / 3, size.width / 8, size.height * 0.55);
    _path.quadraticBezierTo(
        size.width / 4, size.height * 0.8, size.width / 2, size.height);
    _path.quadraticBezierTo(size.width * 0.75, size.height * 0.8,
        size.width * 7 / 8, size.height * 0.55);
    _path.quadraticBezierTo(
        size.width, size.height / 3, size.width * 7 / 8, size.height / 6);
    _path.quadraticBezierTo(
        size.width * 3 / 4, 0, size.width / 2, size.height / 6);

    canvas.drawPath(_path, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class LoveOpen extends StatefulWidget {
  @override
  _LoveOpenState createState() => _LoveOpenState();
}

class _LoveOpenState extends State<LoveOpen>
    with SingleTickerProviderStateMixin {
  Animation _animationA;
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _animationA = Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        if (mounted) setState(() {});
      });

    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _littleHeart(double scale, double value, double angle) => Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: value),
        child: ScaleTransition(
          scale: _animationA,
          alignment: Alignment.center,
          child: Transform.rotate(
            angle: angle,
            child: SizedBox(
              height: 5 * scale,
              width: 6 * scale,
              child: CustomPaint(
                painter: LovePainter(),
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Row(
            children: <Widget>[
              _littleHeart(0.5, 10, -math.pi / 6),
              _littleHeart(1.2, 3, 0),
            ],
          ),
          Row(
            children: <Widget>[
              _littleHeart(0.8, 6, math.pi * 1.5),
              _littleHeart(0.9, 24, math.pi / 2),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              _littleHeart(1, 8, -math.pi * 0.7),
              _littleHeart(0.8, 8, math.pi),
              _littleHeart(0.6, 3, -math.pi * 1.2)
            ],
          ),
        ],
      ),
    );
  }
}
