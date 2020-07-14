import 'dart:io';
import 'dart:ui';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

import '../local_storage/sqflite_localpodcast.dart';
import '../local_storage/key_value_storage.dart';
import '../type/podcastlocal.dart';
import '../type/episodebrief.dart';
import '../type/settings_backup.dart';
import 'download_state.dart';

void callbackDispatcher() {
  if (Platform.isAndroid)
    Workmanager.executeTask((task, inputData) async {
      var dbHelper = DBHelper();
      List<PodcastLocal> podcastList = await dbHelper.getPodcastLocalAll();
      //lastWork is a indicator for if the app was opened since last backgroundwork
      //if the app wes opend,then the old marked new episode would be marked not new.
      KeyValueStorage lastWorkStorage = KeyValueStorage(lastWorkKey);
      int lastWork = await lastWorkStorage.getInt();
      for (PodcastLocal podcastLocal in podcastList) {
        await dbHelper.updatePodcastRss(podcastLocal, removeMark: lastWork);
        print('Refresh ' + podcastLocal.title);
      }
      await FlutterDownloader.initialize();
      AutoDownloader downloader = AutoDownloader();

      KeyValueStorage autoDownloadStorage =
          KeyValueStorage(autoDownloadNetworkKey);
      int autoDownloadNetwork = await autoDownloadStorage.getInt();
      var result = await Connectivity().checkConnectivity();
      if (autoDownloadNetwork == 1) {
        List<EpisodeBrief> episodes = await dbHelper.getNewEpisodes('all');
        // For safety
        if (episodes.length < 100 && episodes.length > 0) {
          downloader.bindBackgroundIsolate();
          await downloader.startTask(episodes);
        }
      } else if (result == ConnectivityResult.wifi) {
        List<EpisodeBrief> episodes = await dbHelper.getNewEpisodes('all');
        //For safety
        if (episodes.length < 100 && episodes.length > 0) {
          downloader.bindBackgroundIsolate();
          await downloader.startTask(episodes);
        }
      }
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
  KeyValueStorage autoupdateStorage = KeyValueStorage(autoUpdateKey);
  KeyValueStorage intervalStorage = KeyValueStorage(updateIntervalKey);
  KeyValueStorage downloadUsingDataStorage =
      KeyValueStorage(downloadUsingDataKey);
  KeyValueStorage introStorage = KeyValueStorage(introKey);
  KeyValueStorage realDarkStorage = KeyValueStorage(realDarkKey);
  KeyValueStorage autoPlayStorage = KeyValueStorage(autoPlayKey);
  KeyValueStorage defaultSleepTimerStorage =
      KeyValueStorage(defaultSleepTimerKey);
  KeyValueStorage autoSleepTimerStorage = KeyValueStorage(autoSleepTimerKey);
  KeyValueStorage autoSleepTimerModeStorage =
      KeyValueStorage(autoSleepTimerModeKey);
  KeyValueStorage autoSleepTimerStartStorage =
      KeyValueStorage(autoSleepTimerStartKey);
  KeyValueStorage autoSleepTimerEndStorage =
      KeyValueStorage(autoSleepTimerEndKey);
  KeyValueStorage tapToOpenPopupMenuStorage =
      KeyValueStorage(tapToOpenPopupMenuKey);
  KeyValueStorage cacheStorage = KeyValueStorage(cacheMaxKey);
  KeyValueStorage podcastLayoutStorage = KeyValueStorage(podcastLayoutKey);
  KeyValueStorage favLayoutStorage = KeyValueStorage(favLayoutKey);
  KeyValueStorage downloadLayoutStorage = KeyValueStorage(downloadLayoutKey);
  KeyValueStorage recentLayoutStorage = KeyValueStorage(recentLayoutKey);
  KeyValueStorage autoDeleteStorage = KeyValueStorage(autoDeleteKey);
  KeyValueStorage autoDownloadStorage = KeyValueStorage(autoDownloadNetworkKey);

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

  int _initialShowIntor;
  bool _showIntro;
  bool get showIntro => _showIntro;

  bool _realDark;
  bool get realDark => _realDark;
  set setRealDark(bool boo) {
    _realDark = boo;
    _setRealDark();
    notifyListeners();
  }

  int _defaultSleepTimer;
  int get defaultSleepTimer => _defaultSleepTimer;
  set setDefaultSleepTimer(int i) {
    _defaultSleepTimer = i;
    _setDefaultSleepTimer();
    notifyListeners();
  }

  bool _autoPlay;
  bool get autoPlay => _autoPlay;
  set setAutoPlay(bool boo) {
    _autoPlay = boo;
    notifyListeners();
    _saveAutoPlay();
  }

  bool _autoSleepTimer;
  bool get autoSleepTimer => _autoSleepTimer;
  set setAutoSleepTimer(bool boo) {
    _autoSleepTimer = boo;
    notifyListeners();
    _saveAutoSleepTimer();
  }

  int _autoSleepTimerMode;
  int get autoSleepTimerMode => _autoSleepTimerMode;
  set setAutoSleepTimerMode(int mode) {
    _autoSleepTimerMode = mode;
    notifyListeners();
    _saveAutoSleepTimerMode();
  }

  int _autoSleepTimerStart;
  int get autoSleepTimerStart => _autoSleepTimerStart;
  set setAutoSleepTimerStart(int start) {
    _autoSleepTimerStart = start;
    notifyListeners();
    _saveAutoSleepTimerStart();
  }

  int _autoSleepTimerEnd;
  int get autoSleepTimerEnd => _autoSleepTimerEnd;
  set setAutoSleepTimerEnd(int end) {
    _autoSleepTimerEnd = end;
    notifyListeners();
    _saveAutoSleepTimerEnd();
  }

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    _getAutoUpdate();
    _getDownloadUsingData();
    _getSleepTimerData();
    _getUpdateInterval().then((value) async {
      if (_initUpdateTag == 0)
        setWorkManager(24);
      //Restart worker if anythin changed in worker callback.
      //varsion 2 add auto download new episodes
      else if (_autoUpdate && _initialShowIntor == 1) {
        await cancelWork();
        setWorkManager(_initUpdateTag);
        await saveShowIntro(2);
      }
    });
  }

  Future _getTheme() async {
    int mode = await themeStorage.getInt();
    _theme = ThemeMode.values[mode];
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

  Future _getAutoUpdate() async {
    int i = await autoupdateStorage.getInt();
    _autoUpdate = i == 0 ? true : false;
  }

  Future _getUpdateInterval() async {
    _initUpdateTag = await intervalStorage.getInt();
    _updateInterval = _initUpdateTag;
  }

  Future _getDownloadUsingData() async {
    int i = await downloadUsingDataStorage.getInt();
    _downloadUsingData = i == 0 ? true : false;
  }

  Future _saveDownloadUsingData() async {
    await downloadUsingDataStorage.saveInt(_downloadUsingData ? 0 : 1);
  }

  Future _getShowIntro() async {
    _initialShowIntor = await introStorage.getInt();
    _showIntro = _initialShowIntor == 0 ? true : false;
  }

  Future _getRealDark() async {
    int i = await realDarkStorage.getInt();
    _realDark = i == 0 ? false : true;
  }

  Future _getSleepTimerData() async {
    _defaultSleepTimer =
        await defaultSleepTimerStorage.getInt(defaultValue: 30);
    int i = await autoSleepTimerStorage.getInt();
    _autoSleepTimer = i == 1;
    _autoSleepTimerStart =
        await autoSleepTimerStartStorage.getInt(defaultValue: 1380);
    _autoSleepTimerEnd =
        await autoSleepTimerEndStorage.getInt(defaultValue: 360);
    int a = await autoPlayStorage.getInt();
    _autoPlay = a == 0;
    _autoSleepTimerMode = await autoSleepTimerModeStorage.getInt();
  }

  Future _saveAccentSetColor() async {
    await accentStorage
        .saveString(_accentSetColor.toString().substring(10, 16));
  }

  Future _setRealDark() async {
    await realDarkStorage.saveInt(_realDark ? 1 : 0);
  }

  Future saveShowIntro(int i) async {
    await introStorage.saveInt(i);
  }

  Future _saveUpdateInterval() async {
    await intervalStorage.saveInt(_updateInterval);
  }

  Future _saveTheme() async {
    await themeStorage.saveInt(_theme.index);
  }

  Future _saveAutoUpdate() async {
    await autoupdateStorage.saveInt(_autoUpdate ? 0 : 1);
  }

  Future _saveAutoPlay() async {
    await autoPlayStorage.saveInt(_autoPlay ? 0 : 1);
  }

  Future _setDefaultSleepTimer() async {
    await defaultSleepTimerStorage.saveInt(_defaultSleepTimer);
  }

  Future _saveAutoSleepTimer() async {
    await autoSleepTimerStorage.saveInt(_autoSleepTimer ? 1 : 0);
  }

  Future _saveAutoSleepTimerMode() async {
    await autoSleepTimerModeStorage.saveInt(_autoSleepTimerMode);
  }

  Future _saveAutoSleepTimerStart() async {
    await autoSleepTimerStartStorage.saveInt(_autoSleepTimerStart);
  }

  Future _saveAutoSleepTimerEnd() async {
    await autoSleepTimerEndStorage.saveInt(_autoSleepTimerEnd);
  }

  Future<SettingsBackup> backup() async {
    int theme = await themeStorage.getInt();
    String accentColor = await accentStorage.getString();
    int realDark = await realDarkStorage.getInt();
    int autoPlay = await autoPlayStorage.getInt();
    int autoUpdate = await autoupdateStorage.getInt();
    int updateInterval = await intervalStorage.getInt();
    int downloadUsingData = await downloadUsingDataStorage.getInt();
    int cacheMax = await cacheStorage.getInt();
    int podcastLayout = await podcastLayoutStorage.getInt();
    int recentLayout = await recentLayoutStorage.getInt();
    int favLayout = await favLayoutStorage.getInt();
    int downloadLayout = await downloadLayoutStorage.getInt();
    int autoDownloadNetwork = await autoDownloadStorage.getInt();
    List<String> episodePopupMenu =
        await KeyValueStorage(episodePopupMenuKey).getStringList();
    int autoDelete = await autoDeleteStorage.getInt();
    int autoSleepTimer = await autoSleepTimerStorage.getInt();
    int autoSleepTimerStart = await autoSleepTimerStartStorage.getInt();
    int autoSleepTimerEnd = await autoSleepTimerEndStorage.getInt();
    int autoSleepTimerMode = await autoSleepTimerModeStorage.getInt();
    int defaultSleepTime = await defaultSleepTimerStorage.getInt();
    int tapToOpenPopupMenu =
        await KeyValueStorage(tapToOpenPopupMenuKey).getInt(defaultValue: 0);

    return SettingsBackup(
        theme: theme,
        accentColor: accentColor,
        realDark: realDark,
        autoPlay: autoPlay,
        autoUpdate: autoUpdate,
        updateInterval: updateInterval,
        downloadUsingData: downloadUsingData,
        cacheMax: cacheMax,
        podcastLayout: podcastLayout,
        recentLayout: recentLayout,
        favLayout: favLayout,
        downloadLayout: downloadLayout,
        autoDownloadNetwork: autoDownloadNetwork,
        episodePopupMenu: episodePopupMenu,
        autoDelete: autoDelete,
        autoSleepTimer: autoSleepTimer,
        autoSleepTimerStart: autoSleepTimerStart,
        autoSleepTimerEnd: autoSleepTimerEnd,
        autoSleepTimerMode: autoSleepTimerMode,
        defaultSleepTime: defaultSleepTime,
        tapToOpenPopupMenu: tapToOpenPopupMenu);
  }
}
