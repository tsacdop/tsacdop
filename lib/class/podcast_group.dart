import 'dart:collection';
import 'dart:core';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tsacdop/local_storage/key_value_storage.dart';
import 'package:tsacdop/local_storage/sqflite_localpodcast.dart';
import 'package:uuid/uuid.dart';
import 'package:tsacdop/class/podcastlocal.dart';

class GroupEntity {
  final String name;
  final String id;
  final String color;
  final List<String> podcastList;

  GroupEntity(this.name, this.id, this.color, this.podcastList);

  Map<String, Object> toJson() {
    return {'name': name, 'id': id, 'color': color, 'podcastList': podcastList};
  }

  static GroupEntity fromJson(Map<String, Object> json) {
    List<String> list = List.from(json['podcastList']);
    print(json['[podcastList']);
    return 
    GroupEntity(
        json['name'] as String, 
        json['id'] as String,
        json['color'] as String, 
        list);
  }
}

class PodcastGroup {
  final String name;
  final String id;
  final String color;
  List<String> podcastList;

  PodcastGroup(this.name,
      {this.color = '#000000', String id, List<String> podcastList})
      : id = id ?? Uuid().v4(),
        podcastList = podcastList ?? [];

  Future getPodcasts() async {
    var dbHelper = DBHelper();
    if (podcastList != []) {
      _podcasts = await dbHelper.getPodcastLocal(podcastList);
    }
  }

  List<PodcastLocal> _podcasts;

  List<PodcastLocal> get podcasts => _podcasts;

  GroupEntity toEntity() {
    return GroupEntity(name, id, color, podcastList);
  }

  static PodcastGroup fromEntity(GroupEntity entity) {
    return PodcastGroup(
      entity.name,
      id: entity.id,
      color: entity.color,
      podcastList: entity.podcastList,
    );
  }
}

class GroupList extends ChangeNotifier {
  List<PodcastGroup> _groups;
  DBHelper dbHelper = DBHelper();
  UnmodifiableListView<PodcastGroup> get groups =>
      UnmodifiableListView(_groups);

  KeyValueStorage storage = KeyValueStorage('groups');
  GroupList({List<PodcastGroup> groups}) : _groups = groups ?? [];

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    loadGroups();
  }

  Future loadGroups() async {
    _isLoading = true;
    notifyListeners();
    storage.getGroups().then((loadgroups) async {
      _groups.addAll(loadgroups.map((e) => PodcastGroup.fromEntity(e)));
    await Future.forEach(_groups, (group) async {
        await group.getPodcasts();
      });
   _isLoading = false;
    notifyListeners();
    });
  }

  Future addGroup(PodcastGroup podcastGroup) async {
    _groups.add(podcastGroup);
    _saveGroup();
    notifyListeners();
  }

  Future delGroup(PodcastGroup podcastGroup) async {
    _groups.remove(podcastGroup);
    notifyListeners();
    _saveGroup();
  }

  void updateGroup(PodcastGroup podcastGroup) {
    var oldGroup = _groups.firstWhere((it) => it.id == podcastGroup.id);
    var index = _groups.indexOf(oldGroup);
    _groups.replaceRange(index, index + 1, [podcastGroup]);
    notifyListeners();
    _saveGroup();
  }

  void _saveGroup() {
    storage.saveGroup(_groups.map((it) => it.toEntity()).toList());
  }

  Future subscribe(PodcastLocal podcastLocal) async {
    _groups[0].podcastList.add(podcastLocal.id);
    _saveGroup();
    await dbHelper.savePodcastLocal(podcastLocal);
    await _groups[0].getPodcasts();
    notifyListeners();
  }

  List<PodcastGroup> getPodcastGroup(String id) {
    List<PodcastGroup> result =[];
    _groups.forEach((group) {
      if (group.podcastList.contains(id)) {
        result.add(group);
      }
    });
    return result;
  }

  changeGroup(String id, List<String> list) async{
    _groups.forEach((group) {
      if (group.podcastList.contains(id)) {
        group.podcastList.remove(id);
      }
    });
    await Future.forEach(list, (s) {
      _groups.forEach((group) async{
        if (group.name == s) group.podcastList.add(id);
        await group.getPodcasts();
      });
    });
    _saveGroup();
    notifyListeners();
  }

  removePodcast(String id) async{
    await Future.forEach(_groups, (group) async{
      if (group.podcastList.contains(id)) {
        group.podcastList.remove(id);
        await group.getPodcasts();
      }
    });
    _saveGroup();
    await dbHelper.delPodcastLocal(id);
   notifyListeners(); 
  }

  saveOrder(PodcastGroup group, List<PodcastLocal> podcasts) async{
      group.podcastList = podcasts.map((e) => e.id).toList();
      _saveGroup();
      await group.getPodcasts();
      notifyListeners();
  }
}
