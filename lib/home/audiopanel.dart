import 'package:flutter/material.dart';

enum SlideDirection { up, down }

class AudioPanel extends StatefulWidget {
  final Widget miniPanel;
  final Widget expandedPanel;
  final double minHeight;
  final double maxHeight;
  AudioPanel(
      {@required this.miniPanel,
      @required this.expandedPanel,
      this.minHeight = 60,
      this.maxHeight = 300,
      Key key})
      : super(key: key);
  @override
  _AudioPanelState createState() => _AudioPanelState();
}

class _AudioPanelState extends State<AudioPanel> with TickerProviderStateMixin {
  double initSize;
  double _startdy;
  double _move = 0;
  AnimationController _controller;
  AnimationController _slowController;
  Animation _animation;
  SlideDirection _slideDirection;

  @override
  void initState() {
    initSize = widget.minHeight;
    _slideDirection = SlideDirection.up;
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 50))
          ..addListener(() {
            setState(() {});
          });
    _slowController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200))
          ..addListener(() {
            setState(() {});
          });
    _animation =
        Tween<double>(begin: initSize, end: initSize).animate(_controller);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _slowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Container(
        child: (_animation.value > widget.minHeight + 30)
            ? Positioned.fill(
                child: GestureDetector(
                  onTap: () => _backToMini(),
                  child: Container(
                    color: Theme.of(context)
                        .scaffoldBackgroundColor
                        .withOpacity(0.5),
                  ),
                ),
              )
            : Center(),
      ),
      Container(
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
          onVerticalDragStart: (event) => _start(event),
          onVerticalDragUpdate: (event) => _update(event),
          onVerticalDragEnd: (event) => _end(),
          child: Container(
            height: (_animation.value >= widget.maxHeight)
                ? widget.maxHeight
                : (_animation.value <= widget.minHeight)
                    ? widget.minHeight
                    : _animation.value,
            child: _animation.value < widget.minHeight + 30
                ? Container(
                    color: Theme.of(context).primaryColor,
                    child: Opacity(
                      opacity: _animation.value > widget.minHeight
                          ? (widget.minHeight + 30 - _animation.value) / 40
                          : 1,
                      child: Container(
                        child: widget.miniPanel,
                      ),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, -0.5),
                          blurRadius: 1,
                          color:
                              Theme.of(context).brightness == Brightness.light
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
                        child: Container(
                          height: widget.maxHeight,
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

  _backToMini() {
    setState(() {
      _animation = Tween<double>(begin: initSize, end: widget.minHeight)
          .animate(_slowController);
      initSize = widget.minHeight;
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

  _end() {
    if (_slideDirection == SlideDirection.up) {
      if (_move > 20) {
        setState(() {
          _animation =
              Tween<double>(begin: _animation.value, end: widget.maxHeight)
                  .animate(_slowController);
          initSize = widget.maxHeight;
        });
        _slowController.forward();
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
        setState(() {
          _animation =
              Tween<double>(begin: _animation.value, end: widget.maxHeight)
                  .animate(_slowController);
          initSize = widget.maxHeight;
        });
        _slowController.forward();
      } else {
        setState(() {
          _animation =
              Tween<double>(begin: _animation.value, end: widget.minHeight)
                  .animate(_controller);
          initSize = widget.minHeight;
        });
        _controller.forward();
      }
    }
    if (_animation.value >= widget.maxHeight) {
      setState(() {
        initSize = widget.maxHeight;
      });
    } else if (_animation.value < widget.minHeight) {
      setState(() {
        initSize = widget.minHeight;
      });
    }
  }
}
