import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tsacdop/local_storage/key_value_storage.dart';
import 'package:tsacdop/local_storage/sqflite_localpodcast.dart';
import 'package:uuid/uuid.dart';

import '../type/podcastlocal.dart';

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
    return GroupEntity(json['name'] as String, json['id'] as String,
        json['color'] as String, list);
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

  Color getColor() {
    if (color != '#000000') {
      int colorInt = int.parse('FF' + color.toUpperCase(), radix: 16);
      return Color(colorInt).withOpacity(1.0);
    } else {
      return Colors.blue[400];
    }
  }

  List<PodcastLocal> _podcasts;
  List<PodcastLocal> _orderedPodcasts;
  List<PodcastLocal> get ordereddPodcasts => _orderedPodcasts;
  List<PodcastLocal> get podcasts => _podcasts;

  set setOrderedPodcasts(List<PodcastLocal> list) {
    _orderedPodcasts = list;
  }

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
  List<PodcastGroup> get groups => _groups;

  KeyValueStorage storage = KeyValueStorage('groups');
  GroupList({List<PodcastGroup> groups}) : _groups = groups ?? [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<PodcastGroup> _orderChanged = [];
  List<PodcastGroup> get orderChanged => _orderChanged;

  void addToOrderChanged(PodcastGroup group) {
    _orderChanged.add(group);
    notifyListeners();
  }

  void drlFromOrderChanged(String name) {
    _orderChanged.removeWhere((group) => group.name == name);
    notifyListeners();
  }

  clearOrderChanged() async {
    if (_orderChanged.length > 0) {
      await Future.forEach(_orderChanged, (PodcastGroup group) async {
        await group.getPodcasts();
      });
      _orderChanged.clear();
      // notifyListeners();
    }
  }

  _initGroup() async {
    storage.getGroups().then((loadgroups) async {
      _groups.addAll(loadgroups.map((e) => PodcastGroup.fromEntity(e)));
      await Future.forEach(_groups, (group) async {
        await group.getPodcasts();
      });
    });
  }

  @override
  void addListener(VoidCallback listener) {
    loadGroups().then((value) => super.addListener(listener));
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

//update podcasts of each group
  Future updateGroups() async {
    await Future.forEach(_groups, (group) async {
      await group.getPodcasts();
    });
    notifyListeners();
  }

  Future addGroup(PodcastGroup podcastGroup) async {
    _isLoading = true;
    _groups.add(podcastGroup);
    await _saveGroup();
    _isLoading = false;
    notifyListeners();
  }

  Future delGroup(PodcastGroup podcastGroup) async {
    _isLoading = true;
    podcastGroup.podcastList.forEach((podcast) {
      if (!_groups.first.podcastList.contains(podcast)) {
        _groups[0].podcastList.insert(0, podcast);
      }
    });
    await _saveGroup();
    _groups.remove(podcastGroup);
    await _groups[0].getPodcasts();
    _isLoading = false;
    notifyListeners();
  }

  updateGroup(PodcastGroup podcastGroup) async {
    var oldGroup = _groups.firstWhere((it) => it.id == podcastGroup.id);
    var index = _groups.indexOf(oldGroup);
    _groups.replaceRange(index, index + 1, [podcastGroup]);
    await podcastGroup.getPodcasts();
    notifyListeners();
    _saveGroup();
  }

  _saveGroup() async {
    await storage.saveGroup(_groups.map((it) => it.toEntity()).toList());
  }

  Future subscribe(PodcastLocal podcastLocal) async {
    _groups[0].podcastList.insert(0, podcastLocal.id);
    await _saveGroup();
    await dbHelper.savePodcastLocal(podcastLocal);
    await _groups[0].getPodcasts();
    notifyListeners();
  }

  Future updatePodcast(String id) async {
    int counts = await dbHelper.getPodcastCounts(id);
    _groups.forEach((group) {
      if (group.podcastList.contains(id)) {
        group.podcasts.firstWhere((podcast) => podcast.id == id)
          ..episodeCount = counts;
        notifyListeners();
      }
    });
  }

  Future subscribeNewPodcast(String id) async {
    if (!_groups[0].podcastList.contains(id))
      _groups[0].podcastList.insert(0, id);
    await _saveGroup();
    await _groups[0].getPodcasts();
    notifyListeners();
  }

  List<PodcastGroup> getPodcastGroup(String id) {
    List<PodcastGroup> result = [];
    _groups.forEach((group) {
      if (group.podcastList.contains(id)) {
        result.add(group);
      }
    });
    return result;
  }

  //Change podcast groups
  changeGroup(String id, List<PodcastGroup> list) async {
    _isLoading = true;
    notifyListeners();
    getPodcastGroup(id).forEach((group) {
      if (list.contains(group)) {
        list.remove(group);
      } else {
        group.podcastList.remove(id);
      }
    });
    list.forEach((s) {
      s.podcastList.insert(0, id);
    });
    await _saveGroup();
    await Future.forEach(_groups, (group) async {
      await group.getPodcasts();
    });
    _isLoading = false;
    notifyListeners();
  }

  //Unsubscribe podcast
  removePodcast(String id) async {
    _isLoading = true;
    notifyListeners();
    _groups.forEach((group) async {
      group.podcastList.remove(id);
    });
    await _saveGroup();
    await dbHelper.delPodcastLocal(id);
    await Future.forEach(_groups, (group) async {
      await group.getPodcasts();
    });
    _isLoading = false;
    notifyListeners();
  }

  saveOrder(PodcastGroup group) async {
    group.podcastList = group.ordereddPodcasts.map((e) => e.id).toList();
    await _saveGroup();
    await group.getPodcasts();
    notifyListeners();
  }
}
