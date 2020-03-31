import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tsacdop/class/podcastlocal.dart';
import 'package:workmanager/workmanager.dart';

import 'package:tsacdop/local_storage/sqflite_localpodcast.dart';
import 'package:tsacdop/local_storage/key_value_storage.dart';

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {
    var dbHelper = DBHelper();
    List<PodcastLocal> podcastList = await dbHelper.getPodcastLocalAll();
    await Future.forEach(podcastList, (podcastLocal) async {
     await dbHelper.updatePodcastRss(podcastLocal);
      print('Refresh ' + podcastLocal.title);
    });
    KeyValueStorage refreshstorage = KeyValueStorage('refreshdate');
    await refreshstorage.saveInt(DateTime.now().millisecondsSinceEpoch);
    return Future.value(true);
  });
}

class SettingState extends ChangeNotifier {
  KeyValueStorage themeStorage = KeyValueStorage('themes');
  KeyValueStorage accentStorage = KeyValueStorage('accents');
  KeyValueStorage autoupdateStorage = KeyValueStorage('autoupdate');
  KeyValueStorage intervalStorage = KeyValueStorage('updateInterval');
  KeyValueStorage downloadUsingDataStorage =
      KeyValueStorage('downloadUsingData');

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
      isInDebugMode: false,
    );
    Workmanager.registerPeriodicTask("1", "update_podcasts",
        frequency: Duration(hours: hour),
        initialDelay: Duration(seconds: 10),
        constraints: Constraints(
          networkType: NetworkType.connected,
        ));
    print('work manager init done + ');
  }

  Future cancelWork() async{
    await Workmanager.cancelAll();
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

  bool _downloadUsingData;
  bool get downloadUsingData => _downloadUsingData;
  set downloadUsingData(bool boo) {
    _downloadUsingData = boo;
    _saveDownloadUsingData();
    notifyListeners();
  }

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    _getTheme();
    _getAccentSetColor();
    _getAutoUpdate();
    _getDownloadUsingData();
    _getUpdateInterval().then((value) {
      if (_initUpdateTag == 0) setWorkManager(24);
    });
  }

  Future _getTheme() async {
    int mode = await themeStorage.getInt();
    _theme = ThemeMode.values[mode];
  }

  Future _saveTheme() async {
    await themeStorage.saveInt(_theme.index);
  }

  Future _getAccentSetColor() async {
    String colorString = await accentStorage.getString();
    if (colorString.isNotEmpty) {
      int color = int.parse('FF' + colorString.toUpperCase(), radix: 16);
      _accentSetColor = Color(color).withOpacity(1.0);
    } else {
      _accentSetColor = Colors.blue[400];
    }
  }

  Future _saveAccentSetColor() async {
    await accentStorage
        .saveString(_accentSetColor.toString().substring(10, 16));
  }

  Future _getAutoUpdate() async {
    int i = await autoupdateStorage.getInt();
    _autoUpdate = i == 0 ? true : false;
  }

  Future _saveAutoUpdate() async {
    await autoupdateStorage.saveInt(_autoUpdate ? 0 : 1);
  }

  Future _getUpdateInterval() async {
    _initUpdateTag = await intervalStorage.getInt();
    _updateInterval = _initUpdateTag;
  }

  Future _saveUpdateInterval() async {
    await intervalStorage.saveInt(_updateInterval);
  }

  Future _getDownloadUsingData() async {
    int i = await downloadUsingDataStorage.getInt();
    _downloadUsingData = i == 0 ? true : false;
  }

  Future _saveDownloadUsingData() async {
    await downloadUsingDataStorage.saveInt(_downloadUsingData ? 0 : 1);
  }
}
