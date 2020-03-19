import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tsacdop/class/podcastlocal.dart';
import 'package:workmanager/workmanager.dart';

import 'package:tsacdop/local_storage/sqflite_localpodcast.dart';
import 'package:tsacdop/local_storage/key_value_storage.dart';

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {
    var dbHelper = DBHelper();
    print('Start task');
    List<PodcastLocal> podcastList = await dbHelper.getPodcastLocalAll();
    int i = 0;
    await Future.forEach(podcastList, (podcastLocal) async {
      i += await dbHelper.updatePodcastRss(podcastLocal);
      print('Refresh ' + podcastLocal.title);
    });
    KeyValueStorage refreshstorage = KeyValueStorage('refreshdate');
    await refreshstorage.saveInt(DateTime.now().millisecondsSinceEpoch);
    KeyValueStorage refreshcountstorage = KeyValueStorage('refreshcount');
    await refreshcountstorage.saveInt(i);
    return Future.value(true);
  });
}

class SettingState extends ChangeNotifier {
  KeyValueStorage themestorage = KeyValueStorage('themes');
  KeyValueStorage accentstorage = KeyValueStorage('accents');
  KeyValueStorage autoupdatestorage = KeyValueStorage('autoupdate');
  KeyValueStorage intervalstorage = KeyValueStorage('updateInterval');

  Future initData() async {
    await _getTheme();
    await _getAccentSetColor();
  }

  ThemeMode _theme;
  ThemeMode get theme => _theme;

  set setTheme(ThemeMode mode) {
    _theme = mode;
    _saveTheme();
    notifyListeners();
  }

  void setWorkManager(int hour) {
    _updateInterval = hour;
    notifyListeners();
    _saveUpdateInterval();
    Workmanager.initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );
    Workmanager.registerPeriodicTask("1", "update_podcasts",
        frequency: Duration(hours: hour),
        initialDelay: Duration(seconds: 10),
        constraints: Constraints(
          networkType: NetworkType.connected,
        ));
    print('work manager init done + ');
  }

  void cancelWork() {
    Workmanager.cancelAll();
    print('work job cancelled');
  }

  Color _accentSetColor;
  Color get accentSetColor => _accentSetColor;

  set setAccentColor(Color color) {
    _accentSetColor = color;
    _saveAccentSetColor();
    notifyListeners();
  }

  int _updateInterval;
  int get updateInterval => _updateInterval;

  int _initUpdateTag;
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
    _getUpdateInterval().then((value) {
      if (_initUpdateTag == 0) setWorkManager(24);
    });
  }

  Future _getTheme() async {
    int mode = await themestorage.getInt();
    _theme = ThemeMode.values[mode];
  }

  Future _saveTheme() async {
    await themestorage.saveInt(_theme.index);
  }

  Future _getAccentSetColor() async {
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

  Future _saveAccentSetColor() async {
    await accentstorage
        .saveString(_accentSetColor.toString().substring(10, 16));
  }

  Future _getAutoUpdate() async {
    int i = await autoupdatestorage.getInt();
    _autoUpdate = i == 0 ? true : false;
  }

  Future _saveAutoUpdate() async {
    await autoupdatestorage.saveInt(_autoUpdate ? 0 : 1);
  }

  Future _getUpdateInterval() async {
    _initUpdateTag = await intervalstorage.getInt();
    _updateInterval = _initUpdateTag == 0 ? 24 : _initUpdateTag;
  }

  Future _saveUpdateInterval() async {
    await intervalstorage.saveInt(_updateInterval);
  }
}
