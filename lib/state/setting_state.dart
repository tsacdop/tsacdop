import 'dart:developer' as developer;
import 'dart:io';
import 'dart:ui';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';
import 'package:workmanager/workmanager.dart';

import '../generated/l10n.dart';
import '../local_storage/key_value_storage.dart';
import '../local_storage/sqflite_localpodcast.dart';
import '../type/settings_backup.dart';
import 'download_state.dart';

void callbackDispatcher() {
  if (Platform.isAndroid) {
    Workmanager.executeTask((task, inputData) async {
      var dbHelper = DBHelper();
      var podcastList = await dbHelper.getPodcastLocalAll(updateOnly: true);
      //lastWork is a indicator for if the app was opened since last backgroundwork
      //if the app wes opend,then the old marked new episode would be marked not new.
      var lastWorkStorage = KeyValueStorage(lastWorkKey);
      var lastWork = await lastWorkStorage.getInt();
      for (var podcastLocal in podcastList) {
        await dbHelper.updatePodcastRss(podcastLocal, removeMark: lastWork);
        developer.log('Refresh ${podcastLocal.title}');
      }
      await FlutterDownloader.initialize();
      var downloader = AutoDownloader();

      var autoDownloadStorage = KeyValueStorage(autoDownloadNetworkKey);
      var autoDownloadNetwork = await autoDownloadStorage.getInt();
      var result = await Connectivity().checkConnectivity();
      if (autoDownloadNetwork == 1) {
        var episodes = await dbHelper.getNewEpisodes('all');
        // For safety
        if (episodes.length < 100 && episodes.length > 0) {
          downloader.bindBackgroundIsolate();
          await downloader.startTask(episodes);
        }
      } else if (result == ConnectivityResult.wifi) {
        var episodes = await dbHelper.getNewEpisodes('all');
        //For safety
        if (episodes.length < 100 && episodes.length > 0) {
          downloader.bindBackgroundIsolate();
          await downloader.startTask(episodes);
        }
      }
      await lastWorkStorage.saveInt(1);
      var refreshstorage = KeyValueStorage(refreshdateKey);
      await refreshstorage.saveInt(DateTime.now().millisecondsSinceEpoch);
      return Future.value(true);
    });
  }
}

final showNotesFontStyles = <TextStyle>[
  TextStyle(
    height: 1.8,
  ),
  GoogleFonts.martel(
      textStyle: TextStyle(
    height: 1.8,
  )),
  GoogleFonts.bitter(
      textStyle: TextStyle(
    height: 1.8,
  )),
];

class SettingState extends ChangeNotifier {
  final _themeStorage = KeyValueStorage(themesKey);
  final _accentStorage = KeyValueStorage(accentsKey);
  final _autoupdateStorage = KeyValueStorage(autoUpdateKey);
  final _intervalStorage = KeyValueStorage(updateIntervalKey);
  final _downloadUsingDataStorage = KeyValueStorage(downloadUsingDataKey);
  final _introStorage = KeyValueStorage(introKey);
  final _realDarkStorage = KeyValueStorage(realDarkKey);
  final _autoPlayStorage = KeyValueStorage(autoPlayKey);
  final _defaultSleepTimerStorage = KeyValueStorage(defaultSleepTimerKey);
  final _autoSleepTimerStorage = KeyValueStorage(autoSleepTimerKey);
  final _autoSleepTimerModeStorage = KeyValueStorage(autoSleepTimerModeKey);
  final _autoSleepTimerStartStorage = KeyValueStorage(autoSleepTimerStartKey);
  final _autoSleepTimerEndStorage = KeyValueStorage(autoSleepTimerEndKey);
  final _cacheStorage = KeyValueStorage(cacheMaxKey);
  final _podcastLayoutStorage = KeyValueStorage(podcastLayoutKey);
  final _favLayoutStorage = KeyValueStorage(favLayoutKey);
  final _downloadLayoutStorage = KeyValueStorage(downloadLayoutKey);
  final _recentLayoutStorage = KeyValueStorage(recentLayoutKey);
  final _autoDeleteStorage = KeyValueStorage(autoDeleteKey);
  final _autoDownloadStorage = KeyValueStorage(autoDownloadNetworkKey);
  final _fastForwardSecondsStorage = KeyValueStorage(fastForwardSecondsKey);
  final _rewindSecondsStorage = KeyValueStorage(rewindSecondsKey);
  final _localeStorage = KeyValueStorage(localeKey);
  final _showNotesFontStorage = KeyValueStorage(showNotesFontKey);
  final _openPlaylistDefaultStorage = KeyValueStorage(openPlaylistDefaultKey);
  final _openAllPodcastDefaultStorage =
      KeyValueStorage(openAllPodcastDefaultKey);

  Future initData() async {
    await _getTheme();
    await _getAccentSetColor();
    await _getShowIntro();
    await _getRealDark();
    await _getOpenPlaylistDefault();
  }

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    _getLocale();
    _getAutoUpdate();
    _getDownloadUsingData();
    _getSleepTimerData();
    _getPlayerSeconds();
    _getShowNotesFonts();
    _getOpenAllPodcastDefault();
    _getUpdateInterval().then((value) async {
      if (_initUpdateTag == 0) {
        setWorkManager(24);
      } else if (_autoUpdate && _initialShowIntor < 3) {
        await cancelWork();
        setWorkManager(_initUpdateTag);
        await saveShowIntro(3);
      }
    });
  }

  Locale _locale;

  /// Load locale.
  Locale get locale => _locale;

  /// Spp thememode. default auto.
  ThemeMode _theme;
  ThemeMode get theme => _theme;

  ThemeData get lightTheme => ThemeData(
      accentColorBrightness: Brightness.dark,
      primaryColor: Colors.grey[100],
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
      accentColor: _accentSetColor,
      cursorColor: _accentSetColor,
      textSelectionHandleColor: _accentSetColor,
      toggleableActiveColor: _accentSetColor,
      buttonTheme: ButtonThemeData(
          height: 32,
          hoverColor: _accentSetColor.withAlpha(70),
          splashColor: _accentSetColor.withAlpha(70)));
  ThemeData get darkTheme => ThemeData.dark().copyWith(
      accentColor: _accentSetColor,
      primaryColorDark: Colors.grey[800],
      scaffoldBackgroundColor: _realDark ? Colors.black87 : Color(0XFF212121),
      primaryColor: _realDark ? Colors.black : Color(0XFF1B1B1B),
      popupMenuTheme: PopupMenuThemeData()
          .copyWith(color: _realDark ? Colors.grey[900] : null),
      appBarTheme: AppBarTheme(elevation: 0),
      buttonTheme: ButtonThemeData(height: 32),
      dialogBackgroundColor: _realDark ? Colors.grey[900] : null,
      cursorColor: _accentSetColor);

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
    developer.log('work manager init done + ');
  }

  Future cancelWork() async {
    await Workmanager.cancelByUniqueName('1');
    developer.log('work job cancelled');
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

  /// Open playlist page default
  bool _openPlaylistDefault;
  bool get openPlaylistDefault => _openPlaylistDefault;
  set openPlaylistDefault(bool boo) {
    _openPlaylistDefault = boo;
    _setOpenPlaylistDefault();
    notifyListeners();
  }

  /// Open all podcasts page default
  bool _openAllPodcastDefault;
  bool get openAllPodcastDefalt => _openAllPodcastDefault;
  set openAllPodcastDefault(boo) {
    _openAllPodcastDefault = boo;
    _setOpenAllPodcastDefault();
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

  int _showNotesFontIndex;
  int get showNotesFontIndex => _showNotesFontIndex;
  TextStyle get showNoteFontStyle => showNotesFontStyles[_showNotesFontIndex];
  set setShowNoteFontStyle(int index) {
    _showNotesFontIndex = index;
    notifyListeners();
    _saveShowNotesFonts();
  }

  Future _getTheme() async {
    var mode = await _themeStorage.getInt();
    _theme = ThemeMode.values[mode];
  }

  Future _getAccentSetColor() async {
    var colorString = await _accentStorage.getString();
    if (colorString.isNotEmpty) {
      var color = int.parse('FF${colorString.toUpperCase()}', radix: 16);
      _accentSetColor = Color(color).withOpacity(1.0);
    } else {
      _accentSetColor = Colors.teal[500];
      await _saveAccentSetColor();
    }
  }

  Future _getAutoUpdate() async {
    _autoUpdate =
        await _autoupdateStorage.getBool(defaultValue: true, reverse: true);
  }

  Future _getUpdateInterval() async {
    _initUpdateTag = await _intervalStorage.getInt();
    _updateInterval = _initUpdateTag;
  }

  Future _getDownloadUsingData() async {
    _downloadUsingData = await _downloadUsingDataStorage.getBool(
        defaultValue: true, reverse: true);
  }

  Future _saveDownloadUsingData() async {
    await _downloadUsingDataStorage.saveBool(_downloadUsingData, reverse: true);
  }

  Future _getShowIntro() async {
    _initialShowIntor = await _introStorage.getInt();
    _showIntro = _initialShowIntor == 0;
  }

  Future _getRealDark() async {
    _realDark = await _realDarkStorage.getBool(defaultValue: false);
  }

  Future _getOpenPlaylistDefault() async {
    _openPlaylistDefault =
        await _openPlaylistDefaultStorage.getBool(defaultValue: false);
  }

  Future _getOpenAllPodcastDefault() async {
    _openAllPodcastDefault =
        await _openAllPodcastDefaultStorage.getBool(defaultValue: false);
  }

  Future _getSleepTimerData() async {
    _defaultSleepTimer =
        await _defaultSleepTimerStorage.getInt(defaultValue: 30);
    _autoSleepTimer = await _autoSleepTimerStorage.getBool(defaultValue: false);
    _autoSleepTimerStart =
        await _autoSleepTimerStartStorage.getInt(defaultValue: 1380);
    _autoSleepTimerEnd =
        await _autoSleepTimerEndStorage.getInt(defaultValue: 360);
    _autoPlay =
        await _autoPlayStorage.getBool(defaultValue: true, reverse: true);
    _autoSleepTimerMode = await _autoSleepTimerModeStorage.getInt();
  }

  Future _getPlayerSeconds() async {
    _rewindSeconds = await _rewindSecondsStorage.getInt(defaultValue: 10);
    _fastForwardSeconds =
        await _fastForwardSecondsStorage.getInt(defaultValue: 30);
  }

  Future _getLocale() async {
    var localeString = await _localeStorage.getStringList();
    if (localeString.isEmpty) {
      await findSystemLocale();
      var systemLanCode;
      final list = Intl.systemLocale.split('_');
      if (list.length == 2) {
        systemLanCode = list.first;
      } else if (list.length == 3) {
        systemLanCode = '${list[0]}_${list[1]}';
      } else {
        systemLanCode = 'en';
      }
      _locale = Locale(systemLanCode);
    } else {
      _locale = Locale(localeString.first, localeString[1]);
    }
    await S.load(_locale);
  }

  Future<void> _getShowNotesFonts() async {
    _showNotesFontIndex = await _showNotesFontStorage.getInt(defaultValue: 1);
  }

  Future<void> _saveAccentSetColor() async {
    await _accentStorage
        .saveString(_accentSetColor.toString().substring(10, 16));
  }

  Future<void> _setRealDark() async {
    await _realDarkStorage.saveBool(_realDark);
  }

  Future<void> _setOpenPlaylistDefault() async {
    await _openPlaylistDefaultStorage.saveBool(_openPlaylistDefault);
  }

  Future<void> _setOpenAllPodcastDefault() async {
    await _openAllPodcastDefaultStorage.saveBool(_openAllPodcastDefault);
  }

  Future<void> saveShowIntro(int i) async {
    await _introStorage.saveInt(i);
  }

  Future<void> _saveUpdateInterval() async {
    await _intervalStorage.saveInt(_updateInterval);
  }

  Future<void> _saveTheme() async {
    await _themeStorage.saveInt(_theme.index);
  }

  Future<void> _saveAutoUpdate() async {
    await _autoupdateStorage.saveBool(_autoUpdate, reverse: true);
  }

  Future<void> _saveAutoPlay() async {
    await _autoPlayStorage.saveBool(_autoPlay, reverse: true);
  }

  Future<void> _setDefaultSleepTimer() async {
    await _defaultSleepTimerStorage.saveInt(_defaultSleepTimer);
  }

  Future<void> _saveAutoSleepTimer() async {
    await _autoSleepTimerStorage.saveBool(_autoSleepTimer);
  }

  Future<void> _saveAutoSleepTimerMode() async {
    await _autoSleepTimerModeStorage.saveInt(_autoSleepTimerMode);
  }

  Future<void> _saveAutoSleepTimerStart() async {
    await _autoSleepTimerStartStorage.saveInt(_autoSleepTimerStart);
  }

  Future<void> _saveAutoSleepTimerEnd() async {
    await _autoSleepTimerEndStorage.saveInt(_autoSleepTimerEnd);
  }

  Future<void> _saveFastForwardSeconds() async {
    await _fastForwardSecondsStorage.saveInt(_fastForwardSeconds);
  }

  Future<void> _saveRewindSeconds() async {
    await _rewindSecondsStorage.saveInt(_rewindSeconds);
  }

  Future<void> _saveShowNotesFonts() async {
    await _showNotesFontStorage.saveInt(_showNotesFontIndex);
  }

  Future<SettingsBackup> backup() async {
    var theme = await _themeStorage.getInt();
    var accentColor = await _accentStorage.getString();
    var realDark = await _realDarkStorage.getBool(defaultValue: false);
    var autoPlay =
        await _autoPlayStorage.getBool(defaultValue: true, reverse: true);
    var autoUpdate =
        await _autoupdateStorage.getBool(defaultValue: true, reverse: true);
    var updateInterval = await _intervalStorage.getInt();
    var downloadUsingData = await _downloadUsingDataStorage.getBool(
        defaultValue: true, reverse: true);
    var cacheMax = await _cacheStorage.getInt(defaultValue: 500 * 1024 * 1024);
    var podcastLayout = await _podcastLayoutStorage.getInt();
    var recentLayout = await _recentLayoutStorage.getInt();
    var favLayout = await _favLayoutStorage.getInt();
    var downloadLayout = await _downloadLayoutStorage.getInt();
    var autoDownloadNetwork =
        await _autoDownloadStorage.getBool(defaultValue: false);
    var episodePopupMenu = await KeyValueStorage(episodePopupMenuKey).getMenu();
    var autoDelete = await _autoDeleteStorage.getInt();
    var autoSleepTimer =
        await _autoSleepTimerStorage.getBool(defaultValue: false);
    var autoSleepTimerStart = await _autoSleepTimerStartStorage.getInt();
    var autoSleepTimerEnd = await _autoSleepTimerEndStorage.getInt();
    var autoSleepTimerMode = await _autoSleepTimerModeStorage.getInt();
    var defaultSleepTime = await _defaultSleepTimerStorage.getInt();
    var tapToOpenPopupMenu = await KeyValueStorage(tapToOpenPopupMenuKey)
        .getBool(defaultValue: false);
    var fastForwardSeconds =
        await _fastForwardSecondsStorage.getInt(defaultValue: 30);
    var rewindSeconds = await _rewindSecondsStorage.getInt(defaultValue: 10);
    var playerHeight =
        await KeyValueStorage(playerHeightKey).getInt(defaultValue: 0);
    var localeList = await _localeStorage.getStringList();
    var backupLocale =
        localeList.isEmpty ? '' : '${'${localeList.first}-'}${localeList[1]}';
    var hideListened =
        await KeyValueStorage(hideListenedKey).getBool(defaultValue: false);
    var notificationLayout =
        await KeyValueStorage(notificationLayoutKey).getInt(defaultValue: 0);
    var showNotesFont = await _showNotesFontStorage.getInt(defaultValue: 1);
    var speedList = await KeyValueStorage(speedListKey).getStringList();
    var hidePodcastDiscovery = await KeyValueStorage(hidePodcastDiscoveryKey)
        .getBool(defaultValue: false);
    final markListenedAfterSKip =
        await KeyValueStorage(markListenedAfterSkipKey)
            .getBool(defaultValue: false);
    final deleteAfterPlayed = await KeyValueStorage(deleteAfterPlayedKey)
        .getBool(defaultValue: false);

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
        episodePopupMenu: episodePopupMenu.map((e) => e.toString()).toList(),
        autoDelete: autoDelete,
        autoSleepTimer: autoSleepTimer,
        autoSleepTimerStart: autoSleepTimerStart,
        autoSleepTimerEnd: autoSleepTimerEnd,
        autoSleepTimerMode: autoSleepTimerMode,
        defaultSleepTime: defaultSleepTime,
        tapToOpenPopupMenu: tapToOpenPopupMenu,
        fastForwardSeconds: fastForwardSeconds,
        rewindSeconds: rewindSeconds,
        playerHeight: playerHeight,
        locale: backupLocale,
        hideListened: hideListened,
        notificationLayout: notificationLayout,
        showNotesFont: showNotesFont,
        speedList: speedList,
        hidePodcastDiscovery: hidePodcastDiscovery,
        markListenedAfterSkip: markListenedAfterSKip,
        deleteAfterPlayed: deleteAfterPlayed);
  }

  Future<void> restore(SettingsBackup backup) async {
    await _themeStorage.saveInt(backup.theme);
    await _accentStorage.saveString(backup.accentColor);
    await _realDarkStorage.saveBool(backup.realDark);
    await _autoPlayStorage.saveBool(backup.autoPlay, reverse: true);
    await _autoupdateStorage.saveBool(backup.autoUpdate, reverse: true);
    await _intervalStorage.saveInt(backup.updateInterval);
    await _downloadUsingDataStorage.saveBool(backup.downloadUsingData,
        reverse: true);
    await _cacheStorage.saveInt(backup.cacheMax);
    await _podcastLayoutStorage.saveInt(backup.podcastLayout);
    await _recentLayoutStorage.saveInt(backup.recentLayout);
    await _favLayoutStorage.saveInt(backup.favLayout);
    await _downloadLayoutStorage.saveInt(backup.downloadLayout);
    await _autoDownloadStorage.saveBool(backup.autoDownloadNetwork);
    await KeyValueStorage(episodePopupMenuKey)
        .saveStringList(backup.episodePopupMenu);
    await _autoDeleteStorage.saveInt(backup.autoDelete);
    await _autoSleepTimerStorage.saveBool(backup.autoSleepTimer);
    await _autoSleepTimerStartStorage.saveInt(backup.autoSleepTimerStart);
    await _autoSleepTimerEndStorage.saveInt(backup.autoSleepTimerEnd);
    await _autoSleepTimerModeStorage.saveInt(backup.autoSleepTimerMode);
    await _defaultSleepTimerStorage.saveInt(backup.defaultSleepTime);
    await _fastForwardSecondsStorage.saveInt(backup.fastForwardSeconds);
    await _rewindSecondsStorage.saveInt(backup.rewindSeconds);
    await KeyValueStorage(playerHeightKey).saveInt(backup.playerHeight);
    await KeyValueStorage(tapToOpenPopupMenuKey)
        .saveBool(backup.tapToOpenPopupMenu);
    await KeyValueStorage(hideListenedKey).saveBool(backup.hideListened);
    await KeyValueStorage(notificationLayoutKey)
        .saveInt(backup.notificationLayout);
    await _showNotesFontStorage.saveInt(backup.showNotesFont);
    await KeyValueStorage(speedListKey).saveStringList(backup.speedList);
    await KeyValueStorage(markListenedAfterSkipKey)
        .saveBool(backup.markListenedAfterSkip);
    await KeyValueStorage(deleteAfterPlayedKey)
        .saveBool(backup.deleteAfterPlayed);

    if (backup.locale == '') {
      await _localeStorage.saveStringList([]);
      await S.load(Locale(Intl.systemLocale));
    } else {
      var localeList = backup.locale.split('-');
      var backupLocale;
      if (localeList[1] == 'null') {
        backupLocale = Locale(localeList.first);
      } else {
        backupLocale = Locale(localeList.first, localeList[1]);
      }
      await _localeStorage.saveStringList(
          [backupLocale.languageCode, backupLocale.countryCode]);
      await S.load(backupLocale);
    }
    await initData();
    await _getAutoUpdate();
    await _getDownloadUsingData();
    await _getSleepTimerData();
    await _getShowNotesFonts();
    await _getUpdateInterval().then((value) async {
      if (_autoUpdate) {
        await cancelWork();
        setWorkManager(_initUpdateTag);
        await saveShowIntro(3);
      }
    });
  }
}
