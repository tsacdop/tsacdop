//Forked from https://github.com/cdharris/flutter_duration_picker
//Copyright https://github.com/cdharris
//License MIT https://github.com/cdharris/flutter_duration_picker/blob/master/LICENSE

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

const Duration _kDialAnimateDuration = Duration(milliseconds: 200);

const double _kDurationPickerWidthPortrait = 328.0;
const double _kDurationPickerWidthLandscape = 512.0;

const double _kDurationPickerHeightPortrait = 380.0;
const double _kDurationPickerHeightLandscape = 304.0;

const double _kTwoPi = 2 * math.pi;
const double _kPiByTwo = math.pi / 2;

const double _kCircleTop = _kPiByTwo;

class _DialPainter extends CustomPainter {
  const _DialPainter({
    required this.context,
    required this.labels,
    required this.backgroundColor,
    required this.accentColor,
    required this.theta,
    required this.textDirection,
    required this.selectedValue,
    required this.pct,
    required this.multiplier,
    required this.secondHand,
  });

  final List<TextPainter> labels;
  final Color? backgroundColor;
  final Color accentColor;
  final double theta;
  final TextDirection textDirection;
  final int? selectedValue;
  final BuildContext context;

  final double pct;
  final int multiplier;
  final int secondHand;

  @override
  void paint(Canvas canvas, Size size) {
    const _epsilon = .001;
    const _sweep = _kTwoPi - _epsilon;
    const _startAngle = -math.pi / 2.0;

    final radius = size.shortestSide / 2.0;
    final center = Offset(size.width / 2.0, size.height / 2.0);
    final centerPoint = center;

    var pctTheta = (0.25 - (theta % _kTwoPi) / _kTwoPi) % 1.0;

    // Draw the background outer ring
    canvas.drawCircle(centerPoint, radius, Paint()..color = backgroundColor!);

    // Draw a translucent circle for every hour
    for (var i = 0; i < multiplier; i = i + 1) {
      canvas.drawCircle(centerPoint, radius,
          Paint()..color = accentColor.withOpacity((i == 0) ? 0.3 : 0.1));
    }

    // Draw the inner background circle
    canvas.drawCircle(centerPoint, radius * 0.88,
        Paint()..color = Theme.of(context).canvasColor);

    // Get the offset point for an angle value of theta, and a distance of _radius
    Offset getOffsetForTheta(double theta, double _radius) {
      return center +
          Offset(_radius * math.cos(theta), -_radius * math.sin(theta));
    }

    // Draw the handle that is used to drag and to indicate the position around the circle
    final handlePaint = Paint()..color = accentColor;
    final handlePoint = getOffsetForTheta(theta, radius - 10.0);
    canvas.drawCircle(handlePoint, 20.0, handlePaint);

    // Draw the Text in the center of the circle which displays hours and mins
    var minutes = (multiplier == 0) ? '' : "${multiplier}min ";
//    int minutes = (pctTheta * 60).round();
//    minutes = minutes == 60 ? 0 : minutes;
    var seconds = "$secondHand";

    var textDurationValuePainter = TextPainter(
        textAlign: TextAlign.center,
        text: TextSpan(
            text: '$minutes$seconds',
            style: Theme.of(context)
                .textTheme
                .headline4!
                .copyWith(fontSize: size.shortestSide * 0.15)),
        textDirection: TextDirection.ltr)
      ..layout();
    var middleForValueText = Offset(
        centerPoint.dx - (textDurationValuePainter.width / 2),
        centerPoint.dy - textDurationValuePainter.height / 2);
    textDurationValuePainter.paint(canvas, middleForValueText);

    var textMinPainter = TextPainter(
        textAlign: TextAlign.center,
        text: TextSpan(
            text: 'sec', //th: ${theta}',
            style: Theme.of(context).textTheme.bodyText1),
        textDirection: TextDirection.ltr)
      ..layout();
    textMinPainter.paint(
        canvas,
        Offset(
            centerPoint.dx - (textMinPainter.width / 2),
            centerPoint.dy +
                (textDurationValuePainter.height / 2) -
                textMinPainter.height / 2));

    // Draw an arc around the circle for the amount of the circle that has elapsed.
    var elapsedPainter = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = accentColor.withOpacity(0.3)
      ..isAntiAlias = true
      ..strokeWidth = radius * 0.12;

    canvas.drawArc(
      Rect.fromCircle(
        center: centerPoint,
        radius: radius - radius * 0.12 / 2,
      ),
      _startAngle,
      _sweep * pctTheta,
      false,
      elapsedPainter,
    );

    // Paint the labels (the minute strings)
    void paintLabels(List<TextPainter> labels) {
      if (labels == null) return;
      final labelThetaIncrement = -_kTwoPi / labels.length;
      var labelTheta = _kPiByTwo;

      for (var label in labels) {
        final labelOffset = Offset(-label.width / 2.0, -label.height / 2.0);

        label.paint(
            canvas, getOffsetForTheta(labelTheta, radius - 40.0) + labelOffset);

        labelTheta += labelThetaIncrement;
      }
    }

    paintLabels(labels);
  }

  @override
  bool shouldRepaint(_DialPainter oldPainter) {
    return oldPainter.labels != labels ||
        oldPainter.backgroundColor != backgroundColor ||
        oldPainter.accentColor != accentColor ||
        oldPainter.theta != theta;
  }
}

class _Dial extends StatefulWidget {
  const _Dial(
      {required this.duration, required this.onChanged, this.snapToMins = 1.0})
      : assert(duration != null);

  final Duration duration;
  final ValueChanged<Duration>? onChanged;

  /// The resolution of mins of the dial, i.e. if snapToMins = 5.0, only durations of 5min intervals will be selectable.
  final double? snapToMins;
  @override
  _DialState createState() => _DialState();
}

class _DialState extends State<_Dial> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _thetaController = AnimationController(
      vsync: this,
      duration: _kDialAnimateDuration,
    );
    _thetaTween = Tween<double>(begin: _getThetaForDuration(widget.duration));
    _theta = _thetaTween!.animate(
        CurvedAnimation(parent: _thetaController!, curve: Curves.fastOutSlowIn))
      ..addListener(() => setState(() {}));
    _thetaController!.addStatusListener((status) {
//      if (status == AnimationStatus.completed && _hours != _snappedHours) {
//        _hours = _snappedHours;
      if (status == AnimationStatus.completed) {
        _minutes = _minuteHand(_turningAngle);
        _seconds = _secondHand(_turningAngle);
        setState(() {});
      }
    });
//    _hours = widget.duration.inHours;

    _turningAngle = _kPiByTwo - widget.duration.inSeconds / 60.0 * _kTwoPi;
    _minutes = _minuteHand(_turningAngle);
    _seconds = _secondHand(_turningAngle);
  }

  late ThemeData themeData;
  MaterialLocalizations? localizations;
  MediaQueryData? media;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    assert(debugCheckHasMediaQuery(context));
    themeData = Theme.of(context);
    localizations = MaterialLocalizations.of(context);
    media = MediaQuery.of(context);
  }

  @override
  void dispose() {
    _thetaController!.dispose();
    super.dispose();
  }

  Tween<double>? _thetaTween;
  late Animation<double> _theta;
  AnimationController? _thetaController;

  final double _pct = 0.0;
  int _seconds = 0;
  bool _dragging = false;
  int _minutes = 0;
  double _turningAngle = 0.0;

  static double _nearest(double target, double a, double b) {
    return ((target - a).abs() < (target - b).abs()) ? a : b;
  }

  void _animateTo(double targetTheta) {
    final currentTheta = _theta.value;
    var beginTheta =
        _nearest(targetTheta, currentTheta, currentTheta + _kTwoPi);
    beginTheta = _nearest(targetTheta, beginTheta, currentTheta - _kTwoPi);
    _thetaTween!
      ..begin = beginTheta
      ..end = targetTheta;
    _thetaController!
      ..value = 0.0
      ..forward();
  }

  double _getThetaForDuration(Duration duration) {
    return (_kPiByTwo - (duration.inSeconds % 60) / 60.0 * _kTwoPi) % _kTwoPi;
  }

  Duration _getTimeForTheta(double theta) {
    return _angleToDuration(_turningAngle);
  }

  Duration _notifyOnChangedIfNeeded() {
//    final Duration current = _getTimeForTheta(_theta.value);
//    var d = Duration(hours: _hours, minutes: current.inMinutes % 60);
    _minutes = _minuteHand(_turningAngle);
    _seconds = _secondHand(_turningAngle);

    var d = _angleToDuration(_turningAngle);

    widget.onChanged!(d);

    return d;
  }

  void _updateThetaForPan() {
    setState(() {
      final offset = _position! - _center!;
      final angle = (math.atan2(offset.dx, offset.dy) - _kPiByTwo) % _kTwoPi;

      // Stop accidental abrupt pans from making the dial seem like it starts from 1h.
      // (happens when wanting to pan from 0 clockwise, but when doing so quickly, one actually pans from before 0 (e.g. setting the duration to 59mins, and then crossing 0, which would then mean 1h 1min).
      if (angle >= _kCircleTop &&
          _theta.value <= _kCircleTop &&
          _theta.value >= 0.1 && // to allow the radians sign change at 15mins.
          _minutes == 0) return;

      _thetaTween!
        ..begin = angle
        ..end = angle;
    });
  }

  Offset? _position;
  Offset? _center;

  void _handlePanStart(DragStartDetails details) {
    assert(!_dragging);
    _dragging = true;
    final RenderBox box = context.findRenderObject() as RenderBox;
    _position = box.globalToLocal(details.globalPosition);
    _center = box.size.center(Offset.zero);
    //_updateThetaForPan();
    _notifyOnChangedIfNeeded();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    var oldTheta = _theta.value;
    _position = _position! + details.delta;
    _updateThetaForPan();
    var newTheta = _theta.value;
//    _updateRotations(oldTheta, newTheta);
    _updateTurningAngle(oldTheta, newTheta);
    _notifyOnChangedIfNeeded();
  }

  int _minuteHand(double angle) {
    return _angleToDuration(angle).inMinutes.toInt();
  }

  int _secondHand(double angle) {
    // Result is in [0; 59], even if overall time is >= 1 hour
    return (_angleToSeconds(angle) % 60.0).toInt();
  }

  Duration _angleToDuration(double angle) {
    return _secondToDuration(_angleToSeconds(angle));
  }

  Duration _secondToDuration(seconds) {
    return Duration(
        minutes: (seconds ~/ 60).toInt(), seconds: (seconds % 60.0).toInt());
  }

  double _angleToSeconds(double angle) {
    // Coordinate transformation from mathematical COS to dial COS
    var dialAngle = _kPiByTwo - angle;

    // Turn dial angle into minutes, may go beyond 60 minutes (multiple turns)
    return dialAngle / _kTwoPi * 60.0;
  }

  void _updateTurningAngle(double oldTheta, double newTheta) {
    // Register any angle by which the user has turned the dial.
    //
    // The resulting turning angle fully captures the state of the dial,
    // including multiple turns (= full hours). The [_turningAngle] is in
    // mathematical coordinate system, i.e. 3-o-clock position being zero, and
    // increasing counter clock wise.

    // From positive to negative (in mathematical COS)
    if (newTheta > 1.5 * math.pi && oldTheta < 0.5 * math.pi) {
      _turningAngle = _turningAngle - ((_kTwoPi - newTheta) + oldTheta);
    }
    // From negative to positive (in mathematical COS)
    else if (newTheta < 0.5 * math.pi && oldTheta > 1.5 * math.pi) {
      _turningAngle = _turningAngle + ((_kTwoPi - oldTheta) + newTheta);
    } else {
      _turningAngle = _turningAngle + (newTheta - oldTheta);
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    assert(_dragging);
    _dragging = false;
    _position = null;
    _center = null;
    //_notifyOnChangedIfNeeded();
    //_animateTo(_getThetaForDuration(widget.duration));
  }

  void _handleTapUp(TapUpDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    _position = box.globalToLocal(details.globalPosition);
    _center = box.size.center(Offset.zero);
    _updateThetaForPan();
    _notifyOnChangedIfNeeded();

    _animateTo(_getThetaForDuration(_getTimeForTheta(_theta.value)));
    _dragging = false;
    _position = null;
    _center = null;
  }

  List<TextPainter> _buildSeconds(TextTheme textTheme) {
    final style = textTheme.subtitle1;

    const _secondsMarkerValues = <Duration>[
      Duration(seconds: 0),
      Duration(seconds: 5),
      Duration(seconds: 10),
      Duration(seconds: 15),
      Duration(seconds: 20),
      Duration(seconds: 25),
      Duration(seconds: 30),
      Duration(seconds: 35),
      Duration(seconds: 40),
      Duration(seconds: 45),
      Duration(seconds: 50),
      Duration(seconds: 55),
    ];

    final labels = <TextPainter>[];
    for (var duration in _secondsMarkerValues) {
      var painter = TextPainter(
        text: TextSpan(style: style, text: duration.inSeconds.toString()),
        textDirection: TextDirection.ltr,
      )..layout();
      labels.add(painter);
    }
    return labels;
  }

  @override
  Widget build(BuildContext context) {
    Color? backgroundColor;
    switch (themeData.brightness) {
      case Brightness.light:
        backgroundColor = Colors.grey[200];
        break;
      case Brightness.dark:
        backgroundColor = themeData.backgroundColor;
        break;
    }

    final theme = Theme.of(context);

    int? selectedDialValue;
    _minutes = _minuteHand(_turningAngle);
    _seconds = _secondHand(_turningAngle);

    return GestureDetector(
        excludeFromSemantics: true,
        onPanStart: _handlePanStart,
        onPanUpdate: _handlePanUpdate,
        onPanEnd: _handlePanEnd,
        onTapUp: _handleTapUp,
        child: CustomPaint(
          painter: _DialPainter(
            pct: _pct,
            multiplier: _minutes,
            secondHand: _seconds,
            context: context,
            selectedValue: selectedDialValue,
            labels: _buildSeconds(theme.textTheme),
            backgroundColor: backgroundColor,
            accentColor: themeData.accentColor,
            theta: _theta.value,
            textDirection: Directionality.of(context),
          ),
        ));
  }
}

/// A duration picker designed to appear inside a popup dialog.
///
/// Pass this widget to [showDialog]. The value returned by [showDialog] is the
/// selected [Duration] if the user taps the "OK" button, or null if the user
/// taps the "CANCEL" button. The selected time is reported by calling
/// [Navigator.pop].
class _DurationPickerDialog extends StatefulWidget {
  /// Creates a duration picker.
  ///
  /// [initialTime] must not be null.
  const _DurationPickerDialog(
      {Key? key, required this.initialTime, this.snapToMins})
      : assert(initialTime != null),
        super(key: key);

  /// The duration initially selected when the dialog is shown.
  final Duration initialTime;
  final double? snapToMins;

  @override
  _DurationPickerDialogState createState() => _DurationPickerDialogState();
}

class _DurationPickerDialogState extends State<_DurationPickerDialog> {
  @override
  void initState() {
    super.initState();
    _selectedDuration = widget.initialTime;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations = MaterialLocalizations.of(context);
  }

  Duration? get selectedDuration => _selectedDuration;
  Duration? _selectedDuration;

  late MaterialLocalizations localizations;

  void _handleTimeChanged(Duration value) {
    setState(() {
      _selectedDuration = value;
    });
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  void _handleOk() {
    Navigator.pop(context, _selectedDuration);
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final theme = Theme.of(context);

    final Widget picker = Padding(
        padding: const EdgeInsets.all(16.0),
        child: AspectRatio(
            aspectRatio: 1.0,
            child: _Dial(
              duration: _selectedDuration!,
              onChanged: _handleTimeChanged,
              snapToMins: widget.snapToMins,
            )));

    final Widget actions = ButtonBar(children: <Widget>[
      FlatButton(
          child: Text(localizations.cancelButtonLabel),
          onPressed: _handleCancel),
      FlatButton(
          child: Text(localizations.okButtonLabel), onPressed: _handleOk),
    ]);

    final dialog =
        Dialog(child: OrientationBuilder(builder: (context, orientation) {
      final Widget pickerAndActions = Container(
        color: theme.dialogBackgroundColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
                child:
                    picker), // picker grows and shrinks with the available space
            actions,
          ],
        ),
      );

      assert(orientation != null);
      switch (orientation) {
        case Orientation.portrait:
          return SizedBox(
              width: _kDurationPickerWidthPortrait,
              height: _kDurationPickerHeightPortrait,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      child: pickerAndActions,
                    ),
                  ]));
        case Orientation.landscape:
          return SizedBox(
              width: _kDurationPickerWidthLandscape,
              height: _kDurationPickerHeightLandscape,
              child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Flexible(
                      child: pickerAndActions,
                    ),
                  ]));
      }
    }));

    return Theme(
      data: theme.copyWith(
        dialogBackgroundColor: Colors.transparent,
      ),
      child: dialog,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

/// Shows a dialog containing the duration picker.
///
/// The returned Future resolves to the duration selected by the user when the user
/// closes the dialog. If the user cancels the dialog, null is returned.
///
/// To show a dialog with [initialTime] equal to the current time:
///
/// ```dart
/// showDurationPicker(
///   initialTime: new Duration.now(),
///   context: context,
/// );
/// ```
Future<Duration?> showDurationPicker(
    {required BuildContext context,
    required Duration initialTime,
    double? snapToMins}) async {
  assert(context != null);
  assert(initialTime != null);

  return await showDialog<Duration>(
    context: context,
    builder: (context) =>
        _DurationPickerDialog(initialTime: initialTime, snapToMins: snapToMins),
  );
}

class DurationPicker extends StatelessWidget {
  final Duration duration;
  final ValueChanged<Duration>? onChange;
  final double? snapToMins;

  final double? width;
  final double? height;

  DurationPicker(
      {this.duration = const Duration(minutes: 0),
      required this.onChange,
      this.snapToMins,
      this.width,
      this.height,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? _kDurationPickerWidthPortrait / 1.5,
      height: height ?? _kDurationPickerHeightPortrait / 1.5,
      child: _Dial(
        duration: duration,
        onChanged: onChange,
        snapToMins: snapToMins,
      ),
    );
  }
}
