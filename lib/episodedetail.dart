import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import 'class/audiostate.dart';
import 'class/episodebrief.dart';
import 'class/sqflite_localpodcast.dart';
import 'episodedownload.dart';

enum DownloadState { stop, load, donwload, complete, error }

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

  Future getSDescription(String title) async {
    var dbHelper = DBHelper();
    widget.episodeItem.description = await dbHelper.getDescription(title);
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
    getSDescription(widget.episodeItem.title);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(widget.episodeItem.feedTitle),
        elevation: 0.0,
        centerTitle: true,
        backgroundColor: Colors.grey[100],
      ),
      body: Container(
        color: Colors.grey[100],
        padding: EdgeInsets.all(12.0),
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
                      style: Theme.of(context).textTheme.title,
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    height: 30.0,
                    child: Text(
                        'Published ' +
                            widget.episodeItem.pubDate.substring(0, 16),
                        style: TextStyle(color: Colors.blue[500])),
                  ),
                  Container(
                    padding: EdgeInsets.all(12.0),
                    height: 50.0,
                    child: Row(
                      children: <Widget>[
                        (widget.episodeItem.explicit == 1)
                            ? ExplicitScale() 
                            : Center(),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.cyan[300],
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0))),
                          height: 30.0,
                          margin: EdgeInsets.only(right: 10.0),
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          alignment: Alignment.center,
                          child: Text(
                              (widget.episodeItem.duration).toString() + 'mins',
                              style: textstyle),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.lightBlue[300],
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0))),
                          height: 30.0,
                          margin: EdgeInsets.only(right: 10.0),
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          alignment: Alignment.center,
                          child: Text(
                              ((widget.episodeItem.enclosureLength) ~/ 1000000)
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
                padding: EdgeInsets.only(left: 12.0, right: 12.0, top: 5.0),
                child: SingleChildScrollView(
                  child: (widget.episodeItem.description != null && _loaddes)
                      ? Html(
                          data: widget.episodeItem.description,
                          onLinkTap: (url) {
                            _launchUrl(url);
                          },
                          useRichText: true,
                        )
                      : Center(),
                ),
              ),
            ),
            MenuBar(
              episodeItem: widget.episodeItem,
              heroTag: widget.heroTag,
            ),
          ],
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

  Future<int> saveLiked(String title) async {
    var dbHelper = DBHelper();
    int result = await dbHelper.setLiked(title);
    if (result == 1 && mounted) setState(() => _liked = true);
    return result;
  }

  Future<int> setUnliked(String title) async {
    var dbHelper = DBHelper();
    int result = await dbHelper.setUniked(title);
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

  @override
  Widget build(BuildContext context) {
    final urlChange = Provider.of<Urlchange>(context);
    return Consumer<Urlchange>(
      builder: (context, urlchange, _) => Container(
        height: 50.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            (widget.episodeItem.title == urlChange.title &&
                    urlChange.audioState == AudioState.play)
                ? ImageRotate(
                    url: widget.episodeItem.imageUrl,
                  )
                : Hero(
                    tag: widget.episodeItem.enclosureUrl + widget.heroTag,
                    child: Container(
                      padding: EdgeInsets.all(10.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        child: Container(
                          height: 30.0,
                          width: 30.0,
                          color: Colors.white,
                          child: CachedNetworkImage(
                            imageUrl: widget.episodeItem.imageUrl,
                          ),
                        ),
                      ),
                    ),
                  ),
            (_like == 0 && !_liked)
                ? IconButton(
                    icon: Icon(
                      Icons.favorite_border,
                      color: Colors.grey[700],
                    ),
                    onPressed: () {
                      saveLiked(widget.episodeItem.title);
                    },
                  )
                : IconButton(
                    icon: Icon(
                      Icons.favorite,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      setUnliked(widget.episodeItem.title);
                    },
                  ),
            DownloadButton(episodeBrief: widget.episodeItem),
            IconButton(
              icon: Icon(Icons.playlist_add, color: Colors.grey[700]),
              onPressed: () {/*TODO*/},
            ),
            Spacer(),
            (widget.episodeItem.title != urlchange.title)
                ? IconButton(
                    icon: Icon(
                      Icons.play_arrow,
                      color: Colors.grey[700],
                    ),
                    onPressed: () {
                      urlChange.audioUrl = widget.episodeItem.enclosureUrl;
                      urlChange.rssTitle = widget.episodeItem.title;
                      urlChange.feedTitle = widget.episodeItem.feedTitle;
                      urlChange.imageUrl = widget.episodeItem.imageUrl;
                    },
                  )
                : (widget.episodeItem.title == urlchange.title &&
                        urlchange.audioState == AudioState.play)
                    ? Container(
                        padding: EdgeInsets.only(right: 15),
                        child: SizedBox(
                            width: 15, height: 15, child: WaveLoader()))
                    : Container(
                        padding: EdgeInsets.only(right: 15),
                        child: SizedBox(
                          width: 15,
                          height: 15,
                          child: LineLoader(),
                        ),
                      ),
          ],
        ),
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
    controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
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
  final String url;
  ImageRotate({this.url, Key key}) : super(key: key);
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
            child: CachedNetworkImage(
              imageUrl: widget.url,
            ),
          ),
        ),
      ),
    );
  }
}

class ExplicitScale extends StatefulWidget {
  @override
  _ExplicitScaleState createState() => _ExplicitScaleState();
}

 class _ExplicitScaleState extends State<ExplicitScale>
    with SingleTickerProviderStateMixin {
  Animation _animation;
  AnimationController _controller;
  double _value;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        if (mounted)
          setState(() {
            _value = _animation.value;
          });
      });
    _controller.forward();
  }

    @override
    void dispose() {
      _controller.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      return Transform.scale(
          scale: _value,
          child: Container(
              decoration:
                  BoxDecoration(color: Colors.red[800], shape: BoxShape.circle),
              height: 25.0,
              width: 25.0,
              margin: EdgeInsets.only(right: 10.0),
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              alignment: Alignment.center,
              child: Text('E', style: TextStyle(color: Colors.white))));
    }
}
