import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';

//Layout change indicator
class LayoutPainter extends CustomPainter {
  double scale;
  Color color;
  LayoutPainter(this.scale, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    Paint _paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawRect(Rect.fromLTRB(0, 0, 10 + 5 * scale, 10), _paint);
    canvas.drawRect(
        Rect.fromLTRB(10 + 5 * scale, 0, 20 + 10 * scale, 10), _paint);
    canvas.drawRect(
        Rect.fromLTRB(20 + 5 * scale, 0, 30, 10 - 10 * scale), _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
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

//Listened indicator
class ListenedPainter extends CustomPainter {
  Color _color;
  double stroke;
  ListenedPainter(this._color, {this.stroke = 1.0});
  @override
  void paint(Canvas canvas, Size size) {
    Paint _paint = Paint()
      ..color = _color
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    Path _path = Path();
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
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

//Listened Completely indicator
class ListenedAllPainter extends CustomPainter {
  Color _color;
  double stroke;
  ListenedAllPainter(this._color, {this.stroke = 1.0});
  @override
  void paint(Canvas canvas, Size size) {
    Paint _paint = Paint()
      ..color = _color
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    Path _path = Path();
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
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

//Wave play indicator
class WavePainter extends CustomPainter {
  double _fraction;
  double _value;
  Color _color;
  WavePainter(this._fraction, this._color);
  @override
  void paint(Canvas canvas, Size size) {
    if (_fraction < 0.5) {
      _value = _fraction;
    } else {
      _value = 1 - _fraction;
    }
    Path _path = Path();
    Paint _paint = Paint()
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
    return CustomPaint(
        painter: WavePainter(_fraction, widget.color ?? Colors.white));
  }
}

//Love shape
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

//Line buffer indicator
//Not used
class LinePainter extends CustomPainter {
  double _fraction;
  Paint _paint;
  Color _maincolor;
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
