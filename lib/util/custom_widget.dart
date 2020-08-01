import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'episodegrid.dart';
import 'extension_helper.dart';

const kTwoPi = math.pi * 2;
const kPi = math.pi;
const kHalfPi = math.pi / 2;

//Layout change indicator
class LayoutPainter extends CustomPainter {
  double scale;
  Color color;
  LayoutPainter(this.scale, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    var _paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawRect(Rect.fromLTRB(0, 0, 10 + 5 * scale, 10), _paint);
    if (scale < 4) {
      canvas.drawRect(
          Rect.fromLTRB(10 + 5 * scale, 0, 20 + 10 * scale, 10), _paint);
      canvas.drawRect(
          Rect.fromLTRB(20 + 5 * scale, 0, 30, 10 - 10 * scale), _paint);
    }
  }

  @override
  bool shouldRepaint(LayoutPainter oldDelegate) {
    return oldDelegate.scale != scale || oldDelegate.color != color;
  }
}

//Dark sky used in sleep timer
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

    var paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    var _fullPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.fill;
    _darwStar(Offset center, double radius) {
      canvas.drawCircle(center, radius, paint);
      var path = Path()
        ..addOval(Rect.fromCircle(center: center, radius: radius * 2));
      canvas.drawShadow(path.shift(Offset(0, -6)), Colors.white, 6, true);
    }

    _darwBigStar(Offset center, double radius) {
      var path = Path();
      path.moveTo(center.dx - radius * 1.5, center.dy);
      path.quadraticBezierTo(center.dx - radius * 0.2, center.dy - radius * 0.2,
          center.dx, center.dy - radius * 2);
      path.quadraticBezierTo(center.dx + radius * 0.2, center.dy - radius * 0.2,
          center.dx + radius * 1.5, center.dy);
      path.quadraticBezierTo(center.dx + radius * 0.2, center.dy + radius * 0.2,
          center.dx, center.dy + radius * 2);
      path.quadraticBezierTo(center.dx - radius * 0.2, center.dy + radius * 0.2,
          center.dx - radius * 1.5, center.dy);
      path.close();

      canvas.drawPath(path, _fullPaint);
      canvas.drawShadow(path.shift(Offset(0, -6)), Colors.white, 10, true);
    }

    for (var center in pisces) {
      _darwStar(center, 2);
    }
    for (var center in orion) {
      _darwStar(center, 2);
    }
    for (var center in points) {
      _darwBigStar(center, 4);
      _darwStar(center, 2);
    }
  }

  @override
  bool shouldRepaint(StarSky oldDelegate) {
    return false;
  }
}

//Listened indicator
class ListenedPainter extends CustomPainter {
  final Color _color;
  double stroke;
  ListenedPainter(this._color, {this.stroke = 1.0});
  @override
  void paint(Canvas canvas, Size size) {
    var _paint = Paint()
      ..color = _color
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    var _path = Path();
    _path.moveTo(size.width / 6, size.height * 3 / 8);
    _path.lineTo(size.width / 6, size.height * 5 / 8);
    _path.moveTo(size.width / 3, size.height / 4);
    _path.lineTo(size.width / 3, size.height * 3 / 4);
    _path.moveTo(size.width / 2, size.height / 8);
    _path.lineTo(size.width / 2, size.height * 7 / 8);
    _path.moveTo(size.width * 5 / 6, size.height * 3 / 8);
    _path.lineTo(size.width * 5 / 6, size.height * 5 / 8);
    _path.moveTo(size.width * 2 / 3, size.height / 4);
    _path.lineTo(size.width * 2 / 3, size.height * 3 / 4);

    canvas.drawPath(_path, _paint);
  }

  @override
  bool shouldRepaint(ListenedPainter oldDelegate) {
    return false;
  }
}

//Listened Completely indicator
class ListenedAllPainter extends CustomPainter {
  final Color color;
  final double stroke;
  ListenedAllPainter(this.color, {this.stroke = 1.0});
  @override
  void paint(Canvas canvas, Size size) {
    var _paint = Paint()
      ..color = color
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    var _path = Path();
    _path.moveTo(size.width / 6, size.height * 3 / 8);
    _path.lineTo(size.width / 6, size.height * 5 / 8);
    _path.moveTo(size.width / 3, size.height / 4);
    _path.lineTo(size.width / 3, size.height * 3 / 4);
    _path.moveTo(size.width / 2, size.height * 3 / 8);
    _path.lineTo(size.width / 2, size.height * 5 / 8);
    _path.moveTo(size.width * 2 / 3, size.height * 4 / 9);
    _path.lineTo(size.width * 2 / 3, size.height * 5 / 9);
    _path.moveTo(size.width / 2, size.height * 3 / 4);
    _path.lineTo(size.width * 2 / 3, size.height * 7 / 8);
    _path.lineTo(size.width * 7 / 8, size.height * 5 / 8);

    canvas.drawPath(_path, _paint);
  }

  @override
  bool shouldRepaint(ListenedAllPainter oldDelegate) {
    return false;
  }
}

//Mark Listened indicator
class MarkListenedPainter extends CustomPainter {
  final Color color;
  double stroke;
  MarkListenedPainter(this.color, {this.stroke = 1.0});
  @override
  void paint(Canvas canvas, Size size) {
    var _paint = Paint()
      ..color = color
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    var _path = Path();
    _path.moveTo(size.width / 6, size.height * 3 / 8);
    _path.lineTo(size.width / 6, size.height * 5 / 8);
    _path.moveTo(size.width / 3, size.height / 4);
    _path.lineTo(size.width / 3, size.height * 3 / 4);
    _path.moveTo(size.width / 2, size.height * 3 / 8);
    _path.lineTo(size.width / 2, size.height * 5 / 8);
    // _path.moveTo(size.width * 2 / 3, size.height * 4 / 9);
    // _path.lineTo(size.width * 2 / 3, size.height * 5 / 9);
    _path.moveTo(size.width / 2, size.height * 13 / 18);
    _path.lineTo(size.width * 5 / 6, size.height * 13 / 18);
    _path.moveTo(size.width * 2 / 3, size.height * 5 / 9);
    _path.lineTo(size.width * 2 / 3, size.height * 8 / 9);

    canvas.drawPath(_path, _paint);
  }

  @override
  bool shouldRepaint(MarkListenedPainter oldDelegate) {
    return false;
  }
}

/// Hide listened painter.
class HideListenedPainter extends CustomPainter {
  Color color;
  Color backgroundColor;
  double fraction;
  double stroke;
  HideListenedPainter(
      {this.color, this.stroke = 1.0, this.backgroundColor, this.fraction});
  @override
  void paint(Canvas canvas, Size size) {
    var _paint = Paint()
      ..color = color
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    var _linePaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = stroke * 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    var _path = Path();

    _path.moveTo(size.width / 6, size.height * 3 / 8);
    _path.lineTo(size.width / 6, size.height * 5 / 8);
    _path.moveTo(size.width / 3, size.height / 4);
    _path.lineTo(size.width / 3, size.height * 3 / 4);
    _path.moveTo(size.width / 2, size.height / 8);
    _path.lineTo(size.width / 2, size.height * 7 / 8);
    _path.moveTo(size.width * 5 / 6, size.height * 3 / 8);
    _path.lineTo(size.width * 5 / 6, size.height * 5 / 8);
    _path.moveTo(size.width * 2 / 3, size.height / 4);
    _path.lineTo(size.width * 2 / 3, size.height * 3 / 4);

    canvas.drawPath(_path, _paint);
    if (fraction > 0) {
      canvas.drawLine(
          Offset(size.width, size.height) / 5,
          Offset(size.width, size.height) / 5 +
              Offset(size.width, size.height) * 3 / 5 * fraction,
          _linePaint);
    }
  }

  @override
  bool shouldRepaint(HideListenedPainter oldDelegate) {
    return oldDelegate.fraction != fraction;
  }
}

class HideListened extends StatefulWidget {
  final bool hideListened;
  HideListened({this.hideListened, Key key}) : super(key: key);
  @override
  _HideListenedState createState() => _HideListenedState();
}

class _HideListenedState extends State<HideListened>
    with SingleTickerProviderStateMixin {
  double _fraction = 0.0;
  Animation animation;
  AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    animation = Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        if (mounted) {
          setState(() {
            _fraction = animation.value;
          });
        }
      });
    if (widget.hideListened) _controller.forward();
  }

  @override
  void didUpdateWidget(HideListened oldWidget) {
    if (oldWidget.hideListened != widget.hideListened) {
      if (widget.hideListened) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        painter: HideListenedPainter(
            fraction: _fraction,
            color: context.textColor,
            backgroundColor: context.accentColor));
  }
}

//Add new episode to palylist
class AddToPlaylistPainter extends CustomPainter {
  final Color color;
  final Color textColor;
  AddToPlaylistPainter(this.color, this.textColor);
  @override
  void paint(Canvas canvas, Size size) {
    var _paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    var _path = Path();
    _path.moveTo(0, 0);
    _path.lineTo(size.width * 4 / 7, 0);
    _path.moveTo(0, size.height / 3);
    _path.lineTo(size.width * 4 / 7, size.height / 3);
    _path.moveTo(0, size.height * 2 / 3);
    _path.lineTo(size.width * 3 / 7, size.height * 2 / 3);
    //_path.moveTo(size.width * 3 / 7, size.height * 2 / 3);
    //_path.lineTo(size.width, size.height * 2 / 3);
    //_path.moveTo(size.width * 5 / 7, size.height / 3);
    //_path.lineTo(size.width * 5 / 7, size.height);
    // _path.moveTo(size.width*5/7, size.height/4);
    // _path.lineTo(size.width*11/14, 0);
    // _path.lineTo(size.width*13/14, size.height/4);
    // _path.lineTo(size.width, 0);
    var textPainter = TextPainter(
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: 'N',
          style: TextStyle(
              fontStyle: FontStyle.italic, color: textColor, fontSize: 10),
        ))
      ..layout();
    textPainter.paint(canvas, Offset(size.width * 4 / 7, size.height / 3));
    canvas.drawPath(_path, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

//Wave play indicator
class WavePainter extends CustomPainter {
  final double _fraction;
  double _value;
  final Color _color;
  WavePainter(this._fraction, this._color);
  @override
  void paint(Canvas canvas, Size size) {
    if (_fraction < 0.5) {
      _value = _fraction;
    } else {
      _value = 1 - _fraction;
    }
    var _path = Path();
    var _paint = Paint()
      ..color = _color
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
  final Color color;
  WaveLoader({this.color, Key key}) : super(key: key);
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
        if (mounted) {
          setState(() {
            _fraction = animation.value;
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
    return CustomPaint(
        painter: WavePainter(_fraction, widget.color ?? Colors.white));
  }
}

//Love shape
class LovePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var _path = Path();
    var _paint = Paint()
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

//Line buffer indicator
//Not used
class LinePainter extends CustomPainter {
  final double _fraction;
  Paint _paint;
  final Color _maincolor;
  LinePainter(this._fraction, this._maincolor) {
    _paint = Paint()
      ..color = _maincolor
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
        if (mounted) {
          setState(() {
            _fraction = animation.value;
          });
        }
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
    return CustomPaint(
        painter: LinePainter(_fraction, Theme.of(context).accentColor));
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
      duration: Duration(milliseconds: 1000),
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

//Heart rise
class HeartSet extends StatefulWidget {
  final double height;
  final double width;
  HeartSet({Key key, this.height, this.width}) : super(key: key);

  @override
  _HeartSetState createState() => _HeartSetState();
}

class _HeartSetState extends State<HeartSet>
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
      duration: Duration(seconds: 2),
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
    return Container(
      height: widget.height,
      width: widget.width,
      alignment: Alignment(0.5, 1 - _value),
      child: Icon(Icons.favorite,
          color: Colors.blue.withOpacity(0.7), size: 20 * _value),
    );
  }
}

class HeartOpen extends StatefulWidget {
  final double height;
  final double width;
  HeartOpen({Key key, this.height, this.width}) : super(key: key);

  @override
  _HeartOpenState createState() => _HeartOpenState();
}

class _HeartOpenState extends State<HeartOpen>
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
      duration: Duration(seconds: 2),
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
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _position(int i) {
    var scale = _list[i];
    var position = _list[i + 1];
    return Positioned(
      left: widget.width * position,
      bottom: widget.height * _value * scale,
      child: Icon(Icons.favorite,
          color: _value > 0.5
              ? Colors.red.withOpacity(2 - _value * 2)
              : Colors.red,
          size: 20 * _value * scale),
    );
  }

  final List<double> _list =
      List<double>.generate(20, (index) => math.Random().nextDouble());
  final List<int> _index = List<int>.generate(19, (index) => index);
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          height: widget.height,
          width: widget.width,
          alignment: Alignment(0.5, 1 - _value),
          child: Icon(Icons.favorite,
              color: Colors.blue.withOpacity(0.7), size: 20 * _value),
        ),
        ..._index.map<Widget>(_position).toList(),
      ],
    );
  }
}

/// Icon using a painter.
class IconPainter extends StatelessWidget {
  const IconPainter(this.painter, {this.height = 10, this.width = 30, Key key})
      : super(key: key);
  final double height;
  final double width;
  final CustomPainter painter;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: CustomPaint(
        painter: painter,
      ),
    );
  }
}

/// A dot just a dot.
class DotIndicator extends StatelessWidget {
  DotIndicator({this.radius = 8, Key key})
      : assert(radius > 0),
        super(key: key);
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: radius,
        height: radius,
        decoration:
            BoxDecoration(shape: BoxShape.circle, color: context.accentColor));
  }
}

class DownloadPainter extends CustomPainter {
  double fraction;
  Color color;
  Color progressColor;
  double progress;
  double pauseProgress;
  DownloadPainter(
      {this.fraction,
      this.color,
      this.progressColor,
      this.progress = 0,
      this.pauseProgress = 0});

  @override
  void paint(Canvas canvas, Size size) {
    var _paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    var _circlePaint = Paint()
      ..color = color.withAlpha(70)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    var _progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    var width = size.width;
    var height = size.height;
    var center = Offset(size.width / 2, size.height / 2);
    if (pauseProgress == 0) {
      canvas.drawLine(
          Offset(width / 2, 0), Offset(width / 2, height * 4 / 5), _paint);
      canvas.drawLine(Offset(width / 5, height / 2),
          Offset(width / 2, height * 4 / 5), _paint);
      canvas.drawLine(Offset(width * 4 / 5, height / 2),
          Offset(width / 2, height * 4 / 5), _paint);
    }

    if (fraction == 0) {
      canvas.drawLine(
          Offset(width / 5, height), Offset(width * 4 / 5, height), _paint);
    } else {
      canvas.drawArc(Rect.fromCircle(center: center, radius: width / 2),
          math.pi / 2, math.pi * fraction, false, _circlePaint);
      canvas.drawArc(Rect.fromCircle(center: center, radius: width / 2),
          math.pi / 2, -math.pi * fraction, false, _circlePaint);
    }

    if (fraction == 1) {
      canvas.drawArc(Rect.fromCircle(center: center, radius: width / 2),
          -math.pi / 2, math.pi * 2 * progress, false, _progressPaint);
    }

    if (pauseProgress > 0) {
      canvas.drawLine(
          Offset(width / 5 + height * 3 * pauseProgress / 20,
              height / 2 - height * 3 * pauseProgress / 10),
          Offset(width / 2 - height * 3 * pauseProgress / 20, height * 4 / 5),
          _paint);
      canvas.drawLine(
          Offset(width * 4 / 5 - height * 3 * pauseProgress / 20,
              height / 2 - height * 3 * pauseProgress / 10),
          Offset(width / 2 + height * 3 * pauseProgress / 20, height * 4 / 5),
          _paint);
    }
  }

  @override
  bool shouldRepaint(DownloadPainter oldDelegate) {
    return oldDelegate.fraction != fraction ||
        oldDelegate.progress != progress ||
        oldDelegate.pauseProgress != pauseProgress;
  }
}

/// Layout icon button.
class LayoutButton extends StatelessWidget {
  const LayoutButton({this.layout, this.onPressed, Key key}) : super(key: key);
  final Layout layout;
  final ValueChanged<Layout> onPressed;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        if (layout == Layout.three) {
          onPressed(Layout.one);
        } else if (layout == Layout.two) {
          onPressed(Layout.three);
        } else {
          onPressed(Layout.two);
        }
      },
      icon: layout == Layout.three
          ? SizedBox(
              height: 10,
              width: 30,
              child: CustomPaint(
                painter: LayoutPainter(0, context.textTheme.bodyText1.color),
              ),
            )
          : layout == Layout.two
              ? SizedBox(
                  height: 10,
                  width: 30,
                  child: CustomPaint(
                    painter:
                        LayoutPainter(1, context.textTheme.bodyText1.color),
                  ),
                )
              : SizedBox(
                  height: 10,
                  width: 30,
                  child: CustomPaint(
                    painter:
                        LayoutPainter(4, context.textTheme.bodyText1.color),
                  ),
                ),
    );
  }
}

/// Remove scroll view overlay effect.
class NoGrowBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
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

/// Used in sleep mode widget.
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
        if (mounted) {
          setState(() {
            _move = animation.value;
            if (animation.value <= 0.5) {
              _fraction = animation.value * 2;
            } else {
              _fraction = 2 - (animation.value) * 2;
            }
          });
        }
      });
    controller.forward();
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

/// Custom paint in player widget. Tab indicator.
class TabIndicator extends CustomPainter {
  double fraction;
  double indicatorSize;
  Color color;
  Color accentColor;
  int index;
  TabIndicator(
      {this.fraction,
      this.color,
      this.accentColor,
      this.indicatorSize,
      this.index});

  @override
  void paint(Canvas canvas, Size size) {
    var _paint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    var _accentPaint = Paint()
      ..color = accentColor
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    var leftStartE = Offset(indicatorSize, size.height);
    var rightStartE = Offset(size.width - indicatorSize, size.height);
    var startPoint = Offset(size.width / 2, 0);
    var leftStart = startPoint + (leftStartE - startPoint) * fraction;
    var rightStart = startPoint + (rightStartE - startPoint) * fraction;
    var leftEnd = startPoint +
        Offset(-size.height, size.height) +
        Offset(-(size.width / 2 - size.height) * fraction, 0);
    var rightEnd = startPoint +
        Offset(size.height, size.height) +
        Offset((size.width / 2 - size.height) * fraction, 0);
    canvas.drawLine(leftStart, leftEnd,
        index == 0 || fraction == 0 ? _accentPaint : _paint);
    canvas.drawLine(rightStart, rightEnd,
        index == 1 || fraction == 0 ? _accentPaint : _paint);
  }

  @override
  bool shouldRepaint(TabIndicator oldDelegate) {
    return oldDelegate.fraction != fraction || oldDelegate.index != index;
  }
}
