import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart' as tuple;

import '../home/audioplayer.dart';
import '../state/audio_state.dart';
import '../util/extension_helper.dart';

class HidePlayerRoute extends ModalRoute<void> {
  HidePlayerRoute(this.openPage, this.transitionPage,
      {required Duration duration})
      : transitionDuration = duration;
  final openPage;
  final transitionPage;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return Selector<AudioPlayerNotifier, tuple.Tuple2<bool, PlayerHeight?>>(
        selector: (_, audio) =>
            tuple.Tuple2(audio.playerRunning, audio.playerHeight),
        builder: (_, data, __) => Align(
              alignment: Alignment.topLeft,
              child: AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  if (animation.isCompleted) {
                    return SizedBox.expand(
                      child: Material(
                        color: Colors.transparent,
                        child: Builder(
                          builder: (context) {
                            return openPage;
                          },
                        ),
                      ),
                    );
                  }
                  // final Animation<double> curvedAnimation = CurvedAnimation(
                  //   parent: animation,
                  //   curve: Curves.fastOutSlowIn,
                  //   reverseCurve: Curves.fastOutSlowIn.flipped,
                  // );
                  final playerHeight = kMinPlayerHeight[data.item2!.index];
                  final playerRunning = data.item1;
                  return SizedBox.expand(
                    child: Container(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Transform.translate(
                          offset:
                              Offset(context.width * (1 - animation.value), 0),
                          child: SizedBox(
                            width: context.width,
                            height: context.height *
                                (playerRunning
                                    ? (1 - playerHeight / context.height)
                                    : 1),
                            child: Material(
                              clipBehavior: Clip.antiAlias,
                              animationDuration: Duration.zero,
                              child: FittedBox(
                                fit: BoxFit.fitWidth,
                                alignment: Alignment.topLeft,
                                child: SizedBox(
                                  width: context.width,
                                  height: context.height,
                                  child: Builder(
                                    builder: (context) {
                                      return transitionPage;
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ));
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

  @override
  final Duration transitionDuration;
}

mixin Tuple2 {}
