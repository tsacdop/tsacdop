import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../state/podcast_group.dart';

const String groupsKey = 'groups';
const String playlistKey = 'playlist';
const String autoPlayKey = 'autoPlay';
const String audioPositionKey = 'audioposition';
const String lastWorkKey = 'lastWork';
const String refreshdateKey = 'refreshdate';
const String themesKey = 'themes';
const String accentsKey = 'accents';
const String autoUpdateKey = 'autoAdd';
const String updateIntervalKey = 'updateInterval';
const String downloadUsingDataKey = 'downloadUsingData';
const String introKey = 'intro';
const String realDarkKey = 'realDark';
const String cacheMaxKey = 'cacheMax';
const String podcastLayoutKey = 'podcastLayoutKey';
const String recentLayoutKey = 'recentLayoutKey';
const String favLayoutKey = 'favLayoutKey';
const String downloadLayoutKey = 'downloadLayoutKey';
const String autoDownloadNetworkKey = 'autoDownloadNetwork';
const String episodePopupMenuKey = 'episodePopupMenuKey';
const String autoDeleteKey = 'autoDeleteKey';
const String autoSleepTimerKey = 'autoSleepTimerKey';
const String autoSleepTimerStartKey = 'autoSleepTimerStartKey';
const String autoSleepTimerEndKey = 'autoSleepTimerEndKey';
const String defaultSleepTimerKey = 'defaultSleepTimerKey';
const String autoSleepTimerModeKey = 'autoSleepTimerModeKey';
const String tapToOpenPopupMenuKey = 'tapToOpenPopupMenuKey';
const String fastForwardSecondsKey = 'fastForwardSecondsKey';
const String rewindSecondsKey = 'rewindSecondsKey';
const String playerHeightKey = 'playerHeightKey';
const String speedKey = 'speedKey';
const String skipSilenceKey = 'skipSilenceKey';
const String localeKey = 'localeKey';
const String boostVolumeKey = 'boostVolumeKey';
const String volumeGainKey = 'volumeGainKey';
const String hideListenedKey = 'hideListenedKey';
const String notificationLayoutKey = 'notificationLayoutKey';

class KeyValueStorage {
  final String key;
  KeyValueStorage(this.key);
  Future<List<GroupEntity>> getGroups() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getString(key) == null) {
      var home = PodcastGroup('Home');
      await prefs.setString(
          key,
          json.encode({
            'groups': [home.toEntity().toJson()]
          }));
    }
    return json
        .decode(prefs.getString(key))['groups']
        .cast<Map<String, Object>>()
        .map<GroupEntity>(GroupEntity.fromJson)
        .toList(growable: false);
  }

  Future<bool> saveGroup(List<GroupEntity> groupList) async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.setString(
        key,
        json.encode(
            {'groups': groupList.map((group) => group.toJson()).toList()}));
  }

  Future<bool> saveInt(int setting) async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.setInt(key, setting);
  }

  Future<int> getInt({int defaultValue = 0}) async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getInt(key) == null) await prefs.setInt(key, defaultValue);
    return prefs.getInt(key);
  }

  Future<bool> saveStringList(List<String> playList) async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.setStringList(key, playList);
  }

  Future<List<String>> getStringList() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getStringList(key) == null) {
      await prefs.setStringList(key, []);
    }
    return prefs.getStringList(key);
  }

  Future<bool> saveString(String string) async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, string);
  }

  Future<String> getString() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getString(key) == null) {
      await prefs.setString(key, '');
    }
    return prefs.getString(key);
  }

  Future<bool> saveMenu(List<int> list) async {
    var prefs = await SharedPreferences.getInstance();
    return await prefs.setStringList(
        key, list.map((e) => e.toString()).toList());
  }

  Future<List<int>> getMenu() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getStringList(key) == null || prefs.getStringList(key).isEmpty) {
      await prefs.setStringList(key, ['0', '1', '2', '13', '14']);
    }
    var list = prefs.getStringList(key);
    return list.map(int.parse).toList();
  }

  /// Rreverse is used for compatite bool value save before which set true = 0, false = 1
  Future<bool> getBool(
      {@required bool defaultValue, bool reverse = false}) async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getInt(key) == null) {
      reverse
          ? await prefs.setInt(key, defaultValue ? 0 : 1)
          : await prefs.setInt(key, defaultValue ? 1 : 0);
    }
    var i = prefs.getInt(key);
    return reverse ? i == 0 : i == 1;
  }

  /// Rreverse is used for compatite bool value save before which set true = 0, false = 1
  Future<bool> saveBool(boo, {reverse = false}) async {
    var prefs = await SharedPreferences.getInstance();
    return reverse
        ? prefs.setInt(key, boo ? 0 : 1)
        : prefs.setInt(key, boo ? 1 : 0);
  }

  Future<bool> saveDouble(double data) async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.setDouble(key, data);
  }

  Future<double> getDoubel({double defaultValue = 0.0}) async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getDouble(key) == null) {
      await prefs.setDouble(key, defaultValue);
    }
    return prefs.getDouble(key);
  }
}
