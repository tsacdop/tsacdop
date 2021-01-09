import 'dart:core';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:ui';

import 'package:color_thief_flutter/color_thief_flutter.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:webfeed/webfeed.dart';
import 'package:workmanager/workmanager.dart';

import '../local_storage/key_value_storage.dart';
import '../local_storage/sqflite_localpodcast.dart';
import '../service/gpodder_api.dart';
import '../type/fireside_data.dart';
import '../type/podcastlocal.dart';

void callbackDispatcher() {
  if (Platform.isAndroid) {
    Workmanager.executeTask((task, inputData) async {
      final gpodder = Gpodder();
      final status = await gpodder.getChanges();
      if (status == 200) {
        await gpodder.updateChange();
        developer.log('Gpodder sync successfully');
      }
      return Future.value(true);
    });
  }
}

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
    var list = List<String>.from(json['podcastList']);
    return GroupEntity(json['name'] as String, json['id'] as String,
        json['color'] as String, list);
  }
}

class PodcastGroup extends Equatable {
  /// Group name.
  final String name;

  final String id;

  /// Group theme color, not used.
  final String color;

  /// Id lists of podcasts in group.
  final List<String> podcastList;

  final List<PodcastLocal> podcasts;

  PodcastGroup(this.name,
      {this.color = '#000000',
      String id,
      List<String> podcastList,
      List<PodcastLocal> podcasts})
      : id = id ?? Uuid().v4(),
        podcastList = podcastList ?? [],
        podcasts = podcasts ?? [];

  final _dbHelper = DBHelper();

  Future<void> getPodcasts() async {
    podcasts.clear();
    if (podcastList.isNotEmpty) {
      try {
        var result = await _dbHelper.getPodcastLocal(podcastList);
        if (podcasts.isEmpty) podcasts.addAll(result);
      } catch (e) {
        await Future.delayed(Duration(milliseconds: 200));
        try {
          var result = await _dbHelper.getPodcastLocal(podcastList);
          if (podcasts.isEmpty) podcasts.addAll(result);
        } catch (e) {
          developer.log(e.toString());
        }
      }
    }
  }

  Future<PodcastGroup> updatePodcast(PodcastLocal podcast) async {
    var count = await _dbHelper.getPodcastCounts(podcast.id);
    var list = [
      for (var p in podcasts)
        p == podcast ? podcast.copyWith(updateCount: count) : p
    ];
    return PodcastGroup(name,
        id: id, color: color, podcastList: podcastList, podcasts: list);
  }

  void reorderGroup(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final podcast = podcasts.removeAt(oldIndex);
    podcasts.insert(newIndex, podcast);
    podcastList.removeAt(oldIndex);
    podcastList.insert(newIndex, podcast.id);
  }

  void addToGroup(PodcastLocal podcast) {
    if (!podcasts.contains(podcast)) {
      podcasts.add(podcast);
      podcastList.add(podcast.id);
    }
  }

  void addToGroupAt(PodcastLocal podcast, {int index = 0}) {
    if (!podcasts.contains(podcast)) {
      podcasts.insert(index, podcast);
      podcastList.insert(index, podcast.id);
    }
  }

  void deleteFromGroup(PodcastLocal podcast) {
    podcasts.remove(podcast);
    podcastList.remove(podcast.id);
  }

  Color getColor() {
    if (color != '#000000') {
      var colorInt = int.parse('FF${color.toUpperCase()}', radix: 16);
      return Color(colorInt).withOpacity(1.0);
    } else {
      return Colors.blue[400];
    }
  }

  ///Ordered podcast list.
  //List<PodcastLocal> _orderedPodcasts;
  //List<PodcastLocal> get orderedPodcasts => _orderedPodcasts;

  //set orderedPodcasts(list) => _orderedPodcasts = list;

  GroupEntity toEntity() {
    return GroupEntity(name, id, color, podcastList);
  }

  static PodcastGroup fromEntity(GroupEntity entity) {
    return PodcastGroup(
      entity.name,
      id: entity.id,
      color: entity.color,
      podcastList: entity.podcastList.toSet().toList(),
    );
  }

  @override
  List<Object> get props => [id, name];
}

enum SubscribeState { none, start, subscribe, fetch, stop, exist, error }

class SubscribeItem {
  ///Rss url.
  String url;

  ///Rss title.
  String title;

  /// Subscribe status.
  SubscribeState subscribeState;

  /// Podcast id.
  String id;

  ///Avatar image link.
  String imgUrl;

  ///Podcast group, default Home.
  String group;

  SubscribeItem(
    this.url,
    this.title, {
    this.subscribeState = SubscribeState.none,
    this.id = '',
    this.imgUrl = '',
    this.group = '',
  });
}

class GroupList extends ChangeNotifier {
  /// List of all gourps.
  List<PodcastGroup> _groups = [];
  List<PodcastGroup> get groups => _groups;

  List<PodcastGroup> _orderChanged = [];
  List<PodcastGroup> get orderChanged => _orderChanged;
  //GroupList({List<PodcastGroup> groups}) : _groups = groups ?? [];

  /// Subscribe worker isolate
  FlutterIsolate subIsolate;
  ReceivePort receivePort;
  SendPort subSendPort;

  /// Current subsribe item from isolate.
  SubscribeItem _currentSubscribeItem = SubscribeItem('', '');
  SubscribeItem get currentSubscribeItem => _currentSubscribeItem;

  /// Default false, true if subscribe isolate is created.
  bool _created = false;
  bool get created => _created;

  final DBHelper _dbHelper = DBHelper();

  /// Groups save in shared_prefrences.
  final KeyValueStorage _groupStorage = KeyValueStorage(groupsKey);

  @override
  void addListener(VoidCallback listener) {
    if (_groups.isEmpty) {
      loadGroups().then((value) => super.addListener(listener));
      gpodderSyncNow();
    }
  }

  @override
  void dispose() {
    subIsolate?.kill();
    subIsolate = null;
    super.dispose();
  }

  /// Subscribe podcast via isolate.
  /// Add subsribe item
  SubscribeItem _subscribeItem;
  setSubscribeItem(SubscribeItem item, {bool syncGpodder = true}) async {
    _subscribeItem = item;
    if (syncGpodder) _syncAdd(item.url);
    await _start();
  }

  _setCurrentSubscribeItem(SubscribeItem item) {
    _currentSubscribeItem = item;
    notifyListeners();
  }

  Future<void> _syncAdd(String rssUrl) async {
    final check = await _checkGpodderLoggedin();
    if (check) {
      await _addStorage.addList([rssUrl]);
    }
  }

  Future<void> _start() async {
    if (!_created) {
      await _createIsolate();
      _created = true;
      listen();
    } else {
      subSendPort.send([
        _subscribeItem.url,
        _subscribeItem.title,
        _subscribeItem.imgUrl,
        _subscribeItem.group,
      ]);
    }
  }

  Future<void> _createIsolate() async {
    receivePort = ReceivePort();
    subIsolate =
        await FlutterIsolate.spawn(subIsolateEntryPoint, receivePort.sendPort);
  }

  /// Isolate listener to get subscrribe status.
  void listen() {
    receivePort.distinct().listen((message) {
      if (message is SendPort) {
        subSendPort = message;
        subSendPort.send([
          _subscribeItem.url,
          _subscribeItem.title,
          _subscribeItem.imgUrl,
          _subscribeItem.group,
        ]);
      } else if (message is List) {
        _setCurrentSubscribeItem(SubscribeItem(
          message[1],
          message[0],
          subscribeState: SubscribeState.values[message[2]],
        ));
        if (message.length == 5) {
          _subscribeNewPodcast(id: message[3], groupName: message[4]);
        }
      } else if (message is String && message == "done") {
        subIsolate.kill();
        subIsolate = null;
        _currentSubscribeItem = SubscribeItem('', '');
        _created = false;
        notifyListeners();
      }
    });
  }

  ///Set gpodder sync
  final _loginInfp = KeyValueStorage(gpodderApiKey);
  final _addStorage = KeyValueStorage(gpodderAddKey);
  final _removeStorage = KeyValueStorage(gpodderRemoveKey);
  final _remoteAddStorage = KeyValueStorage(gpodderRemoteAddKey);
  final _remoteRemoveStorage = KeyValueStorage(gpodderRemoteRemoveKey);

  Future<bool> _checkGpodderLoggedin() async {
    final loginInfo = await _loginInfp.getStringList();
    return loginInfo.isNotEmpty;
  }

  Future<void> gpodderSyncNow() async {
    final addList = await _remoteAddStorage.getStringList();
    final removeList = await _remoteRemoveStorage.getStringList();

    if (removeList.isNotEmpty) {
      for (var rssLink in removeList) {
        final exist = await _dbHelper.checkPodcast(rssLink);
        if (exist != '') {
          var podcast = await _dbHelper.getPodcastWithUrl(rssLink);
          await _unsubscribe(podcast);
        }
      }
      await _remoteAddStorage.clearList();
    }
    if (addList.isNotEmpty) {
      for (var rssLink in addList) {
        final exist = await _dbHelper.checkPodcast(rssLink);
        if (exist == '') {
          var item = SubscribeItem(rssLink, rssLink, group: 'Home');
          _subscribeItem = item;
          await _start();

          await Future.delayed(Duration(milliseconds: 200));
        }
      }
      await _remoteRemoveStorage.clearList();
    }
  }

  void setWorkManager() {
    Workmanager.initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
    Workmanager.registerPeriodicTask("2", "gpodder_sync",
        frequency: Duration(hours: 4),
        initialDelay: Duration(seconds: 10),
        constraints: Constraints(
          networkType: NetworkType.connected,
        ));
    developer.log('work manager init done + (gpodder sync)');
  }

  Future cancelWork() async {
    await Workmanager.cancelByUniqueName('2');
    developer.log('work job cancelled');
  }

  /// Mange groups states in app.
  /// Load groups from storage at start.
  Future<void> loadGroups() async {
    _groupStorage.getGroups().then((loadgroups) async {
      _groups.addAll(loadgroups.map(PodcastGroup.fromEntity));
      for (var group in _groups) {
        await group.getPodcasts();
      }
      _groups = [...groups];
      notifyListeners();
    });
  }

  void addToOrderChanged(PodcastGroup group) {
    if (_orderChanged.contains(group)) {
      _orderChanged = [for (var g in _orderChanged) g == group ? group : g];
    } else {
      _orderChanged = [..._orderChanged, group];
    }
    notifyListeners();
  }

  void drlFromOrderChanged(String name) {
    _orderChanged = [
      for (var group in _orderChanged)
        if (group.name != name) group
    ];
    notifyListeners();
  }

  void clearOrderChanged() {
    _orderChanged.clear();
  }

  /// Update podcasts of each group
  Future<void> updateGroups() async {
    for (var group in _groups) {
      await group.getPodcasts();
    }
    _groups = [..._groups];
    notifyListeners();
  }

  /// Add new group.
  Future<void> addGroup(PodcastGroup podcastGroup) async {
    _groups = [..._groups, podcastGroup];
    notifyListeners();
    await _saveGroup();
  }

  /// Remove group.
  Future<void> delGroup(PodcastGroup podcastGroup) async {
    for (var podcast in podcastGroup.podcasts) {
      if (!_groups.first.podcasts.contains(podcast)) {
        _groups.first.addToGroup(podcast);
      }
    }
    _groups = [
      for (var group in _groups)
        if (group.id != podcastGroup.id) group
    ];
    notifyListeners();
    await _saveGroup();
  }

  Future<void> updateGroup(PodcastGroup podcastGroup) async {
    _groups = [
      for (var group in _groups) group == podcastGroup ? podcastGroup : group
    ];
    notifyListeners();
    _saveGroup();
  }

  Future<void> _updateGroups() async {
    _groups = [..._groups];
    notifyListeners();
    await _saveGroup();
  }

  Future<void> _saveGroup() async {
    await _groupStorage.saveGroup(_groups.map((it) => it.toEntity()).toList());
  }

  /// Subscribe podcast from search result.
  Future subscribe(PodcastLocal podcast) async {
    await _dbHelper.savePodcastLocal(podcast);
    _groups.first.addToGroupAt(podcast);
    _updateGroups();
  }

  /// Subscribe podcast from OPML.
  Future<bool> _subscribeNewPodcast(
      {String id, String groupName = 'Home'}) async {
    //List<String> groupNames = _groups.map((e) => e.name).toList();
    var podcasts = await _dbHelper.getPodcastLocal([id]);
    for (var group in _groups) {
      if (group.name == groupName) {
        if (group.podcastList.contains(id)) {
          return true;
        } else {
          group.addToGroupAt(podcasts.first);
          _updateGroups();
          return true;
        }
      }
    }
    _groups = [
      ..._groups,
      PodcastGroup(groupName, podcastList: [id], podcasts: podcasts)
    ];
    notifyListeners();
    await _saveGroup();
    return true;
  }

  List<PodcastGroup> getPodcastGroup(String id) {
    var result = <PodcastGroup>[];
    for (var group in _groups) {
      if (group.podcastList.contains(id)) {
        result.add(group);
      }
    }
    return result;
  }

  //Change podcast groups
  Future<void> changeGroup(
      PodcastLocal podcast, List<PodcastGroup> list) async {
    for (var group in getPodcastGroup(podcast.id)) {
      if (list.contains(group)) {
        list.remove(group);
      } else {
        group.deleteFromGroup(podcast);
      }
    }
    for (var s in list) {
      s.addToGroup(podcast);
    }
    _updateGroups();
  }

  /// Unsubscribe podcast
  Future<void> _syncRemove(String rssUrl) async {
    final check = await _checkGpodderLoggedin();
    if (check) {
      await _removeStorage.addList([rssUrl]);
    }
  }

  Future<void> _unsubscribe(PodcastLocal podcast) async {
    for (var group in _groups) {
      group.deleteFromGroup(podcast);
    }
    _updateGroups();
    await _dbHelper.delPodcastLocal(podcast.id);
  }

  /// Delete podcsat from device.
  Future<void> removePodcast(
    PodcastLocal podcast,
  ) async {
    _syncRemove(podcast.rssUrl);
    await _unsubscribe(podcast);
    await File(podcast.imagePath)?.delete();
  }

  Future<void> saveOrder(PodcastGroup group) async {
    // group.podcastList = group.orderedPodcasts.map((e) => e.id).toList();
    var orderedGroup;
    for (var g in _orderChanged) {
      if (g == group) orderedGroup = g;
    }
    _groups = [for (var g in _groups) g == orderedGroup ? orderedGroup : g];
    notifyListeners();
    await _saveGroup();
  }
}

Future<void> subIsolateEntryPoint(SendPort sendPort) async {
  var items = <SubscribeItem>[];
  var _running = false;
  final listColor = <String>[
    '388E3C',
    '1976D2',
    'D32F2F',
    '00796B',
  ];
  var subReceivePort = ReceivePort();
  sendPort.send(subReceivePort.sendPort);

  Future<String> _getColor(File file) async {
    final imageProvider = FileImage(file);
    var colorImage = await getImageFromProvider(imageProvider);
    var color = await getColorFromImage(colorImage);
    var primaryColor = color.toString();
    return primaryColor;
  }

  Future<void> _subscribe(SubscribeItem item) async {
    var dbHelper = DBHelper();
    var rss = item.url;
    sendPort.send([item.title, item.url, 1]);
    var options = BaseOptions(
      connectTimeout: 30000,
      receiveTimeout: 90000,
    );

    try {
      var response = await Dio(options).get(rss);
      RssFeed p;
      try {
        p = RssFeed.parse(response.data);
      } catch (e) {
        sendPort.send([item.title, item.url, 6]);
        await Future.delayed(Duration(seconds: 2));
        sendPort.send([item.title, item.url, 4]);
        items.removeWhere((element) => element.url == item.url);
        if (items.isNotEmpty) {
          await _subscribe(items.first);
        } else {
          sendPort.send("done");
        }
      }

      var dir = await getApplicationDocumentsDirectory();

      var realUrl =
          response.redirects.isEmpty ? rss : response.realUri.toString();

      var checkUrl = await dbHelper.checkPodcast(realUrl);

      /// If url not existe in database.
      if (checkUrl == '') {
        img.Image thumbnail;
        String imageUrl;
        try {
          var imageResponse = await Dio().get<List<int>>(p.itunes.image.href,
              options: Options(
                responseType: ResponseType.bytes,
                receiveTimeout: 90000,
              ));
          imageUrl = p.itunes.image.href;
          var image = img.decodeImage(imageResponse.data);
          thumbnail = img.copyResize(image, width: 300);
        } catch (e) {
          try {
            var imageResponse = await Dio().get<List<int>>(item.imgUrl,
                options: Options(
                  responseType: ResponseType.bytes,
                  receiveTimeout: 90000,
                ));
            imageUrl = item.imgUrl;
            var image = img.decodeImage(imageResponse.data);
            thumbnail = img.copyResize(image, width: 300);
          } catch (e) {
            developer.log(e.toString(), name: 'Download image error');
            try {
              var index = math.Random().nextInt(3);
              var imageResponse = await Dio().get<List<int>>(
                  "https://ui-avatars.com/api/?size=300&background="
                  "${listColor[index]}&color=fff&name=${item.title}&length=2&bold=true",
                  options: Options(responseType: ResponseType.bytes));
              imageUrl = "https://ui-avatars.com/api/?size=300&background="
                  "${listColor[index]}&color=fff&name=${item.title}&length=2&bold=true";
              thumbnail = img.decodeImage(imageResponse.data);
            } catch (e) {
              developer.log(e.toString(), name: 'Donwload image error');
              sendPort.send([item.title, item.url, 6]);
              await Future.delayed(Duration(seconds: 2));
              sendPort.send([item.title, item.url, 4]);
              items.removeWhere((element) => element.url == item.url);
              if (items.length > 0) {
                await _subscribe(items.first);
              } else {
                sendPort.send("done");
              }
            }
          }
        }
        var uuid = Uuid().v4();
        File("${dir.path}/$uuid.png")
          ..writeAsBytesSync(img.encodePng(thumbnail));

        var imagePath = "${dir.path}/$uuid.png";
        var primaryColor = await _getColor(File("${dir.path}/$uuid.png"));
        var author = p.itunes.author ?? p.author ?? '';
        var provider = p.generator ?? '';
        var link = p.link ?? '';
        var funding = p.podcastFunding.isNotEmpty
            ? [for (var f in p.podcastFunding) f.url]
            : <String>[];
        var podcastLocal = PodcastLocal(p.title, imageUrl, realUrl,
            primaryColor, author, uuid, imagePath, provider, link, funding,
            description: p.description);

        await dbHelper.savePodcastLocal(podcastLocal);
        sendPort.send([item.title, item.url, 2, uuid, item.group]);
        if (provider.contains('fireside')) {
          var data = FiresideData(uuid, link);
          try {
            await data.fatchData();
          } catch (e) {
            developer.log(e.toString(), name: 'Fatch fireside data error');
          }
        }
        await dbHelper.savePodcastRss(p, uuid);

        //   if (item.syncWithGpodder) {
        //     final gpodder = Gpodder();
        //     await gpodder.updateChange({
        //       'add': [item.url]
        //     });
        //   }

        sendPort.send([item.title, item.url, 3, uuid]);

        await Future.delayed(Duration(seconds: 2));

        sendPort.send([item.title, item.url, 4]);
        items.removeAt(0);
        if (items.length > 0) {
          await _subscribe(items.first);
        } else {
          sendPort.send("done");
        }
      } else {
        sendPort.send([item.title, realUrl, 5, checkUrl, item.group]);
        await Future.delayed(Duration(seconds: 2));
        sendPort.send([item.title, item.url, 4]);
        items.removeAt(0);
        if (items.length > 0) {
          await _subscribe(items.first);
        } else {
          sendPort.send("done");
        }
      }
    } catch (e) {
      developer.log('$e confirm');
      sendPort.send([item.title, item.url, 6]);
      await Future.delayed(Duration(seconds: 2));
      sendPort.send([item.title, item.url, 4]);
      items.removeWhere((element) => element.url == item.url);
      if (items.length > 0) {
        await _subscribe(items.first);
      } else {
        sendPort.send("done");
      }
    }
  }

  subReceivePort.distinct().listen((message) {
    if (message is List<dynamic>) {
      items.add(SubscribeItem(message[0], message[1],
          imgUrl: message[2], group: message[3]));
      if (!_running) {
        _subscribe(items.first);
        _running = true;
      }
    }
  });
}
