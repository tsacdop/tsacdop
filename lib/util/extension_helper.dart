import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
