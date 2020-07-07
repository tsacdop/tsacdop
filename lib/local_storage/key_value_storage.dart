import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../state/podcast_group.dart';

const String autoPlayKey = 'autoPlay';
//const String autoAddKey = 'autoAdd';
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
//SleepTImer
const String autoSleepTimerKey = 'autoSleepTimerKey';
const String autoSleepTimerStartKey = 'autoSleepTimerStartKey';
const String autoSleepTimerEndKey = 'autoSleepTimerEndKey';
const String defaultSleepTimerKey = 'defaultSleepTimerKey';
const String autoSleepTimerModeKey = 'autoSleepTimerModeKey';
const String tapToOpenPopupMenuKey = 'tapToOpenPopupMenuKey';

class KeyValueStorage {
  final String key;
  KeyValueStorage(this.key);
  Future<List<GroupEntity>> getGroups() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString(key) == null) {
      PodcastGroup home = PodcastGroup('Home');
      await prefs.setString(
          key,
          json.encode({
            'groups': [home.toEntity().toJson()]
          }));
    }
    print(prefs.getString(key));
    return json
        .decode(prefs.getString(key))['groups']
        .cast<Map<String, Object>>()
        .map<GroupEntity>(GroupEntity.fromJson)
        .toList(growable: false);
  }

  Future<bool> saveGroup(List<GroupEntity> groupList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(
        key,
        json.encode(
            {'groups': groupList.map((group) => group.toJson()).toList()}));
  }

  Future<bool> saveInt(int setting) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setInt(key, setting);
  }

  Future<int> getInt({int defaultValue = 0}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getInt(key) == null) await prefs.setInt(key, defaultValue);
    return prefs.getInt(key);
  }

  Future<bool> saveStringList(List<String> playList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setStringList(key, playList);
  }

  Future<List<String>> getStringList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getStringList(key) == null) {
      await prefs.setStringList(key, []);
    }
    return prefs.getStringList(key);
  }

  Future<bool> saveString(String string) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, string);
  }

  Future<String> getString() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString(key) == null) {
      await prefs.setString(key, '');
    }
    return prefs.getString(key);
  }

  saveMenu(List<int> list) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, list.map((e) => e.toString()).toList());
  }

  Future<List<int>> getMenu() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getStringList(key) == null) {
      await prefs.setStringList(key, ['0', '1', '12', '13', '14']);
    }
    List<String> list = prefs.getStringList(key);
    return list.map((e) => int.parse(e)).toList();
  }
}
