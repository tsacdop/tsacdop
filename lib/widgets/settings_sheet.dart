import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../util/extension_helper.dart';

class SettingsSheet extends StatefulWidget {
  const SettingsSheet({this.height, super.key});
  final double? height;
  @override
  _SettingsSheetState createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet>
    with TickerProviderStateMixin {
  late Animation _animation;
  late AnimationController _controller;
  late AnimationController _slowController;
  double? _initSize;
  late double _startdy;
  double _move = 0;

  @override
  void initState() {
    _initSize = widget.height;
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
    _animation = Tween<double>(
      begin: 0,
      end: _initSize,
    ).animate(_slowController);
    _slowController.forward();
    super.initState();
  }

  @override
  void dispose() {
    _slowController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox(
        height: context.height,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  _backToMini();
                  Navigator.pop(context);
                },
                child: Container(
                  color: context.background.withValues(
                    alpha:
                        0.8 * math.min(_animation.value / widget.height, 1.0),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onVerticalDragStart: _start,
              onVerticalDragUpdate: _update,
              onVerticalDragEnd: (event) => _end(),
              child: Container(
                height: math.min(_animation.value, widget.height!),
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _backToMini() {
    setState(() {
      _animation = Tween<double>(
        begin: _initSize,
        end: 0,
      ).animate(_slowController);
      _initSize = 0;
    });
    _slowController.forward();
  }

  void _start(DragStartDetails event) {
    setState(() {
      _startdy = event.localPosition.dy;
      _animation = Tween<double>(
        begin: _initSize,
        end: _initSize,
      ).animate(_controller);
    });
    _controller.forward();
  }

  void _update(DragUpdateDetails event) {
    setState(() {
      _move = _startdy - event.localPosition.dy;
      _animation = Tween<double>(
        begin: _initSize,
        end: _initSize! + _move,
      ).animate(_controller);
    });
    _controller.forward();
  }

  Future<void> _end() async {
    if (_move < -50) {
      setState(() {
        _animation = Tween<double>(
          begin: _animation.value,
          end: 0,
        ).animate(_controller);
        _initSize = 0;
      });
      _controller.forward();
      Navigator.pop(context);
    } else {
      setState(() {
        _animation = Tween<double>(
          begin: _animation.value,
          end: widget.height,
        ).animate(_controller);
        _initSize = widget.height;
      });
      _controller.forward();
    }
  }
}
