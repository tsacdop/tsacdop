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
  final double minSize = 60;
  final double maxSize = 300;
  double _startdy;
  double _move = 0;
  AnimationController _controller;
  Animation _animation;

  @override
  void initState() {
    initSize = minSize;
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 50))
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Container(
        child: (_animation.value > minSize + 30)
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
            height: (_animation.value >= maxSize)
                ? maxSize
                : (_animation.value <= minSize) ? minSize : _animation.value,
            child: _animation.value < minSize + 30
                ? Container(
                    color: Theme.of(context).primaryColor,
                    child: Opacity(
                      opacity: _animation.value > minSize
                          ? (minSize + 30 - _animation.value) / 40
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
        ),
      ),
    ]);
  }

  _backToMini() {
    setState(() {
      _animation =
          Tween<double>(begin: initSize, end: minSize).animate(_controller);
      initSize = minSize;
    });
    _controller.forward();
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
    });
    _controller.forward();
  }

  _end() {
    if (_animation.value >= (maxSize + minSize) / 4 &&
            _animation.value < maxSize ||
        (_move - _startdy > 20)) {
      setState(() {
        _animation = Tween<double>(begin: _animation.value, end: maxSize)
            .animate(_controller);
        initSize = maxSize;
      });
      _controller.forward();
    } else if (_animation.value < (maxSize + minSize) / 4 &&
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
    } else if (_animation.value < minSize) {
      setState(() {
        initSize = minSize;
      });
    }
  }
}
