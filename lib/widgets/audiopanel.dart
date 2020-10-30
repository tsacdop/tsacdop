import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../util/extension_helper.dart';

enum SlideDirection { up, down }

class AudioPanel extends StatefulWidget {
  final Widget miniPanel;
  final Widget expandedPanel;
  final Widget optionPanel;
  final double minHeight;
  final double maxHeight;

  AudioPanel(
      {@required this.miniPanel,
      @required this.expandedPanel,
      this.optionPanel,
      this.minHeight = 70,
      this.maxHeight = 300,
      Key key})
      : super(key: key);
  @override
  AudioPanelState createState() => AudioPanelState();
}

class AudioPanelState extends State<AudioPanel> with TickerProviderStateMixin {
  double initSize;
  double _startdy;
  double _move = 0;
  AnimationController _controller;
  AnimationController _slowController;
  Animation _animation;
  SlideDirection _slideDirection;
  double _expandHeight;

  @override
  void initState() {
    initSize = widget.minHeight;
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 50))
          ..addListener(() {
            if (mounted) setState(() {});
          });
    _slowController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200))
          ..addListener(() {
            if (mounted) setState(() {});
          });
    _animation =
        Tween<double>(begin: 0, end: initSize).animate(_slowController);
    _controller.forward();
    _slideDirection = SlideDirection.up;
    super.initState();
    _expandHeight = widget.maxHeight + 300;
  }

  @override
  void dispose() {
    _controller.dispose();
    _slowController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AudioPanel oldWidget) {
    if (oldWidget.maxHeight != widget.maxHeight) {
      setState(() {
        _expandHeight = widget.maxHeight + 300;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  double _getHeight() {
    if (_animation.value >= _expandHeight) {
      return _expandHeight;
    } else if (_animation.value <= widget.minHeight) {
      return widget.minHeight;
    } else {
      return _animation.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Container(
        child: (_animation.value > widget.minHeight + 30)
            ? Positioned.fill(
                child: GestureDetector(
                  onTap: backToMini,
                  child: Container(
                    color: Theme.of(context)
                        .scaffoldBackgroundColor
                        .withOpacity(0.9 *
                            math.min(_animation.value / widget.maxHeight, 1)),
                  ),
                ),
              )
            : Center(),
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
          onVerticalDragStart: _start,
          onVerticalDragUpdate: _update,
          onVerticalDragEnd: (event) => _end(),
          child: Container(
            height: _getHeight(),
            child: _animation.value < widget.minHeight + 30
                ? Container(
                    color: Theme.of(context).primaryColor,
                    child: Opacity(
                      opacity: _animation.value > widget.minHeight
                          ? (widget.minHeight + 30 - _animation.value) / 40
                          : 1,
                      child: widget.miniPanel,
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: context.primaryColor,
                      //  borderRadius: BorderRadius.only(
                      //      topLeft: Radius.circular(20.0),
                      //      topRight: Radius.circular(20.0)),

                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, -1),
                          blurRadius: 1,
                          color: context.brightness == Brightness.light
                              ? Colors.grey[400].withOpacity(0.5)
                              : Colors.grey[800],
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Opacity(
                        opacity: _animation.value < (widget.maxHeight - 50)
                            ? (_animation.value - widget.minHeight) /
                                (widget.maxHeight - widget.minHeight - 50)
                            : 1,
                        child: SizedBox(
                          height: math.max(widget.maxHeight,
                              math.min(_animation.value, _expandHeight)),
                          child: widget.expandedPanel,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    ]);
  }

  backToMini() {
    setState(() {
      _animation = Tween<double>(begin: initSize, end: widget.minHeight)
          .animate(_slowController);
      initSize = widget.minHeight;
    });
    _slowController.forward();
  }

  scrollToTop() {
    setState(() {
      _animation = Tween<double>(begin: initSize, end: _expandHeight)
          .animate(_slowController);
      initSize = _expandHeight;
    });
    _slowController.forward();
  }

  _start(DragStartDetails event) {
    setState(() {
      _startdy = event.localPosition.dy;
      _animation =
          Tween<double>(begin: initSize, end: initSize).animate(_controller);
    });
    _controller.forward();
  }

  _update(DragUpdateDetails event) {
    setState(() {
      _move = _startdy - event.localPosition.dy;
      _animation = Tween<double>(begin: initSize, end: initSize + _move)
          .animate(_controller);
      _slideDirection = _move > 0 ? SlideDirection.up : SlideDirection.down;
    });
    _controller.forward();
  }

  _end() async {
    if (_slideDirection == SlideDirection.up) {
      if (_move > 50) {
        if (_animation.value > widget.maxHeight + 20) {
          setState(() {
            _animation =
                Tween<double>(begin: _animation.value, end: _expandHeight)
                    .animate(_slowController);
            initSize = _expandHeight;
          });
          _slowController.forward();
        } else {
          setState(() {
            _animation =
                Tween<double>(begin: widget.maxHeight, end: widget.maxHeight)
                    .animate(_controller);
            initSize = widget.maxHeight;
          });
          _controller.forward();
        }
      } else {
        setState(() {
          _animation =
              Tween<double>(begin: _animation.value, end: widget.minHeight)
                  .animate(_controller);
          initSize = widget.minHeight;
        });
        _controller.forward();
      }
    } else if (_slideDirection == SlideDirection.down) {
      if (_move > -50) {
        if (_animation.value > widget.maxHeight) {
          setState(() {
            _animation =
                Tween<double>(begin: _animation.value, end: _expandHeight)
                    .animate(_slowController);
            initSize = _expandHeight;
          });
        } else {
          setState(() {
            _animation =
                Tween<double>(begin: _animation.value, end: widget.maxHeight)
                    .animate(_slowController);
            initSize = widget.maxHeight;
          });
        }
        _slowController.forward();
      } else {
        if (_animation.value > widget.maxHeight) {
          setState(() {
            _animation =
                Tween<double>(begin: _animation.value, end: widget.maxHeight)
                    .animate(_slowController);
            initSize = widget.maxHeight;
          });
        } else {
          setState(() {
            _animation =
                Tween<double>(begin: _animation.value, end: widget.minHeight)
                    .animate(_controller);
            initSize = widget.minHeight;
          });
        }
        _controller.forward();
      }
    }
    if (_animation.value >= _expandHeight) {
      setState(() {
        initSize = _expandHeight;
      });
    } else if (_animation.value < widget.minHeight) {
      setState(() {
        initSize = widget.minHeight;
      });
    }
  }
}

class _AudioPanelRoute extends StatefulWidget {
  _AudioPanelRoute({this.expandPanel, this.height, Key key}) : super(key: key);
  final Widget expandPanel;
  final double height;
  @override
  __AudioPanelRouteState createState() => __AudioPanelRouteState();
}

class __AudioPanelRouteState extends State<_AudioPanelRoute> {
  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Scaffold(
        body: Stack(children: <Widget>[
          Container(
            child: Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                // child:
                // Container(
                //   color: Theme.of(context)
                //       .scaffoldBackgroundColor
                //       .withOpacity(0.8),
                //
                //),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: widget.height,
              decoration: BoxDecoration(
                color: context.primaryColor,
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, -1),
                    blurRadius: 1,
                    color: context.brightness == Brightness.light
                        ? Colors.grey[400].withOpacity(0.5)
                        : Colors.grey[800],
                  ),
                ],
              ),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: SizedBox(
                  height: 300,
                  child: widget.expandPanel,
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
