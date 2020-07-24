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
    buttonTheme: ButtonThemeData(height: 32));

class SettingState extends ChangeNotifier {
  var themeStorage = KeyValueStorage(themesKey);
  var accentStorage = KeyValueStorage(accentsKey);
  var autoupdateStorage = KeyValueStorage(autoUpdateKey);
  var intervalStorage = KeyValueStorage(updateIntervalKey);
  var downloadUsingDataStorage = KeyValueStorage(downloadUsingDataKey);
  var introStorage = KeyValueStorage(introKey);
  var realDarkStorage = KeyValueStorage(realDarkKey);
  var autoPlayStorage = KeyValueStorage(autoPlayKey);
  var defaultSleepTimerStorage = KeyValueStorage(defaultSleepTimerKey);
  var autoSleepTimerStorage = KeyValueStorage(autoSleepTimerKey);
  var autoSleepTimerModeStorage = KeyValueStorage(autoSleepTimerModeKey);
  var autoSleepTimerStartStorage = KeyValueStorage(autoSleepTimerStartKey);
  var autoSleepTimerEndStorage = KeyValueStorage(autoSleepTimerEndKey);
  var tapToOpenPopupMenuStorage = KeyValueStorage(tapToOpenPopupMenuKey);
  var cacheStorage = KeyValueStorage(cacheMaxKey);
  var podcastLayoutStorage = KeyValueStorage(podcastLayoutKey);
  var favLayoutStorage = KeyValueStorage(favLayoutKey);
  var downloadLayoutStorage = KeyValueStorage(downloadLayoutKey);
  var recentLayoutStorage = KeyValueStorage(recentLayoutKey);
  var autoDeleteStorage = KeyValueStorage(autoDeleteKey);
  var autoDownloadStorage = KeyValueStorage(autoDownloadNetworkKey);
  var fastForwardSecondsStorage = KeyValueStorage(fastForwardSecondsKey);
  var rewindSecondsStorage = KeyValueStorage(rewindSecondsKey);

  Future initData() async {
    await _getTheme();
    await _getAccentSetColor();
    await _getShowIntro();
    await _getRealDark();
  }

  /// Spp thememode. default auto.
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

  /// Auto syncing podcasts in background, default true.
  bool _autoUpdate;
  bool get autoUpdate => _autoUpdate;
  set autoUpdate(bool boo) {
    _autoUpdate = boo;
    _saveAutoUpdate();
    notifyListeners();
  }

  /// Confirem before using data to download episode, default true(reverse).
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

  /// Real dark theme, default false.
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

  /// Auto start sleep timer at night. Defualt false.
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

  int _fastForwardSeconds;
  int get fastForwardSeconds => _fastForwardSeconds;
  set setFastForwardSeconds(int sec) {
    _fastForwardSeconds = sec;
    notifyListeners();
    _saveFastForwardSeconds();
  }

  int _rewindSeconds;
  int get rewindSeconds => _rewindSeconds;
  set setRewindSeconds(int sec) {
    _rewindSeconds = sec;
    notifyListeners();
    _saveRewindSeconds();
  }

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    _getAutoUpdate();
    _getDownloadUsingData();
    _getSleepTimerData();
    _getPlayerSeconds();
    _getUpdateInterval().then((value) async {
      if (_initUpdateTag == 0)
        setWorkManager(24);

      /// Restart worker if anythin changed in worker callback.
      /// varsion 2 add auto download new episodes
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
      await _saveAccentSetColor();
    }
  }

  Future _getAutoUpdate() async {
    _autoUpdate =
        await autoupdateStorage.getBool(defaultValue: true, reverse: true);
  }

  Future _getUpdateInterval() async {
    _initUpdateTag = await intervalStorage.getInt();
    _updateInterval = _initUpdateTag;
  }

  Future _getDownloadUsingData() async {
    _downloadUsingData = await downloadUsingDataStorage.getBool(
        defaultValue: true, reverse: true);
  }

  Future _saveDownloadUsingData() async {
    await downloadUsingDataStorage.saveBool(_downloadUsingData, reverse: true);
  }

  Future _getShowIntro() async {
    _initialShowIntor = await introStorage.getInt();
    _showIntro = _initialShowIntor == 0 ? true : false;
  }

  Future _getRealDark() async {
    _realDark = await realDarkStorage.getBool(defaultValue: false);
  }

  Future _getSleepTimerData() async {
    _defaultSleepTimer =
        await defaultSleepTimerStorage.getInt(defaultValue: 30);
    _autoSleepTimer = await autoSleepTimerStorage.getBool(defaultValue: false);
    _autoSleepTimerStart =
        await autoSleepTimerStartStorage.getInt(defaultValue: 1380);
    _autoSleepTimerEnd =
        await autoSleepTimerEndStorage.getInt(defaultValue: 360);
    _autoPlay =
        await autoPlayStorage.getBool(defaultValue: true, reverse: true);
    _autoSleepTimerMode = await autoSleepTimerModeStorage.getInt();
  }

  Future _getPlayerSeconds() async {
    _rewindSeconds = await rewindSecondsStorage.getInt(defaultValue: 10);
    _fastForwardSeconds =
        await fastForwardSecondsStorage.getInt(defaultValue: 30);
  }

  Future _saveAccentSetColor() async {
    await accentStorage
        .saveString(_accentSetColor.toString().substring(10, 16));
  }

  Future _setRealDark() async {
    await realDarkStorage.saveBool(_realDark);
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
    await autoupdateStorage.saveBool(_autoUpdate, reverse: true);
  }

  Future _saveAutoPlay() async {
    await autoPlayStorage.saveBool(_autoPlay, reverse: true);
  }

  Future _setDefaultSleepTimer() async {
    await defaultSleepTimerStorage.saveInt(_defaultSleepTimer);
  }

  Future _saveAutoSleepTimer() async {
    await autoSleepTimerStorage.saveBool(_autoSleepTimer);
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

  Future _saveFastForwardSeconds() async {
    await fastForwardSecondsStorage.saveInt(_fastForwardSeconds);
  }

  Future _saveRewindSeconds() async {
    await rewindSecondsStorage.saveInt(_rewindSeconds);
  }

  Future<SettingsBackup> backup() async {
    int theme = await themeStorage.getInt();
    String accentColor = await accentStorage.getString();
    bool realDark = await realDarkStorage.getBool(defaultValue: false);
    bool autoPlay =
        await autoPlayStorage.getBool(defaultValue: true, reverse: true);
    bool autoUpdate =
        await autoupdateStorage.getBool(defaultValue: true, reverse: true);
    int updateInterval = await intervalStorage.getInt();
    bool downloadUsingData = await downloadUsingDataStorage.getBool(
        defaultValue: true, reverse: true);
    int cacheMax = await cacheStorage.getInt(defaultValue: 500 * 1024 * 1024);
    int podcastLayout = await podcastLayoutStorage.getInt();
    int recentLayout = await recentLayoutStorage.getInt();
    int favLayout = await favLayoutStorage.getInt();
    int downloadLayout = await downloadLayoutStorage.getInt();
    bool autoDownloadNetwork =
        await autoDownloadStorage.getBool(defaultValue: false);
    List<String> episodePopupMenu =
        await KeyValueStorage(episodePopupMenuKey).getStringList();
    int autoDelete = await autoDeleteStorage.getInt();
    bool autoSleepTimer =
        await autoSleepTimerStorage.getBool(defaultValue: false);
    int autoSleepTimerStart = await autoSleepTimerStartStorage.getInt();
    int autoSleepTimerEnd = await autoSleepTimerEndStorage.getInt();
    int autoSleepTimerMode = await autoSleepTimerModeStorage.getInt();
    int defaultSleepTime = await defaultSleepTimerStorage.getInt();
    bool tapToOpenPopupMenu = await KeyValueStorage(tapToOpenPopupMenuKey)
        .getBool(defaultValue: false);
    int fastForwardSeconds =
        await fastForwardSecondsStorage.getInt(defaultValue: 30);
    int rewindSeconds = await rewindSecondsStorage.getInt(defaultValue: 10);

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
        tapToOpenPopupMenu: tapToOpenPopupMenu,
        fastForwardSeconds: fastForwardSeconds,
        rewindSeconds: rewindSeconds);
  }

  Future<void> restore(SettingsBackup backup) async {
    await themeStorage.saveInt(backup.theme);
    await accentStorage.saveString(backup.accentColor);
    await realDarkStorage.saveBool(backup.realDark);
    await autoPlayStorage.saveBool(backup.autoPlay, reverse: true);
    await autoupdateStorage.saveBool(backup.autoUpdate, reverse: true);
    await intervalStorage.saveInt(backup.updateInterval);
    await downloadUsingDataStorage.saveBool(backup.downloadUsingData,
        reverse: true);
    await cacheStorage.saveInt(backup.cacheMax);
    await podcastLayoutStorage.saveInt(backup.podcastLayout);
    await recentLayoutStorage.saveInt(backup.recentLayout);
    await favLayoutStorage.saveInt(backup.favLayout);
    await downloadLayoutStorage.saveInt(backup.downloadLayout);
    await autoDownloadStorage.saveBool(backup.autoDownloadNetwork);
    await KeyValueStorage(episodePopupMenuKey)
        .saveStringList(backup.episodePopupMenu);
    await autoDeleteStorage.saveInt(backup.autoDelete);
    await autoSleepTimerStorage.saveBool(backup.autoSleepTimer);
    await autoSleepTimerStartStorage.saveInt(backup.autoSleepTimerStart);
    await autoSleepTimerEndStorage.saveInt(backup.autoSleepTimerEnd);
    await autoSleepTimerModeStorage.saveInt(backup.autoSleepTimerMode);
    await defaultSleepTimerStorage.saveInt(backup.defaultSleepTime);
    await fastForwardSecondsStorage.saveInt(backup.fastForwardSeconds);
    await rewindSecondsStorage.saveInt(backup.rewindSeconds);
    await KeyValueStorage(tapToOpenPopupMenuKey)
        .saveBool(backup.tapToOpenPopupMenu);
    await initData();
    await _getAutoUpdate();
    await _getDownloadUsingData();
    await _getSleepTimerData();
    await _getUpdateInterval().then((value) async {
      if (_autoUpdate) {
        await cancelWork();
        setWorkManager(_initUpdateTag);
        await saveShowIntro(2);
      }
    });
  }
}
