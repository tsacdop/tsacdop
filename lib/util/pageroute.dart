import 'package:flutter/material.dart';

//Slide Transition
class SlideLeftRoute extends PageRouteBuilder {
  final Widget page;
  SlideLeftRoute({this.page})
      : super(
            pageBuilder: (
              context,
              animation,
              secondaryAnimation,
            ) =>
                page,
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              var begin = Offset(1.0, 0.0);
              var end = Offset.zero;
              var curve = Curves.easeOutQuart;
              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var tweenSequence = TweenSequence(<TweenSequenceItem<Offset>>[
                TweenSequenceItem<Offset>(
                  tween: tween,
                  weight: 90.0,
                ),
                TweenSequenceItem<Offset>(
                  tween: ConstantTween<Offset>(Offset.zero),
                  weight: 10.0,
                ),
              ]);
              return SlideTransition(
                position: animation.drive(tweenSequence),
                child: child,
              );
            });
}

class SlideLeftHideRoute extends PageRouteBuilder {
  final Widget page;
  // final Widget transitionPage;
  SlideLeftHideRoute({this.page})
      : super(
          pageBuilder: (
            context,
            animation,
            secondaryAnimation,
          ) =>
              page,
          // transitionDuration: Duration(milliseconds: 300),
          transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
          ) {
            return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child);
          },
        );
}

class SlideUptRoute extends PageRouteBuilder {
  final Widget page;
  SlideUptRoute({this.page})
      : super(
          pageBuilder: (
            context,
            animation,
            secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
          ) =>
              SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
}

//Scale Pageroute
class ScaleRoute extends PageRouteBuilder {
  final Widget page;
  ScaleRoute({this.page})
      : super(
          pageBuilder: (
            context,
            animation,
            secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
          ) =>
              ScaleTransition(
            scale: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.fastOutSlowIn,
              ),
            ),
            child: child,
          ),
        );
}

class FadeRoute extends PageRouteBuilder {
  final Widget page;
  FadeRoute({this.page})
      : super(
          pageBuilder: (
            context,
            animation,
            secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
          ) =>
              FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeInCubic,
              ),
            ),
            child: child,
          ),
        );
}
