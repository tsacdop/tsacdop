import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../generated/l10n.dart';

extension ContextExtension on BuildContext {
  Color get primaryColor => Theme.of(this).primaryColor;
  Color get accentColor => Theme.of(this).accentColor;
  Color get scaffoldBackgroundColor => Theme.of(this).scaffoldBackgroundColor;
  Color get primaryColorDark => Theme.of(this).primaryColorDark;
  Color get textColor => Theme.of(this).textTheme.bodyText1.color;
  Color get dialogBackgroundColor => Theme.of(this).dialogBackgroundColor;
  Brightness get brightness => Theme.of(this).brightness;
  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;
  double get paddingTop => MediaQuery.of(this).padding.top;
  TextTheme get textTheme => Theme.of(this).textTheme;
  S get s => S.of(this);
}

extension IntExtension on int {
  String toDate(BuildContext context) {
    if (this == null) return '';
    final s = context.s;
    var date = DateTime.fromMillisecondsSinceEpoch(this, isUtc: true);
    var difference = DateTime.now().toUtc().difference(date);
    if (difference.inMinutes < 30) {
      return s.minsAgo(difference.inMinutes);
    } else if (difference.inMinutes < 60) {
      return s.hoursAgo(0);
    } else if (difference.inHours < 24) {
      return s.hoursAgo(difference.inHours);
    } else if (difference.inDays < 7) {
      return s.daysAgo(difference.inDays);
    } else {
      return DateFormat.yMMMd().format(
          DateTime.fromMillisecondsSinceEpoch(this, isUtc: true).toLocal());
    }
  }

  String get toTime =>
      '${(this ~/ 60).toString().padLeft(2, '0')}:${(truncate() % 60).toString().padLeft(2, '0')}';

  String toInterval(BuildContext context) {
    if (this == null || isNegative) return '';
    final s = context.s;
    var interval = Duration(milliseconds: this);
    if (interval.inHours <= 48) {
      return s.publishedDaily;
    } else if (interval.inDays > 2 && interval.inDays <= 14) {
      return s.publishedWeekly;
    } else if (interval.inDays > 14 && interval.inDays < 60) {
      return s.publishedMonthly;
    } else {
      return s.publishedYearly;
    }
  }
}

extension StringExtension on String {
  Future get launchUrl async {
    if (await canLaunch(this)) {
      await launch(this);
    } else {
      developer.log('Could not launch $this');
      Fluttertoast.showToast(
        msg: '$this Invalid Link',
        gravity: ToastGravity.TOP,
      );
    }
  }

  Color colorizedark() {
    Color c;
    var color = json.decode(this);
    if (color[0] > 200 && color[1] > 200 && color[2] > 200) {
      c = Color.fromRGBO((255 - color[0]), 255 - color[1], 255 - color[2], 1.0);
    } else {
      c = Color.fromRGBO(color[0], color[1] > 200 ? 190 : color[1],
          color[2] > 200 ? 190 : color[2], 1);
    }
    return c;
  }

  Color colorizeLight() {
    Color c;
    var color = json.decode(this);
    if (color[0] < 50 && color[1] < 50 && color[2] < 50) {
      c = Color.fromRGBO((255 - color[0]), 255 - color[1], 255 - color[2], 1.0);
    } else {
      c = Color.fromRGBO(color[0] < 50 ? 100 : color[0],
          color[1] < 50 ? 100 : color[1], color[2] < 50 ? 100 : color[2], 1.0);
    }
    return c;
  }
}
