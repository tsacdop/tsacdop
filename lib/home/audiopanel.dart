import 'package:flutter/material.dart';

class AudioPanel extends StatefulWidget {
  final Widget miniPanel;
  final Widget expandedPanel;
  AudioPanel({this.miniPanel, this.expandedPanel, Key key}) : super(key: key);
  @override
  _AudioPanelState createState() => _AudioPanelState();
}

class _AudioPanelState extends State<AudioPanel>
    with SingleTickerProviderStateMixin {
  double initSize;
  double minSize = 60;
  double maxSize = 300;
  double _startdy;
  double _move = 0;
  AnimationController _controller;
  var _animation;

  @override
  void initState() {
    super.initState();
    initSize = minSize;
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 100))
          ..addListener(() {
            setState(() {});
          });
    _animation =
        Tween<double>(begin: initSize, end: initSize).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragStart: (event) => _start(event),
      onVerticalDragUpdate: (event) => _update(event),
      onVerticalDragEnd: (event) => _end(),
      child: Container(
        height: (_animation.value >= maxSize)
            ? maxSize
            : (_animation.value <= minSize) ? minSize : _animation.value,
        child: _animation.value < minSize + 30
            ? Opacity(
                opacity: _animation.value > minSize
                    ? (minSize + 30 - _animation.value) / 40
                    : 1,
                child: Container(
                  child: widget.miniPanel,
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  boxShadow: [
                    
                    BoxShadow(
                      color: Colors.grey[400].withOpacity(0.8),
                      spreadRadius: 3,
                      blurRadius: 6,
                      offset: Offset(0, -1),
                    )
                  ],
                ),
                child: SingleChildScrollView(
                  child: Opacity(
                    opacity: _animation.value < (maxSize - 50)
                        ? (_animation.value - minSize) /
                            (maxSize - minSize - 50)
                        : 1,
                    child: Container(
                      height: maxSize,
                      child: widget.expandedPanel,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  _start(DragStartDetails event) {
    print(event.localPosition.dy);
    setState(() {
      _startdy = event.localPosition.dy;
    });
    _controller.forward();
  }

  _update(DragUpdateDetails event) {
    print(event.localPosition.dy);
    setState(() {
      _move = _startdy - event.localPosition.dy;
      _animation = Tween<double>(begin: initSize, end: initSize + _move)
          .animate(_controller);
    });
    _controller.forward();
  }

  _end() {
    print(_animation.value);
    if (_animation.value >= (maxSize + minSize) / 2.2 &&
        _animation.value < maxSize) {
      setState(() {
        _animation = Tween<double>(begin: _animation.value, end: maxSize)
            .animate(_controller);
        initSize = maxSize;
      });
      _controller.forward();
    } else if (_animation.value < (maxSize + minSize) / 2.2 &&
        _animation.value > minSize) {
      setState(() {
        _animation = Tween<double>(begin: _animation.value, end: minSize)
            .animate(_controller);
        initSize = minSize;
      });
      _controller.forward();
    } else if (_animation.value >= maxSize) {
      setState(() {
        initSize = maxSize;
      });
    } else if (_animation.value <= minSize) {
      setState(() {
        initSize = minSize;
      });
    }
  }
}
