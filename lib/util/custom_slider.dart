import 'package:flutter/material.dart';

class MyRectangularTrackShape extends RectangularSliderTrackShape {
  Rect getPreferredRect({
    @required RenderBox parentBox,
    Offset offset = Offset.zero,
    @required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight;
    final trackLeft = offset.dx;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final trackWidth = parentBox.size.width;
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
    double textScaleFactor,
    Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final radiusTween = Tween<double>(
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
