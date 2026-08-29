import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../type/episodebrief.dart';
import '../util/extension_helper.dart';
import 'episodegrid.dart';

const kTwoPi = math.pi * 2;
const kPi = math.pi;
const kHalfPi = math.pi / 2;

//Layout change indicator
class LayoutPainter extends CustomPainter {
  double? scale;
  Color? color;
  LayoutPainter(this.scale, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color!
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawRect(Rect.fromLTRB(0, 0, 10 + 5 * scale!, 10), paint);
    if (scale! < 4) {
      canvas.drawRect(
        Rect.fromLTRB(10 + 5 * scale!, 0, 20 + 10 * scale!, 10),
        paint,
      );
      canvas.drawRect(
        Rect.fromLTRB(20 + 5 * scale!, 0, 30, 10 - 10 * scale!),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(LayoutPainter oldDelegate) {
    return oldDelegate.scale != scale || oldDelegate.color != color;
  }
}

/// Multi select button.
class MultiSelectPainter extends CustomPainter {
  Color color;
  MultiSelectPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;
    final x = size.width / 2;
    final y = size.height / 2;
    var path = Path();
    path.moveTo(0, 0);
    path.lineTo(x, 0);
    path.lineTo(x, y * 2);
    path.lineTo(x * 2, y * 2);
    path.lineTo(x * 2, y);
    path.lineTo(0, y);
    path.lineTo(0, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(MultiSelectPainter oldDelegate) {
    return false;
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
      Offset(7, 19),
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
      Offset(10, 26),
    ].map((e) => Offset(e.dx * 10 + 250, e.dy * 10)).toList();

    var paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    var fullPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.fill;
    darwStar(Offset center, double radius) {
      canvas.drawCircle(center, radius, paint);
      var path = Path()
        ..addOval(Rect.fromCircle(center: center, radius: radius * 2));
      canvas.drawShadow(path.shift(Offset(0, -6)), Colors.white, 6, true);
    }

    darwBigStar(Offset center, double radius) {
      var path = Path();
      path.moveTo(center.dx - radius * 1.5, center.dy);
      path.quadraticBezierTo(
        center.dx - radius * 0.2,
        center.dy - radius * 0.2,
        center.dx,
        center.dy - radius * 2,
      );
      path.quadraticBezierTo(
        center.dx + radius * 0.2,
        center.dy - radius * 0.2,
        center.dx + radius * 1.5,
        center.dy,
      );
      path.quadraticBezierTo(
        center.dx + radius * 0.2,
        center.dy + radius * 0.2,
        center.dx,
        center.dy + radius * 2,
      );
      path.quadraticBezierTo(
        center.dx - radius * 0.2,
        center.dy + radius * 0.2,
        center.dx - radius * 1.5,
        center.dy,
      );
      path.close();

      canvas.drawPath(path, fullPaint);
      canvas.drawShadow(path.shift(Offset(0, -6)), Colors.white, 10, true);
    }

    for (var center in pisces) {
      darwStar(center, 2);
    }
    for (var center in orion) {
      darwStar(center, 2);
    }
    for (var center in points) {
      darwBigStar(center, 4);
      darwStar(center, 2);
    }
  }

  @override
  bool shouldRepaint(StarSky oldDelegate) {
    return false;
  }
}

//Listened indicator
class ListenedPainter extends CustomPainter {
  final Color? _color;
  double stroke;
  ListenedPainter(this._color, {this.stroke = 1.0});
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = _color!
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    var path = Path();
    path.moveTo(size.width / 6, size.height * 3 / 8);
    path.lineTo(size.width / 6, size.height * 5 / 8);
    path.moveTo(size.width / 3, size.height / 4);
    path.lineTo(size.width / 3, size.height * 3 / 4);
    path.moveTo(size.width / 2, size.height / 8);
    path.lineTo(size.width / 2, size.height * 7 / 8);
    path.moveTo(size.width * 5 / 6, size.height * 3 / 8);
    path.lineTo(size.width * 5 / 6, size.height * 5 / 8);
    path.moveTo(size.width * 2 / 3, size.height / 4);
    path.lineTo(size.width * 2 / 3, size.height * 3 / 4);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ListenedPainter oldDelegate) {
    return false;
  }
}

//Listened Completely indicator
class ListenedAllPainter extends CustomPainter {
  final Color? color;
  final double stroke;
  ListenedAllPainter(this.color, {this.stroke = 1.0});
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color!
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    var path = Path();
    path.moveTo(size.width / 6, size.height * 3 / 8);
    path.lineTo(size.width / 6, size.height * 5 / 8);
    path.moveTo(size.width / 3, size.height / 4);
    path.lineTo(size.width / 3, size.height * 3 / 4);
    path.moveTo(size.width / 2, size.height * 3 / 8);
    path.lineTo(size.width / 2, size.height * 5 / 8);
    path.moveTo(size.width * 2 / 3, size.height * 4 / 9);
    path.lineTo(size.width * 2 / 3, size.height * 5 / 9);
    path.moveTo(size.width / 2, size.height * 3 / 4);
    path.lineTo(size.width * 2 / 3, size.height * 7 / 8);
    path.lineTo(size.width * 7 / 8, size.height * 5 / 8);

    canvas.drawPath(path, paint);
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
    var paint = Paint()
      ..color = color
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    var path = Path();
    path.moveTo(size.width / 6, size.height * 3 / 8);
    path.lineTo(size.width / 6, size.height * 5 / 8);
    path.moveTo(size.width / 3, size.height / 4);
    path.lineTo(size.width / 3, size.height * 3 / 4);
    path.moveTo(size.width / 2, size.height * 3 / 8);
    path.lineTo(size.width / 2, size.height * 5 / 8);
    // _path.moveTo(size.width * 2 / 3, size.height * 4 / 9);
    // _path.lineTo(size.width * 2 / 3, size.height * 5 / 9);
    path.moveTo(size.width / 2, size.height * 13 / 18);
    path.lineTo(size.width * 5 / 6, size.height * 13 / 18);
    path.moveTo(size.width * 2 / 3, size.height * 5 / 9);
    path.lineTo(size.width * 2 / 3, size.height * 8 / 9);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(MarkListenedPainter oldDelegate) {
    return false;
  }
}

/// Hide listened painter.
class HideListenedPainter extends CustomPainter {
  Color? color;
  Color? backgroundColor;
  double? fraction;
  double stroke;
  HideListenedPainter({
    this.color,
    this.stroke = 1.0,
    this.backgroundColor,
    this.fraction,
  });
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color!
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    var linePaint = Paint()
      ..color = backgroundColor!
      ..strokeWidth = stroke * 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    var path = Path();

    path.moveTo(size.width / 6, size.height * 3 / 8);
    path.lineTo(size.width / 6, size.height * 5 / 8);
    path.moveTo(size.width / 3, size.height / 4);
    path.lineTo(size.width / 3, size.height * 3 / 4);
    path.moveTo(size.width / 2, size.height / 8);
    path.lineTo(size.width / 2, size.height * 7 / 8);
    path.moveTo(size.width * 5 / 6, size.height * 3 / 8);
    path.lineTo(size.width * 5 / 6, size.height * 5 / 8);
    path.moveTo(size.width * 2 / 3, size.height / 4);
    path.lineTo(size.width * 2 / 3, size.height * 3 / 4);

    canvas.drawPath(path, paint);
    if (fraction! > 0) {
      canvas.drawLine(
        Offset(size.width, size.height) / 5,
        Offset(size.width, size.height) / 5 +
            Offset(size.width, size.height) * 3 / 5 * fraction!,
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(HideListenedPainter oldDelegate) {
    return oldDelegate.fraction != fraction;
  }
}

class HideListened extends StatefulWidget {
  final bool? hideListened;
  const HideListened({this.hideListened, super.key});
  @override
  _HideListenedState createState() => _HideListenedState();
}

class _HideListenedState extends State<HideListened>
    with SingleTickerProviderStateMixin {
  double _fraction = 0.0;
  late Animation animation;
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    animation = Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        if (mounted) {
          setState(() {
            _fraction = animation.value;
          });
        }
      });
    if (widget.hideListened!) _controller.forward();
  }

  @override
  void didUpdateWidget(HideListened oldWidget) {
    if (oldWidget.hideListened != widget.hideListened) {
      if (widget.hideListened!) {
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
        backgroundColor: context.accentColor,
      ),
    );
  }
}

//Add new episode to palylist
class AddToPlaylistPainter extends CustomPainter {
  final Color color;
  final Color textColor;
  AddToPlaylistPainter(this.color, this.textColor);
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    var path = Path();
    path.moveTo(0, size.height / 5);
    path.lineTo(size.width * 4 / 7, size.height / 5);
    path.moveTo(0, size.height / 2);
    path.lineTo(size.width * 4 / 7, size.height / 2);
    path.moveTo(0, size.height * 4 / 5);
    path.lineTo(size.width * 3 / 7, size.height * 4 / 5);

    var textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: 'N',
        style: TextStyle(
          fontStyle: FontStyle.italic,
          color: textColor,
          fontSize: 10,
        ),
      ),
    )..layout();
    textPainter.paint(canvas, Offset(size.width * 4 / 7, size.height * 3 / 5));
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

/// Remove new flag icon.
class RemoveNewFlagPainter extends CustomPainter {
  final Color? color;
  final Color textColor;
  RemoveNewFlagPainter(this.color, this.textColor);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color!
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    var path = Path();

    path.moveTo(size.width * 3 / 5, size.height / 5);
    path.lineTo(size.width * 4 / 5, size.height * 2 / 5);
    path.lineTo(size.width * 2 / 5, size.height * 4 / 5);
    path.lineTo(size.width / 5, size.height * 3 / 5);
    path.lineTo(size.width * 3 / 5, size.height / 5);
    path.moveTo(size.width * 2 / 5, size.height * 2 / 5);
    path.lineTo(size.width * 3 / 5, size.height * 3 / 5);

    var textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: 'N',
        style: TextStyle(
          fontStyle: FontStyle.italic,
          color: textColor,
          fontSize: 10,
        ),
      ),
    )..layout();
    textPainter.paint(canvas, Offset(size.width * 4 / 7, size.height * 3 / 5));
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(RemoveNewFlagPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(RemoveNewFlagPainter oldDelegate) => false;
}

//Wave play indicator
class WavePainter extends CustomPainter {
  final double _fraction;
  late double _value;
  final Color _color;
  WavePainter(this._fraction, this._color);
  @override
  void paint(Canvas canvas, Size size) {
    if (_fraction < 0.5) {
      _value = _fraction;
    } else {
      _value = 1 - _fraction;
    }
    var path = Path();
    var paint = Paint()
      ..color = _color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    path.moveTo(0, size.height / 2);
    path.lineTo(0, size.height / 2 + size.height * _value * 0.2);
    path.moveTo(0, size.height / 2);
    path.lineTo(0, size.height / 2 - size.height * _value * 0.2);
    path.moveTo(size.width / 4, size.height / 2);
    path.lineTo(size.width / 4, size.height / 2 + size.height * _value * 0.8);
    path.moveTo(size.width / 4, size.height / 2);
    path.lineTo(size.width / 4, size.height / 2 - size.height * _value * 0.8);
    path.moveTo(size.width / 2, size.height / 2);
    path.lineTo(size.width / 2, size.height / 2 + size.height * _value * 0.5);
    path.moveTo(size.width / 2, size.height / 2);
    path.lineTo(size.width / 2, size.height / 2 - size.height * _value * 0.5);
    path.moveTo(size.width * 3 / 4, size.height / 2);
    path.lineTo(
      size.width * 3 / 4,
      size.height / 2 + size.height * _value * 0.6,
    );
    path.moveTo(size.width * 3 / 4, size.height / 2);
    path.lineTo(
      size.width * 3 / 4,
      size.height / 2 - size.height * _value * 0.6,
    );
    path.moveTo(size.width, size.height / 2);
    path.lineTo(size.width, size.height / 2 + size.height * _value * 0.2);
    path.moveTo(size.width, size.height / 2);
    path.lineTo(size.width, size.height / 2 - size.height * _value * 0.2);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return oldDelegate._fraction != _fraction;
  }
}

class WaveLoader extends StatefulWidget {
  final Color? color;
  final bool animate;
  const WaveLoader({this.color, this.animate = true, super.key});
  @override
  _WaveLoaderState createState() => _WaveLoaderState();
}

class _WaveLoaderState extends State<WaveLoader>
    with SingleTickerProviderStateMixin {
  double _fraction = 0.0;
  late Animation animation;
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
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
      painter: WavePainter(
        widget.animate ? _fraction : 1,
        widget.color ?? Colors.white,
      ),
    );
  }
}

//Love shape
class LovePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var path = Path();
    var paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    path.moveTo(size.width / 2, size.height / 6);
    path.quadraticBezierTo(size.width / 4, 0, size.width / 8, size.height / 6);
    path.quadraticBezierTo(
      0,
      size.height / 3,
      size.width / 8,
      size.height * 0.55,
    );
    path.quadraticBezierTo(
      size.width / 4,
      size.height * 0.8,
      size.width / 2,
      size.height,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.8,
      size.width * 7 / 8,
      size.height * 0.55,
    );
    path.quadraticBezierTo(
      size.width,
      size.height / 3,
      size.width * 7 / 8,
      size.height / 6,
    );
    path.quadraticBezierTo(
      size.width * 3 / 4,
      0,
      size.width / 2,
      size.height / 6,
    );

    canvas.drawPath(path, paint);
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
  late Paint _paint;
  final Color _maincolor;
  LinePainter(this._fraction, this._maincolor) {
    _paint = Paint()
      ..color = _maincolor
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
      Offset(0, size.height / 2.0),
      Offset(size.width * _fraction, size.height / 2.0),
      _paint,
    );
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) {
    return oldDelegate._fraction != _fraction;
  }
}

class LineLoader extends StatefulWidget {
  const LineLoader({super.key});

  @override
  _LineLoaderState createState() => _LineLoaderState();
}

class _LineLoaderState extends State<LineLoader>
    with SingleTickerProviderStateMixin {
  double _fraction = 0.0;
  late Animation animation;
  late AnimationController controller;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
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
    return CustomPaint(painter: LinePainter(_fraction, context.accentColor));
  }
}

class ImageRotate extends StatefulWidget {
  final EpisodeBrief? episodeItem;
  const ImageRotate({this.episodeItem, super.key});
  @override
  _ImageRotateState createState() => _ImageRotateState();
}

class _ImageRotateState extends State<ImageRotate>
    with SingleTickerProviderStateMixin {
  late Animation _animation;
  late AnimationController _controller;
  late double _value;

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
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircleAvatar(
            backgroundColor: widget.episodeItem!.backgroudColor(context),
            backgroundImage: widget.episodeItem!.avatarImage,
          ),
        ),
      ),
    );
  }
}

class LoveOpen extends StatefulWidget {
  const LoveOpen({super.key});

  @override
  _LoveOpenState createState() => _LoveOpenState();
}

class _LoveOpenState extends State<LoveOpen>
    with SingleTickerProviderStateMixin {
  late Animation _animationA;
  late AnimationController _controller;

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
      scale: _animationA as Animation<double>,
      alignment: Alignment.center,
      child: Transform.rotate(
        angle: angle,
        child: SizedBox(
          height: 5 * scale,
          width: 6 * scale,
          child: CustomPaint(painter: LovePainter()),
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
              _littleHeart(0.6, 3, -math.pi * 1.2),
            ],
          ),
        ],
      ),
    );
  }
}

//Heart rise
class HeartSet extends StatefulWidget {
  final double? height;
  final double? width;
  const HeartSet({super.key, this.height, this.width});

  @override
  _HeartSetState createState() => _HeartSetState();
}

class _HeartSetState extends State<HeartSet>
    with SingleTickerProviderStateMixin {
  late Animation _animation;
  late AnimationController _controller;
  late double _value;
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
      child: Icon(
        Icons.favorite,
        color: Colors.blue.withValues(alpha: 0.7),
        size: 20 * _value,
      ),
    );
  }
}

class HeartOpen extends StatefulWidget {
  final double? height;
  final double? width;
  const HeartOpen({super.key, this.height, this.width});

  @override
  _HeartOpenState createState() => _HeartOpenState();
}

class _HeartOpenState extends State<HeartOpen>
    with SingleTickerProviderStateMixin {
  late Animation _animation;
  late AnimationController _controller;
  late double _value;
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
      left: widget.width! * position,
      bottom: widget.height! * _value * scale,
      child: Icon(
        Icons.favorite,
        color: _value > 0.5
            ? Colors.red.withValues(alpha: 2 - _value * 2)
            : Colors.red,
        size: 20 * _value * scale,
      ),
    );
  }

  final List<double> _list = List<double>.generate(
    20,
    (index) => math.Random().nextDouble(),
  );
  final List<int> _index = List<int>.generate(19, (index) => index);
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          height: widget.height,
          width: widget.width,
          alignment: Alignment(0.5, 1 - _value),
          child: Icon(
            Icons.favorite,
            color: Colors.blue.withValues(alpha: 0.7),
            size: 20 * _value,
          ),
        ),
        ..._index.map<Widget>(_position),
      ],
    );
  }
}

/// Icon using a painter.
class IconPainter extends StatelessWidget {
  const IconPainter(
    this.painter, {
    this.height = 10,
    this.width = 30,
    super.key,
  });
  final double height;
  final double width;
  final CustomPainter painter;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: CustomPaint(painter: painter),
    );
  }
}

/// A dot just a dot.
class DotIndicator extends StatelessWidget {
  const DotIndicator({this.radius = 8, this.color, super.key})
    : assert(radius > 0);
  final Color? color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color ?? context.accentColor,
      ),
    );
  }
}

///Download button.
class DownloadPainter extends CustomPainter {
  double? fraction;
  Color? color;
  Color? progressColor;
  double progress;
  double pauseProgress;
  double stroke;
  DownloadPainter({
    this.fraction,
    this.color,
    this.progressColor,
    this.progress = 0,
    this.stroke = 2,
    this.pauseProgress = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color!
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    var circlePaint = Paint()
      ..color = color!.withAlpha(70)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    var progressPaint = Paint()
      ..color = progressColor!
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    var width = size.width;
    var height = size.height;
    var center = Offset(size.width / 2, size.height / 2);
    if (pauseProgress == 0 && progress < 1) {
      canvas.drawLine(
        Offset(width / 2, 4),
        Offset(width / 2, height * 4 / 5),
        paint,
      );
      canvas.drawLine(
        Offset(width / 4, height / 2),
        Offset(width / 2, height * 4 / 5),
        paint,
      );
      canvas.drawLine(
        Offset(width * 3 / 4, height / 2),
        Offset(width / 2, height * 4 / 5),
        paint,
      );
    }

    if (fraction == 0) {
      canvas.drawLine(
        Offset(width / 5, height),
        Offset(width * 4 / 5, height),
        paint,
      );
    } else if (progress < 1) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: width / 2),
        math.pi / 2,
        math.pi * fraction!,
        false,
        circlePaint,
      );
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: width / 2),
        math.pi / 2,
        -math.pi * fraction!,
        false,
        circlePaint,
      );
    }

    if (progress == 1) {
      canvas.drawLine(
        Offset(width / 5, height * 9 / 10),
        Offset(width * 4 / 5, height * 9 / 10),
        progressPaint,
      );
      canvas.drawLine(
        Offset(width / 5, height * 5 / 10),
        Offset(width * 2 / 5, height * 7 / 10),
        progressPaint,
      );
      canvas.drawLine(
        Offset(width * 4 / 5, height * 3 / 10),
        Offset(width * 2 / 5, height * 7 / 10),
        progressPaint,
      );
    }

    if (fraction == 1 && progress < 1) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: width / 2),
        -math.pi / 2,
        math.pi * 2 * progress,
        false,
        progressPaint,
      );
    }

    if (pauseProgress > 0) {
      canvas.drawLine(
        Offset(
          width / 5 + height * 3 * pauseProgress / 20,
          height / 2 - height * pauseProgress / 5,
        ),
        Offset(
          width / 2 - height * 3 * pauseProgress / 20,
          height * 4 / 5 - height * pauseProgress / 10,
        ),
        paint,
      );
      canvas.drawLine(
        Offset(
          width * 4 / 5 - height * 3 * pauseProgress / 20,
          height / 2 - height * pauseProgress / 5,
        ),
        Offset(
          width / 2 + height * 3 * pauseProgress / 20,
          height * 4 / 5 - height * pauseProgress / 10,
        ),
        paint,
      );
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
  const LayoutButton({this.layout, this.onPressed, super.key});
  final Layout? layout;
  final ValueChanged<Layout>? onPressed;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        if (layout == Layout.three) {
          onPressed!(Layout.one);
        } else if (layout == Layout.two) {
          onPressed!(Layout.three);
        } else {
          onPressed!(Layout.two);
        }
      },
      icon: layout == Layout.three
          ? SizedBox(
              height: 10,
              width: 30,
              child: CustomPaint(painter: LayoutPainter(0, context.textColor)),
            )
          : layout == Layout.two
          ? SizedBox(
              height: 10,
              width: 30,
              child: CustomPaint(painter: LayoutPainter(1, context.textColor)),
            )
          : SizedBox(
              height: 10,
              width: 30,
              child: CustomPaint(painter: LayoutPainter(4, context.textColor)),
            ),
    );
  }
}

/// Remove scroll view overlay effect.
class NoGrowBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class Meteor extends CustomPainter {
  late final Paint _paint;
  Meteor({double strokeWidth = 2.0}) {
    _paint = Paint()
      ..color = Colors.white
      ..strokeWidth = strokeWidth
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
  const MeteorLoader({super.key});

  @override
  _MeteorLoaderState createState() => _MeteorLoaderState();
}

class _MeteorLoaderState extends State<MeteorLoader>
    with SingleTickerProviderStateMixin {
  static const _tracks = <_MeteorTrack>[
    _MeteorTrack(0.04, 0.04, 0.28, 0.31, 0.00, 0.22, 0.70),
    _MeteorTrack(0.47, 0.02, 0.70, 0.30, 0.13, 0.19, 0.90),
    _MeteorTrack(0.72, 0.13, 0.94, 0.38, 0.27, 0.21, 0.65),
    _MeteorTrack(0.18, 0.30, 0.42, 0.60, 0.39, 0.20, 0.80),
    _MeteorTrack(0.56, 0.35, 0.80, 0.63, 0.52, 0.22, 0.72),
    _MeteorTrack(0.02, 0.54, 0.24, 0.80, 0.65, 0.19, 0.62),
    _MeteorTrack(0.67, 0.60, 0.91, 0.88, 0.77, 0.21, 0.85),
    _MeteorTrack(0.34, 0.66, 0.56, 0.92, 0.89, 0.18, 0.68),
  ];

  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 4200),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                return Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    for (final track in _tracks)
                      _buildMeteor(track, constraints.biggest),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildMeteor(_MeteorTrack track, Size area) {
    var phase = controller.value - track.delay;
    if (phase < 0) phase += 1;
    final progress = phase / track.duration;
    if (progress > 1) return const SizedBox.shrink();

    final visibility = math.sin(math.pi * progress);
    final left =
        (track.startX + (track.endX - track.startX) * progress) * area.width;
    final top =
        (track.startY + (track.endY - track.startY) * progress) * area.height;
    final height = 82.0 * track.scale;

    return Positioned(
      left: left,
      top: top,
      child: Opacity(
        opacity: visibility.clamp(0.0, 1.0),
        child: SizedBox(
          width: height * 0.48,
          height: height,
          child: CustomPaint(painter: Meteor(strokeWidth: 2.2 * track.scale)),
        ),
      ),
    );
  }
}

class _MeteorTrack {
  const _MeteorTrack(
    this.startX,
    this.startY,
    this.endX,
    this.endY,
    this.delay,
    this.duration,
    this.scale,
  );

  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final double delay;
  final double duration;
  final double scale;
}

/// Custom paint in player widget. Tab indicator.
class TabIndicator extends CustomPainter {
  double? fraction;
  double? indicatorSize;
  Color? color;
  Color? accentColor;
  int? index;
  TabIndicator({
    this.fraction,
    this.color,
    this.accentColor,
    this.indicatorSize,
    this.index,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color!
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    var accentPaint = Paint()
      ..color = accentColor!
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    var leftStartE = Offset(indicatorSize!, size.height);
    var rightStartE = Offset(size.width - indicatorSize!, size.height);
    var startPoint = Offset(size.width / 2, 0);
    var leftStart = startPoint + (leftStartE - startPoint) * fraction!;
    var rightStart = startPoint + (rightStartE - startPoint) * fraction!;
    var leftEnd =
        startPoint +
        Offset(-size.height, size.height) +
        Offset(-(size.width / 2 - size.height) * fraction!, 0);
    var rightEnd =
        startPoint +
        Offset(size.height, size.height) +
        Offset((size.width / 2 - size.height) * fraction!, 0);
    canvas.drawLine(
      leftStart,
      leftEnd,
      index == 0 || fraction == 0 ? accentPaint : paint,
    );
    canvas.drawLine(
      rightStart,
      rightEnd,
      index == 2 || fraction == 0 ? accentPaint : paint,
    );
    if (fraction == 1) {
      canvas.drawLine(
        Offset(size.width / 2 - indicatorSize! / 2, size.height),
        Offset(size.width / 2 + indicatorSize! / 2, size.height),
        index == 1 || fraction == 0 ? accentPaint : paint,
      );
    }
  }

  @override
  bool shouldRepaint(TabIndicator oldDelegate) {
    return oldDelegate.fraction != fraction || oldDelegate.index != index;
  }
}

/// Custom back button
class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key});
  @override
  Widget build(BuildContext context) {
    return IconButton(
      splashRadius: 20,
      icon: const BackButtonIcon(),
      tooltip: context.s.back,
      onPressed: () {
        Navigator.maybePop(context);
      },
    );
  }
}

// Episode tag widget.
Widget episodeTag(String text, Color? color) {
  if (text == '') {
    return Center();
  }
  return Container(
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(15.0),
    ),
    height: 25.0,
    margin: EdgeInsets.only(right: 10.0),
    padding: EdgeInsets.symmetric(horizontal: 8.0),
    alignment: Alignment.center,
    child: Text(text, style: TextStyle(fontSize: 14.0, color: Colors.black)),
  );
}

// Sleep time picker.
class SleepTimerPicker extends StatefulWidget {
  final ValueChanged<Duration>? onChange;
  const SleepTimerPicker({this.onChange, super.key});

  @override
  _SleepTimerPickerState createState() => _SleepTimerPickerState();
}

class _SleepTimerPickerState extends State<SleepTimerPicker> {
  final textStyle = TextStyle(fontSize: 60);
  late int hour;
  late int minute;
  @override
  void initState() {
    _initTimer();
    super.initState();
  }

  void _initTimer() {
    var h = DateTime.now().hour;
    var m = DateTime.now().minute;
    if (m > 50) {
      hour = (h + 1) % 24;
      minute = 0;
    } else {
      hour = h;
      minute = m ~/ 10 * 10 + 10;
    }
  }

  Duration _getDuration() {
    var h = DateTime.now().hour;
    var m = DateTime.now().minute;
    var d =
        Duration(hours: hour, minutes: minute) - Duration(hours: h, minutes: m);
    if (d >= Duration.zero) {
      return d;
    } else {
      return Duration(hours: 24) - d;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                if (hour >= 23) {
                  hour = 0;
                } else {
                  hour++;
                }
              });
              widget.onChange!(_getDuration());
            },
            onLongPress: () {
              setState(() {
                hour = DateTime.now().hour;
              });
              widget.onChange!(_getDuration());
            },
            child: Container(
              decoration: BoxDecoration(
                color: context.primaryColorDark,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(hour.toString().padLeft(2, '0'), style: textStyle),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(':', style: textStyle),
          ),
          GestureDetector(
            onTap: (() {
              setState(() {
                if (minute >= 55) {
                  minute = 0;
                } else {
                  minute += 5;
                }
              });
              widget.onChange!(_getDuration());
            }),
            onLongPress: () {
              setState(() {
                minute = 0;
              });
              widget.onChange!(_getDuration());
            },
            child: Container(
              decoration: BoxDecoration(
                color: context.primaryColorDark,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(minute.toString().padLeft(2, '0'), style: textStyle),
            ),
          ),
        ],
      ),
    );
  }
}

class UpDownIndicator extends StatefulWidget {
  final bool? status;
  final Color color;
  const UpDownIndicator({this.status, this.color = Colors.white, super.key});

  @override
  _UpDownIndicatorState createState() => _UpDownIndicatorState();
}

class _UpDownIndicatorState extends State<UpDownIndicator>
    with SingleTickerProviderStateMixin {
  late double _value;
  late AnimationController _controller;
  late Animation _animation;
  @override
  void initState() {
    super.initState();
    _value = 0;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {
          _value = _animation.value;
        });
      });
  }

  @override
  void didUpdateWidget(covariant UpDownIndicator oldWidget) {
    if (widget.status != oldWidget.status) {
      widget.status! ? _controller.forward() : _controller.reverse();
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
    return Transform.rotate(
      angle: widget.status! ? math.pi * _value : -math.pi * _value,
      child: Icon(Icons.keyboard_arrow_down, color: widget.color),
    );
  }
}

class CircleProgressIndicator extends CustomPainter {
  final int progress;
  late Paint _paint;
  CircleProgressIndicator(this.progress, {required Color color}) {
    _paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var center = Offset(size.width / 2, size.height / 2);
    canvas.drawArc(
      Rect.fromCenter(
        center: center,
        height: size.height * 2,
        width: size.width * 2,
      ),
      -math.pi / 2,
      math.pi * 2 * (progress / 100),
      true,
      _paint,
    );
  }

  @override
  bool shouldRepaint(CircleProgressIndicator oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
