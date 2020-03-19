//Fork from https://github.com/divyanshub024/day_night_switch

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const double _kTrackHeight = 80.0;
const double _kTrackWidth = 160.0;
const double _kTrackRadius = _kTrackHeight / 2.0;
const double _kThumbRadius = 36.0;
const double _kSwitchWidth =
    _kTrackWidth - 2 * _kTrackRadius + 2 * kRadialReactionRadius;
const double _kSwitchHeight = 2 * kRadialReactionRadius + 8.0;

class DayNightSwitch extends StatefulWidget {
  const DayNightSwitch({
    @required this.value,
    @required this.onChanged,
    @required this.onDrag,
    this.dragStartBehavior = DragStartBehavior.start,
    this.height,
    this.moonImage,
    this.sunImage,
    this.sunColor,
    this.moonColor,
    this.dayColor,
    this.nightColor,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final ValueChanged<double> onDrag;
  final DragStartBehavior dragStartBehavior;
  final double height;
  final ImageProvider sunImage;
  final ImageProvider moonImage;
  final Color sunColor;
  final Color moonColor;
  final Color dayColor;
  final Color nightColor;

  @override
  _DayNightSwitchState createState() => _DayNightSwitchState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty('value',
        value: value, ifTrue: 'on', ifFalse: 'off', showName: true));
    properties.add(ObjectFlagProperty<ValueChanged<bool>>(
      'onChanged',
      onChanged,
      ifNull: 'disabled',
    ));
  }
}

class _DayNightSwitchState extends State<DayNightSwitch>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final Color moonColor = widget.moonColor ?? const Color(0xFFf5f3ce);
    final Color nightColor = widget.nightColor ?? const Color(0xFF003366);

    Color sunColor = widget.sunColor ?? const Color(0xFFFDB813);
    Color dayColor = widget.dayColor ?? const Color(0xFF87CEEB);

    return _SwitchRenderObjectWidget(
      dragStartBehavior: widget.dragStartBehavior,
      value: widget.value,
      activeColor: moonColor,
      inactiveColor: sunColor,
      moonImage: widget.moonImage,
      sunImage: widget.sunImage,
      activeTrackColor: nightColor,
      inactiveTrackColor: dayColor,
      configuration: createLocalImageConfiguration(context),
      onChanged: widget.onChanged,
      onDrag: widget.onDrag,
      additionalConstraints:
          BoxConstraints.tight(Size(_kSwitchWidth, _kSwitchHeight)),
      vsync: this,
    );
  }
}

class _SwitchRenderObjectWidget extends LeafRenderObjectWidget {
  const _SwitchRenderObjectWidget({
    Key key,
    this.value,
    this.activeColor,
    this.inactiveColor,
    this.moonImage,
    this.sunImage,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.configuration,
    this.onChanged,
    this.onDrag,
    this.vsync,
    this.additionalConstraints,
    this.dragStartBehavior,
  }) : super(key: key);

  final bool value;
  final Color activeColor;
  final Color inactiveColor;
  final ImageProvider moonImage;
  final ImageProvider sunImage;
  final Color activeTrackColor;
  final Color inactiveTrackColor;
  final ImageConfiguration configuration;
  final ValueChanged<bool> onChanged;
  final ValueChanged<double> onDrag;
  final TickerProvider vsync;
  final BoxConstraints additionalConstraints;
  final DragStartBehavior dragStartBehavior;

  @override
  _RenderSwitch createRenderObject(BuildContext context) {
    return _RenderSwitch(
      dragStartBehavior: dragStartBehavior,
      value: value,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      moonImage: moonImage,
      sunImage: sunImage,
      activeTrackColor: activeTrackColor,
      inactiveTrackColor: inactiveTrackColor,
      configuration: configuration,
      onChanged: onChanged,
      onDrag: onDrag,
      textDirection: Directionality.of(context),
      additionalConstraints: additionalConstraints,
      vSync: vsync,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderSwitch renderObject) {
    renderObject
      ..value = value
      ..activeColor = activeColor
      ..inactiveColor = inactiveColor
      ..activeThumbImage = moonImage
      ..inactiveThumbImage = sunImage
      ..activeTrackColor = activeTrackColor
      ..inactiveTrackColor = inactiveTrackColor
      ..configuration = configuration
      ..onChanged = onChanged
      ..onDrag = onDrag
      ..textDirection = Directionality.of(context)
      ..additionalConstraints = additionalConstraints
      ..dragStartBehavior = dragStartBehavior
      ..vsync = vsync;
  }
}

class _RenderSwitch extends RenderToggleable {
  ValueChanged<double> onDrag;
  _RenderSwitch({
    bool value,
    Color activeColor,
    Color inactiveColor,
    ImageProvider moonImage,
    ImageProvider sunImage,
    Color activeTrackColor,
    Color inactiveTrackColor,
    ImageConfiguration configuration,
    BoxConstraints additionalConstraints,
    @required TextDirection textDirection,
    ValueChanged<bool> onChanged,
    this.onDrag,
    @required TickerProvider vSync,
    DragStartBehavior dragStartBehavior,
  })  : assert(textDirection != null),
        _activeThumbImage = moonImage,
        _inactiveThumbImage = sunImage,
        _activeTrackColor = activeTrackColor,
        _inactiveTrackColor = inactiveTrackColor,
        _configuration = configuration,
        _textDirection = textDirection,
        super(
          value: value,
          tristate: false,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
          onChanged: onChanged,
          additionalConstraints: additionalConstraints,
          vsync: vSync,
        ) {
    _drag = HorizontalDragGestureRecognizer()
      ..onStart = _handleDragStart
      ..onUpdate = _handleDragUpdate
      ..onEnd = _handleDragEnd
      ..dragStartBehavior = dragStartBehavior;
  }
  
  ImageProvider get activeThumbImage => _activeThumbImage;
  ImageProvider _activeThumbImage;
  set activeThumbImage(ImageProvider value) {
    if (value == _activeThumbImage) return;
    _activeThumbImage = value;
    markNeedsPaint();
  }

  ImageProvider get inactiveThumbImage => _inactiveThumbImage;
  ImageProvider _inactiveThumbImage;
  set inactiveThumbImage(ImageProvider value) {
    if (value == _inactiveThumbImage) return;
    _inactiveThumbImage = value;
    markNeedsPaint();
  }

  Color get activeTrackColor => _activeTrackColor;
  Color _activeTrackColor;
  set activeTrackColor(Color value) {
    assert(value != null);
    if (value == _activeTrackColor) return;
    _activeTrackColor = value;
    markNeedsPaint();
  }

  Color get inactiveTrackColor => _inactiveTrackColor;
  Color _inactiveTrackColor;
  set inactiveTrackColor(Color value) {
    assert(value != null);
    if (value == _inactiveTrackColor) return;
    _inactiveTrackColor = value;
    markNeedsPaint();
  }

  ImageConfiguration get configuration => _configuration;
  ImageConfiguration _configuration;
  set configuration(ImageConfiguration value) {
    assert(value != null);
    if (value == _configuration) return;
    _configuration = value;
    markNeedsPaint();
  }

  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    assert(value != null);
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsPaint();
  }

  DragStartBehavior get dragStartBehavior => _drag.dragStartBehavior;
  set dragStartBehavior(DragStartBehavior value) {
    assert(value != null);
    if (_drag.dragStartBehavior == value) return;
    _drag.dragStartBehavior = value;
  }

  @override
  void detach() {
    _cachedThumbPainter?.dispose();
    _cachedThumbPainter = null;
    super.detach();
  }

  double get _trackInnerLength => size.width - 2.0 * kRadialReactionRadius;

  HorizontalDragGestureRecognizer _drag;

  void _handleDragStart(DragStartDetails details) {
    if (isInteractive) reactionController.forward();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (isInteractive) {
      position
        ..curve = null
        ..reverseCurve = null;
      final double delta = details.primaryDelta / _trackInnerLength;
      switch (textDirection) {
        case TextDirection.rtl:
          positionController.value -= delta;
          break;
        case TextDirection.ltr:
          positionController.value += delta;
          break;
      }
      positionController.addListener(() {onDrag(positionController.value);});
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (position.value >= 0.5)
      positionController.forward();
    else
      positionController.reverse();
    reactionController.reverse();
  }



  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    if (event is PointerDownEvent && onChanged != null) _drag.addPointer(event);
    super.handleEvent(event, entry);
  }

  Color _cachedThumbColor;
  ImageProvider _cachedThumbImage;
  BoxPainter _cachedThumbPainter;

  BoxDecoration _createDefaultThumbDecoration(
      Color color, ImageProvider image) {
    return BoxDecoration(
      color: color,
      image: image == null ? null : DecorationImage(image: image),
      shape: BoxShape.circle,
      boxShadow: kElevationToShadow[1],
    );
  }

  bool _isPainting = false;

  void _handleDecorationChanged() {
    // If the image decoration is available synchronously, we'll get called here
    // during paint. There's no reason to mark ourselves as needing paint if we
    // are already in the middle of painting. (In fact, doing so would trigger
    // an assert).
    if (!_isPainting) markNeedsPaint();
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config.isToggled = value == true;
  }
  
  
    
  @override
  void paint(PaintingContext context, Offset offset) {
    final Canvas canvas = context.canvas;
    final bool isEnabled = onChanged != null;
    final double currentValue = position.value;

    double visualPosition;
    switch (textDirection) {
      case TextDirection.rtl:
        visualPosition = 1.0 - currentValue;
        break;
      case TextDirection.ltr:
        visualPosition = currentValue;
        break;
    }

    final Color trackColor = isEnabled
        ? Color.lerp(inactiveTrackColor, activeTrackColor, currentValue)
        : inactiveTrackColor;

    final Color thumbColor = isEnabled
        ? Color.lerp(inactiveColor, activeColor, currentValue)
        : inactiveColor;

    final ImageProvider thumbImage = isEnabled
        ? (currentValue < 0.5 ? inactiveThumbImage : activeThumbImage)
        : inactiveThumbImage;

    // Paint the track
    final Paint paint = Paint()..color = trackColor;
    const double trackHorizontalPadding = kRadialReactionRadius - _kTrackRadius;
    final Rect trackRect = Rect.fromLTWH(
      offset.dx + trackHorizontalPadding,
      offset.dy + (size.height - _kTrackHeight) / 2.0,
      size.width - 2.0 * trackHorizontalPadding,
      _kTrackHeight,
    );
    final RRect trackRRect = RRect.fromRectAndRadius(
        trackRect, const Radius.circular(_kTrackRadius));
    canvas.drawRRect(trackRRect, paint);

    final Offset thumbPosition = Offset(
      kRadialReactionRadius + visualPosition * _trackInnerLength,
      size.height / 2.0,
    );

    paintRadialReaction(canvas, offset, thumbPosition);

    var linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4 + (6 * (1 - currentValue))
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(offset.dx + _kSwitchWidth * 0.1, offset.dy),
      Offset(
          offset.dx +
              (_kSwitchWidth * 0.1) +
              (_kSwitchWidth / 2 * (1 - currentValue)),
          offset.dy),
      linePaint,
    );

    canvas.drawLine(
      Offset(offset.dx + _kSwitchWidth * 0.2, offset.dy + _kSwitchHeight),
      Offset(
          offset.dx +
              (_kSwitchWidth * 0.2) +
              (_kSwitchWidth / 2 * (1 - currentValue)),
          offset.dy + _kSwitchHeight),
      linePaint,
    );

    var starPaint = Paint()
      ..strokeWidth = 4 + (6 * (1 - currentValue))
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..color = Color.fromARGB((255 * currentValue).floor(), 255, 255, 255);

    canvas.drawLine(
      Offset(offset.dx, offset.dy + _kSwitchHeight * 0.7),
      Offset(offset.dx, offset.dy + _kSwitchHeight * 0.7),
      starPaint,
    );

    try {
      _isPainting = true;
      BoxPainter thumbPainter;
      if (_cachedThumbPainter == null ||
          thumbColor != _cachedThumbColor ||
          thumbImage != _cachedThumbImage) {
        _cachedThumbColor = thumbColor;
        _cachedThumbImage = thumbImage;
        _cachedThumbPainter =
            _createDefaultThumbDecoration(thumbColor, thumbImage)
                .createBoxPainter(_handleDecorationChanged);
      }
      thumbPainter = _cachedThumbPainter;

      // The thumb contracts slightly during the animation
      final double inset = 1.0 - (currentValue - 0.5).abs() * 2.0;
      final double radius = _kThumbRadius - inset;
      thumbPainter.paint(
        canvas,
        thumbPosition + offset - Offset(radius, radius),
        configuration.copyWith(size: Size.fromRadius(radius)),
      );
    } finally {
      _isPainting = false;
    }

    canvas.drawLine(
      Offset(offset.dx + _kSwitchWidth * 0.3, offset.dy + _kSwitchHeight * 0.5),
      Offset(
          offset.dx +
              (_kSwitchWidth * 0.3) +
              (_kSwitchWidth / 2 * (1 - currentValue)),
          offset.dy + _kSwitchHeight * 0.5),
      linePaint,
    );
  }
}