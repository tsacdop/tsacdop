import 'package:flutter/material.dart';
import '../generated/l10n.dart';

extension ContextExtension on BuildContext {
  Color get primaryColor => Theme.of(this).primaryColor;
  Color get accentColor => Theme.of(this).accentColor;
  Color get scaffoldBackgroundColor => Theme.of(this).scaffoldBackgroundColor;
  Color get primaryColorDark => Theme.of(this).primaryColorDark;
  Color get textColor => Theme.of(this).textTheme.bodyText1.color;
  Brightness get brightness => Theme.of(this).brightness;
  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.width;
  TextTheme get textTheme => Theme.of(this).textTheme;
  S get s => S.of(this);
}
