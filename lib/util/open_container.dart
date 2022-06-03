import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'extension_helper.dart';

typedef OpenContainerBuilder = Widget Function(
  BuildContext context,
  VoidCallback action,
  bool hide,
);

enum ContainerTransitionType {
  fade,
  fadeThrough,
}

class OpenContainer extends StatefulWidget {
  const OpenContainer({
    Key? key,
    this.closedColor = Colors.white,
    this.openColor = Colors.white,
    this.beginColor = Colors.white,
    this.endColor = Colors.white,
    this.closedElevation = 1.0,
    this.openElevation = 4.0,
    this.closedShape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(4.0)),
    ),
    this.openShape = const RoundedRectangleBorder(),
    required this.closedBuilder,
    required this.openBuilder,
    this.flightWidget,
    this.flightWidgetSize,
    this.playerRunning,
    this.playerHeight,
    this.tappable = true,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.transitionType = ContainerTransitionType.fade,
  }) : super(key: key);

  final Color beginColor;
  final Color endColor;
  final Color closedColor;
  final Widget? flightWidget;
  final double? flightWidgetSize;
  final bool? playerRunning;
  final double? playerHeight;

  final Color openColor;

  final double closedElevation;

  final double openElevation;

  final ShapeBorder closedShape;

  final ShapeBorder openShape;

  final OpenContainerBuilder closedBuilder;

  final OpenContainerBuilder openBuilder;

  final bool tappable;

  final Duration transitionDuration;

  final ContainerTransitionType transitionType;

  @override
  _OpenContainerState createState() => _OpenContainerState();
}

class _OpenContainerState extends State<OpenContainer> {
  final GlobalKey<_HideableState> _hideableKey = GlobalKey<_HideableState>();

  final GlobalKey _closedBuilderKey = GlobalKey();

  void openContainer() {
    Navigator.of(context).push(_OpenContainerRoute(
      beginColor: widget.beginColor,
      endColor: widget.endColor,
      closedColor: widget.closedColor,
      openColor: widget.openColor,
      closedElevation: widget.closedElevation,
      openElevation: widget.openElevation,
      closedShape: widget.closedShape,
      openShape: widget.openShape,
      closedBuilder: widget.closedBuilder,
      openBuilder: widget.openBuilder,
      hideableKey: _hideableKey,
      closedBuilderKey: _closedBuilderKey,
      transitionDuration: widget.transitionDuration,
      transitionType: widget.transitionType,
      flightWidget: widget.flightWidget,
      flightWidgetSize: widget.flightWidgetSize,
      playerRunning: widget.playerRunning,
      playerHeight: widget.playerHeight,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return _Hideable(
      key: _hideableKey,
      child: GestureDetector(
        onTap: widget.tappable ? openContainer : null,
        child: Material(
          color: Colors.transparent,
          // clipBehavior: Clip.antiAlias,
          // color: widget.closedColor,
          // elevation: widget.closedElevation,
          //  shape: widget.closedShape,
          child: Builder(
            key: _closedBuilderKey,
            builder: (context) {
              return widget.closedBuilder(context, openContainer, false);
            },
          ),
        ),
      ),
    );
  }
}

class _Hideable extends StatefulWidget {
  const _Hideable({
    Key? key,
    this.child,
  }) : super(key: key);

  final Widget? child;

  @override
  State<_Hideable> createState() => _HideableState();
}

class _HideableState extends State<_Hideable> {
  /// When non-null the child is replaced by a [SizedBox] of the set size.
  Size? get placeholderSize => _placeholderSize;
  Size? _placeholderSize;
  set placeholderSize(Size? value) {
    if (_placeholderSize == value) {
      return;
    }
    setState(() {
      _placeholderSize = value;
    });
  }

  /// When true the child is not visible, but will maintain its size.
  ///
  /// The value of this property is ignored when [placeholderSize] is non-null
  /// (i.e. [isInTree] returns false).
  bool get isVisible => _visible;
  bool _visible = true;
  set isVisible(bool value) {
    if (_visible == value) {
      return;
    }
    setState(() {
      _visible = value;
    });
  }

  /// Whether the child is currently included in the tree.
  ///
  /// When it is included, it may be visible or not according to [isVisible].
  bool get isInTree => _placeholderSize == null;

  @override
  Widget build(BuildContext context) {
    if (_placeholderSize != null) {
      return SizedBox.fromSize(size: _placeholderSize);
    }
    return Opacity(
      opacity: _visible ? 1.0 : 0.0,
      child: widget.child,
    );
  }
}

class _OpenContainerRoute extends ModalRoute<void> {
  _OpenContainerRoute({
    required this.closedColor,
    required this.openColor,
    required this.beginColor,
    required this.endColor,
    required double closedElevation,
    required this.openElevation,
    required ShapeBorder closedShape,
    required this.openShape,
    required this.closedBuilder,
    required this.openBuilder,
    required this.hideableKey,
    required this.closedBuilderKey,
    required this.transitionDuration,
    required this.transitionType,
    this.flightWidget,
    this.flightWidgetSize,
    this.playerRunning,
    this.playerHeight,
  })  : _elevationTween = Tween<double>(
          begin: closedElevation,
          end: openElevation,
        ),
        _shapeTween = ShapeBorderTween(
          begin: closedShape,
          end: openShape,
        ),
        _colorTween = _getColorTween(
            transitionType: transitionType,
            closedColor: closedColor,
            openColor: openColor,
            beginColor: beginColor,
            endColor: endColor),
        _closedOpacityTween = _getClosedOpacityTween(transitionType),
        _openOpacityTween = _getOpenOpacityTween(transitionType);

  final Widget? flightWidget;
  final double? flightWidgetSize;
  final bool? playerRunning;
  final double? playerHeight;
  static _FlippableTweenSequence<Color?>? _getColorTween({
    required ContainerTransitionType transitionType,
    required Color closedColor,
    required Color openColor,
    required Color beginColor,
    required Color endColor,
  }) {
    switch (transitionType) {
      case ContainerTransitionType.fade:
        return _FlippableTweenSequence<Color?>(
          <TweenSequenceItem<Color?>>[
            TweenSequenceItem<Color>(
              tween: ConstantTween<Color>(closedColor),
              weight: 1 / 5,
            ),
            TweenSequenceItem<Color?>(
              tween: ColorTween(begin: closedColor, end: openColor),
              weight: 1 / 5,
            ),
            TweenSequenceItem<Color>(
              tween: ConstantTween<Color>(openColor),
              weight: 3 / 5,
            ),
          ],
        );
      case ContainerTransitionType.fadeThrough:
        return _FlippableTweenSequence<Color?>(
          <TweenSequenceItem<Color?>>[
            TweenSequenceItem<Color?>(
              tween: ColorTween(begin: closedColor, end: endColor),
              weight: 1 / 5,
            ),
            TweenSequenceItem<Color?>(
              tween: ColorTween(begin: beginColor, end: openColor),
              weight: 4 / 5,
            ),
          ],
        );
    }
  }

  static _FlippableTweenSequence<double>? _getClosedOpacityTween(
      ContainerTransitionType transitionType) {
    switch (transitionType) {
      case ContainerTransitionType.fade:
        return _FlippableTweenSequence<double>(
          <TweenSequenceItem<double>>[
            TweenSequenceItem<double>(
              tween: ConstantTween<double>(1.0),
              weight: 1,
            ),
          ],
        );
      case ContainerTransitionType.fadeThrough:
        return _FlippableTweenSequence<double>(
          <TweenSequenceItem<double>>[
            TweenSequenceItem<double>(
              tween: Tween<double>(begin: 1.0, end: 0.0),
              weight: 1 / 5,
            ),
            TweenSequenceItem<double>(
              tween: ConstantTween<double>(0.0),
              weight: 4 / 5,
            ),
          ],
        );
    }
  }

  static _FlippableTweenSequence<double>? _getOpenOpacityTween(
      ContainerTransitionType transitionType) {
    switch (transitionType) {
      case ContainerTransitionType.fade:
        return _FlippableTweenSequence<double>(
          <TweenSequenceItem<double>>[
            TweenSequenceItem<double>(
              tween: ConstantTween<double>(0.0),
              weight: 1 / 5,
            ),
            TweenSequenceItem<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              weight: 1 / 5,
            ),
            TweenSequenceItem<double>(
              tween: ConstantTween<double>(1.0),
              weight: 3 / 5,
            ),
          ],
        );
      case ContainerTransitionType.fadeThrough:
        return _FlippableTweenSequence<double>(
          <TweenSequenceItem<double>>[
            TweenSequenceItem<double>(
              tween: ConstantTween<double>(0.0),
              weight: 1 / 5,
            ),
            TweenSequenceItem<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              weight: 4 / 5,
            ),
          ],
        );
    }
  }

  final Color closedColor;
  final Color openColor;
  final Color beginColor;
  final Color endColor;
  final double openElevation;
  final ShapeBorder openShape;
  final OpenContainerBuilder closedBuilder;
  final OpenContainerBuilder openBuilder;

  // See [_OpenContainerState._hideableKey].
  final GlobalKey<_HideableState> hideableKey;

  // See [_OpenContainerState._closedBuilderKey].
  final GlobalKey closedBuilderKey;

  @override
  final Duration transitionDuration;
  final ContainerTransitionType transitionType;

  final Tween<double> _elevationTween;
  final ShapeBorderTween _shapeTween;
  final _FlippableTweenSequence<double>? _closedOpacityTween;
  final _FlippableTweenSequence<double>? _openOpacityTween;
  final _FlippableTweenSequence<Color?>? _colorTween;

  // Key used for the widget returned by [OpenContainer.openBuilder] to keep
  // its state when the shape of the widget tree is changed at the end of the
  // animation to remove all the craft that was necessary to make the animation
  // work.
  final GlobalKey _openBuilderKey = GlobalKey();

  // Defines the position and the size of the (opening) [OpenContainer] within
  // the bounds of the enclosing [Navigator].
  final RectTween _rectTween = RectTween();
  final Tween<Offset> _positionTween = Tween<Offset>();
  final Tween<double> _avatarScaleTween = Tween<double>();
  AnimationStatus? _lastAnimationStatus;
  AnimationStatus? _currentAnimationStatus;

  @override
  TickerFuture didPush() {
    _takeMeasurements(navigatorContext: hideableKey.currentContext!);

    animation!.addStatusListener((status) {
      _lastAnimationStatus = _currentAnimationStatus;
      _currentAnimationStatus = status;
      switch (status) {
        case AnimationStatus.dismissed:
          hideableKey.currentState!
            ..placeholderSize = null
            ..isVisible = true;
          break;
        case AnimationStatus.completed:
          hideableKey.currentState!
            ..placeholderSize = null
            ..isVisible = false;
          break;
        case AnimationStatus.forward:
        case AnimationStatus.reverse:
          break;
      }
    });

    return super.didPush();
  }

  @override
  bool didPop(void result) {
    _takeMeasurements(
      navigatorContext: subtreeContext!,
      delayForSourceRoute: true,
    );
    return super.didPop(result);
  }

  void _takeMeasurements({
    required BuildContext navigatorContext,
    bool delayForSourceRoute = false,
  }) {
    final RenderBox navigator =
        Navigator.of(navigatorContext).context.findRenderObject() as RenderBox;
    final navSize = _getSize(navigator);
    _rectTween.end = Offset.zero & navSize;
    void takeMeasurementsInSourceRoute([Duration? _]) {
      if (!navigator.attached || hideableKey.currentContext == null) {
        return;
      }
      _rectTween.begin = _getRect(hideableKey, navigator);

      hideableKey.currentState!.placeholderSize = _rectTween.begin!.size;
    }

    if (delayForSourceRoute) {
      SchedulerBinding.instance
          .addPostFrameCallback(takeMeasurementsInSourceRoute);
    } else {
      takeMeasurementsInSourceRoute();
    }
  }

  Size _getSize(RenderBox render) {
    assert(render != null && render.hasSize);
    return render.size;
  }

  // Returns the bounds of the [RenderObject] identified by `key` in the
  // coordinate system of `ancestor`.
  Rect _getRect(GlobalKey key, RenderBox ancestor) {
    assert(key.currentContext != null);
    assert(ancestor != null && ancestor.hasSize);
    final RenderBox render =
        key.currentContext!.findRenderObject() as RenderBox;
    assert(render != null && render.hasSize);
    return MatrixUtils.transformRect(
      render.getTransformTo(ancestor),
      Offset.zero & render.size,
    );
  }

  bool get _transitionWasInterrupted {
    var wasInProgress = false;
    var isInProgress = false;

    switch (_currentAnimationStatus) {
      case AnimationStatus.completed:
      case AnimationStatus.dismissed:
        isInProgress = false;
        break;
      case AnimationStatus.forward:
      case AnimationStatus.reverse:
        isInProgress = true;
        break;
      default:
        break;
    }
    switch (_lastAnimationStatus) {
      case AnimationStatus.completed:
      case AnimationStatus.dismissed:
        wasInProgress = false;
        break;
      case AnimationStatus.forward:
      case AnimationStatus.reverse:
        wasInProgress = true;
        break;
      default:
        break;
    }
    return wasInProgress && isInProgress;
  }

  void closeContainer() {
    Navigator.of(subtreeContext!).pop();
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Align(
      alignment: Alignment.topLeft,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          if (animation.isCompleted) {
            return SizedBox.expand(
              child: Material(
                color: openColor,
                elevation: openElevation,
                shape: openShape,
                child: Builder(
                  key: _openBuilderKey,
                  builder: (context) {
                    return openBuilder(context, closeContainer, false);
                  },
                ),
              ),
            );
          }

          final Animation<double> curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.fastOutSlowIn,
            reverseCurve:
                _transitionWasInterrupted ? null : Curves.fastOutSlowIn.flipped,
          );
          final Animation<double> secondCurvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCirc,
            reverseCurve:
                _transitionWasInterrupted ? null : Curves.easeOutCirc.flipped,
          );
          TweenSequence<Color?>? colorTween;
          TweenSequence<double>? closedOpacityTween, openOpacityTween;
          switch (animation.status) {
            case AnimationStatus.dismissed:
            case AnimationStatus.forward:
              closedOpacityTween = _closedOpacityTween;
              openOpacityTween = _openOpacityTween;
              colorTween = _colorTween;
              break;
            case AnimationStatus.reverse:
              if (_transitionWasInterrupted) {
                closedOpacityTween = _closedOpacityTween;
                openOpacityTween = _openOpacityTween;
                colorTween = _colorTween;
                break;
              }
              closedOpacityTween = _closedOpacityTween!.flipped;
              openOpacityTween = _openOpacityTween!.flipped;
              colorTween = _colorTween!.flipped;
              break;
            case AnimationStatus.completed:
              assert(false); // Unreachable.
              break;
          }
          assert(colorTween != null);
          assert(closedOpacityTween != null);
          assert(openOpacityTween != null);

          final rect = _rectTween.evaluate(curvedAnimation)!;
          _positionTween.begin =
              Offset(_rectTween.begin!.left + 10, _rectTween.begin!.top + 10);
          _positionTween.end = Offset(
              10,
              playerRunning!
                  ? MediaQuery.of(context).size.height - 40 - playerHeight!
                  : MediaQuery.of(context).size.height - 40);

          _avatarScaleTween.begin = flightWidgetSize;
          _avatarScaleTween.end = 30;
          return SizedBox.expand(
            child: Stack(
              children: <Widget>[
                Container(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Transform.translate(
                      offset: Offset(rect.left, rect.top),
                      child: SizedBox(
                        width: rect.width,
                        height: rect.height *
                            (playerRunning!
                                ? (1 - playerHeight! / context.height)
                                : 1),
                        child: Material(
                          clipBehavior: Clip.antiAlias,
                          animationDuration: Duration.zero,
                          color: colorTween!.evaluate(animation),
                          shape: _shapeTween.evaluate(curvedAnimation),
                          elevation: _elevationTween.evaluate(curvedAnimation),
                          child: Stack(
                            fit: StackFit.passthrough,
                            children: <Widget>[
                              // Closed child fading out.
                              FittedBox(
                                fit: BoxFit.fitWidth,
                                alignment: Alignment.topLeft,
                                child: SizedBox(
                                  width: _rectTween.begin!.width,
                                  height: _rectTween.begin!.height,
                                  child: hideableKey.currentState!.isInTree
                                      ? null
                                      : Opacity(
                                          opacity: closedOpacityTween!
                                              .evaluate(animation),
                                          child: Builder(
                                            key: closedBuilderKey,
                                            builder: (context) {
                                              // Use dummy "open container" callback
                                              // since we are in the process of opening.
                                              return closedBuilder(
                                                  context, () {}, true);
                                            },
                                          ),
                                        ),
                                ),
                              ),

                              // Open child fading in.
                              FittedBox(
                                fit: BoxFit.fitWidth,
                                alignment: Alignment.topLeft,
                                child: SizedBox(
                                  width: _rectTween.end!.width,
                                  height: _rectTween.end!.height,
                                  child: Opacity(
                                    opacity:
                                        openOpacityTween!.evaluate(animation),
                                    child: Builder(
                                      key: _openBuilderKey,
                                      builder: (context) {
                                        return openBuilder(
                                            context, closeContainer, true);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: _positionTween.evaluate(secondCurvedAnimation).dy,
                  left: _positionTween.evaluate(secondCurvedAnimation).dx,
                  child: SizedBox(
                    height: _avatarScaleTween.evaluate(secondCurvedAnimation),
                    width: _avatarScaleTween.evaluate(secondCurvedAnimation),
                    child: flightWidget,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  bool get maintainState => true;

  @override
  Color? get barrierColor => null;

  @override
  bool get opaque => true;

  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => null;
}

class _FlippableTweenSequence<T> extends TweenSequence<T> {
  _FlippableTweenSequence(this._items) : super(_items);

  final List<TweenSequenceItem<T>> _items;
  _FlippableTweenSequence<T>? _flipped;

  _FlippableTweenSequence<T>? get flipped {
    if (_flipped == null) {
      final newItems = <TweenSequenceItem<T>>[];
      for (var i = 0; i < _items.length; i++) {
        newItems.add(TweenSequenceItem<T>(
          tween: _items[i].tween,
          weight: _items[_items.length - 1 - i].weight,
        ));
      }
      _flipped = _FlippableTweenSequence<T>(newItems);
    }
    return _flipped;
  }
}
