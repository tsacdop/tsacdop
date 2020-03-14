import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:tsacdop/local_storage/key_value_storage.dart';

class SettingState extends ChangeNotifier {
  KeyValueStorage themestorage = KeyValueStorage('themes');
  KeyValueStorage accentstorage = KeyValueStorage('accents');
  KeyValueStorage autoupdatestorage = KeyValueStorage('autoupdate');

  Future initData() async {
    await _getTheme();
    await _getAccentSetColor();
    await _getAutoUpdate();
  }

  ThemeMode _theme;
  ThemeMode get theme => _theme;

  set setTheme(ThemeMode mode) {
    _theme = mode;
    _saveTheme();
    notifyListeners();
  }

  Color _accentSetColor;
  Color get accentSetColor => _accentSetColor;

  set setAccentColor(Color color) {
    _accentSetColor = color;
    _saveAccentSetColor();
    notifyListeners();
  }

  bool _autoUpdate;
  bool get autoUpdate => _autoUpdate;
  set autoUpdate(bool boo) {
    _autoUpdate = boo;
    _saveAutoUpdate();
    notifyListeners();
  }

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    _getTheme();
    _getAccentSetColor();
    _getAutoUpdate();
  }

  _getTheme() async {
    int mode = await themestorage.getInt();
    _theme = ThemeMode.values[mode];
  }

  _saveTheme() async {
    await themestorage.saveInt(_theme.index);
  }

  _getAccentSetColor() async {
    String colorString = await accentstorage.getString();
    print(colorString);
    if (colorString.isNotEmpty) {
      int color = int.parse('FF' + colorString.toUpperCase(), radix: 16);
      _accentSetColor = Color(color).withOpacity(1.0);
      print(_accentSetColor.toString());
    } else {
      _accentSetColor = Colors.blue[400];
    }
  }

  _saveAccentSetColor() async {
    await accentstorage
        .saveString(_accentSetColor.toString().substring(10, 16));
  }

  _getAutoUpdate() async {
    int i = await autoupdatestorage.getInt();
    _autoUpdate = i == 0 ? false : true;
  }

  _saveAutoUpdate() async {
    await autoupdatestorage.saveInt(_autoUpdate ? 1 : 0);
  }
}
