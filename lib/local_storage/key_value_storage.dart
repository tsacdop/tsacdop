import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tsacdop/class/podcast_group.dart';

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
          }));}
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
}
