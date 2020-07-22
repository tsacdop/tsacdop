import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../generated/l10n.dart';

extension ContextExtension on BuildContext {
  Color get primaryColor => Theme.of(this).primaryColor;
  Color get accentColor => Theme.of(this).accentColor;
  Color get scaffoldBackgroundColor => Theme.of(this).scaffoldBackgroundColor;
  Color get primaryColorDark => Theme.of(this).primaryColorDark;
  Color get textColor => Theme.of(this).textTheme.bodyText1.color;
  Brightness get brightness => Theme.of(this).brightness;
  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;
  TextTheme get textTheme => Theme.of(this).textTheme;
  S get s => S.of(this);
}

extension IntExtension on int {
  String toDate(BuildContext context) {
    if (this == null) return '';
    final s = context.s;
    DateTime date = DateTime.fromMillisecondsSinceEpoch(this, isUtc: true);
    var difference = DateTime.now().toUtc().difference(date);
    if (difference.inHours < 24) {
      return s.hoursAgo(difference.inHours);
    } else if (difference.inDays < 7) {
      return s.daysAgo(difference.inDays);
    } else {
      return DateFormat.yMMMd().format(
          DateTime.fromMillisecondsSinceEpoch(this, isUtc: true).toLocal());
    }
  }

  String get toTime =>
      '${(this ~/ 60)}:${(this.truncate() % 60).toString().padLeft(2, '0')}';

  String toInterval(BuildContext context) {
    if (this == null || this.isNegative) return '';
    final s = context.s;
    var interval = Duration(milliseconds: this);
    if (interval.inHours <= 48)
      return 'Published daily';
    else if (interval.inDays > 2 && interval.inDays <= 14)
      return 'Published weekly';
    else if (interval.inDays > 14 && interval.inDays < 60)
      return 'Published monthly';
    else
      return 'Published yearly';
  }
}

extension StringExtension on String {
  Future get launchUrl async {
    if (await canLaunch(this)) {
      await launch(this);
    } else {
      print('Could not launch $this');
    }
  }

  Color colorizedark() {
    Color _c;
    var color = json.decode(this);
    if (color[0] > 200 && color[1] > 200 && color[2] > 200) {
      _c =
          Color.fromRGBO((255 - color[0]), 255 - color[1], 255 - color[2], 1.0);
    } else {
      _c = Color.fromRGBO(color[0], color[1] > 200 ? 190 : color[1],
          color[2] > 200 ? 190 : color[2], 1);
    }
    return _c;
  }

  Color colorizeLight() {
    Color _c;
    var color = json.decode(this);
    if (color[0] < 50 && color[1] < 50 && color[2] < 50) {
      _c =
          Color.fromRGBO((255 - color[0]), 255 - color[1], 255 - color[2], 1.0);
    } else {
      _c = Color.fromRGBO(color[0] < 50 ? 100 : color[0],
          color[1] < 50 ? 100 : color[1], color[2] < 50 ? 100 : color[2], 1.0);
    }
    return _c;
  }
}
