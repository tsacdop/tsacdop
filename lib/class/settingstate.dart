import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:tsacdop/local_storage/key_value_storage.dart';

class SettingState extends ChangeNotifier {
  KeyValueStorage storage = KeyValueStorage('themes');
  int _theme;

  int get theme => _theme;
  void setTheme(int theme) {
    _theme = theme;
    notifyListeners();
    _saveTheme(theme);
  }

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    _getTheme();
  }

  _getTheme() async {
    _theme = await storage.getTheme();
  }

  _saveTheme(theme) async {
    await storage.saveTheme(theme);
  }
}
