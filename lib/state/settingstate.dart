import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

import '../local_storage/sqflite_localpodcast.dart';
import '../local_storage/key_value_storage.dart';
import '../type/podcastlocal.dart';

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {
    var dbHelper = DBHelper();
    List<PodcastLocal> podcastList = await dbHelper.getPodcastLocalAll();
    //lastWork is a indicator for if the app was opened since last backgroundwork
    //if the app wes opend,then the old marked new episode would be marked not new.
    KeyValueStorage lastWorkStorage = KeyValueStorage(lastWorkKey);
    int lastWork = await lastWorkStorage.getInt();
    await Future.forEach<PodcastLocal>(podcastList, (podcastLocal) async {
      await dbHelper.updatePodcastRss(podcastLocal, removeMark: lastWork);
      print('Refresh ' + podcastLocal.title);
    });
    await lastWorkStorage.saveInt(1);
    KeyValueStorage refreshstorage = KeyValueStorage(refreshdateKey);
    await refreshstorage.saveInt(DateTime.now().millisecondsSinceEpoch);
    return Future.value(true);
  });
}

ThemeData lightTheme = ThemeData(
  accentColorBrightness: Brightness.dark,
  primaryColor: Colors.grey[100],
  //  accentColor: _accentSetColor,
  primaryColorLight: Colors.white,
  primaryColorDark: Colors.grey[300],
  dialogBackgroundColor: Colors.white,
  backgroundColor: Colors.grey[100],
  appBarTheme: AppBarTheme(
    color: Colors.grey[100],
    elevation: 0,
  ),
  textTheme: TextTheme(
    bodyText2: TextStyle(fontSize: 15.0, fontWeight: FontWeight.normal),
  ),
  tabBarTheme: TabBarTheme(
    labelColor: Colors.black,
    unselectedLabelColor: Colors.grey[400],
  ),
);

class SettingState extends ChangeNotifier {
  KeyValueStorage themeStorage = KeyValueStorage(themesKey);
  KeyValueStorage accentStorage = KeyValueStorage(accentsKey);
  KeyValueStorage autoupdateStorage = KeyValueStorage(autoAddKey);
  KeyValueStorage intervalStorage = KeyValueStorage(updateIntervalKey);
  KeyValueStorage downloadUsingDataStorage =
      KeyValueStorage(downloadUsingDataKey);
  KeyValueStorage introStorage = KeyValueStorage(introKey);
  KeyValueStorage realDarkStorage = KeyValueStorage(realDarkKey);

  Future initData() async {
    await _getTheme();
    await _getAccentSetColor();
    await _getShowIntro();
    await _getRealDark();
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

  Future cancelWork() async {
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

  bool _showIntro;
  bool get showIntro => _showIntro;

  bool _realDark;
  bool get realDark => _realDark;
  set setRealDark(bool boo) {
    _realDark = boo;
    _setRealDark();
    notifyListeners();
  }

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    _getTheme();
    _getAccentSetColor();
    _getAutoUpdate();
    _getRealDark();
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
      _accentSetColor = Colors.teal[500];
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

  Future _getShowIntro() async {
    int i = await introStorage.getInt();
    _showIntro = i == 0 ? true : false;
  }

  Future saveShowIntro() async {
    await introStorage.saveInt(1);
  }

  Future _getRealDark() async {
    int i = await realDarkStorage.getInt();
    _realDark = i == 0 ? false : true;
  }

  Future _setRealDark() async {
    await realDarkStorage.saveInt(_realDark ? 1 : 0);
  }
}
