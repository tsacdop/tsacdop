import 'dart:core';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:tsacdop/local_storage/key_value_storage.dart';
import 'package:tsacdop/local_storage/sqflite_localpodcast.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:color_thief_flutter/color_thief_flutter.dart';
import 'package:dio/dio.dart';

import '../webfeed/webfeed.dart';
import '../local_storage/sqflite_localpodcast.dart';
import '../local_storage/key_value_storage.dart';
import '../type/fireside_data.dart';
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
  /// Group name.
  final String name;

  final String id;

  /// Group theme color, not used.
  final String color;

  /// Id lists of podcasts in group.
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

  ///Podcast in group.
  List<PodcastLocal> _podcasts;
  List<PodcastLocal> get podcasts => _podcasts;

  ///Ordered podcast list.
  List<PodcastLocal> _orderedPodcasts;
  List<PodcastLocal> get ordereddPodcasts => _orderedPodcasts;

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
  SubscribeItem(this.url, this.title,
      {this.subscribeState = SubscribeState.none,
      this.id = '',
      this.imgUrl = '',
      this.group = ''});
}

class GroupList extends ChangeNotifier {
  /// List of all gourps.
  List<PodcastGroup> _groups = [];
  List<PodcastGroup> get groups => _groups;

  DBHelper dbHelper = DBHelper();

  /// Groups save in shared_prefrences.
  KeyValueStorage storage = KeyValueStorage('groups');

  //GroupList({List<PodcastGroup> groups}) : _groups = groups ?? [];

  /// Default false, true during loading groups from storage.
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Svae ordered gourps info before saved.
  List<PodcastGroup> _orderChanged = [];
  List<PodcastGroup> get orderChanged => _orderChanged;

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

  /// Add subsribe item
  SubscribeItem _subscribeItem;
  setSubscribeItem(SubscribeItem item) async {
    _subscribeItem = item;
    await _start();
  }

  _setCurrentSubscribeItem(SubscribeItem item) {
    _currentSubscribeItem = item;
    notifyListeners();
  }

  Future _start() async {
    if (_created == false) {
      await _createIsolate();
      _created = true;
      listen();
    } else
      subSendPort.send([
        _subscribeItem.url,
        _subscribeItem.title,
        _subscribeItem.imgUrl,
        _subscribeItem.group
      ]);
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
          _subscribeItem.group
        ]);
      } else if (message is List) {
        _setCurrentSubscribeItem(SubscribeItem(
          message[1],
          message[0],
          subscribeState: SubscribeState.values[message[2]],
        ));
        if (message.length == 5)
          _subscribeNewPodcast(id: message[3], groupName: message[4]);
      } else if (message is String && message == "done") {
        subIsolate.kill();
        subIsolate = null;
        _currentSubscribeItem = SubscribeItem('', '');
        _created = false;
        notifyListeners();
      }
    });
  }

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
      for (var group in _orderChanged) await group.getPodcasts();
      _orderChanged.clear();
      // notifyListeners();
    }
  }

  @override
  void addListener(VoidCallback listener) {
    loadGroups().then((value) => super.addListener(listener));
  }

  @override
  void dispose() {
    subIsolate?.kill();
    subIsolate = null;
    super.dispose();
  }

  /// Load groups from storage at start.
  Future loadGroups() async {
    _isLoading = true;
    notifyListeners();
    storage.getGroups().then((loadgroups) async {
      _groups.addAll(loadgroups.map((e) => PodcastGroup.fromEntity(e)));
      for (var group in _groups) await group.getPodcasts();
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Update podcasts of each group
  Future updateGroups() async {
    for (var group in _groups) await group.getPodcasts();
    notifyListeners();
  }

  /// Add new group.
  Future addGroup(PodcastGroup podcastGroup) async {
    _isLoading = true;
    _groups.add(podcastGroup);
    await _saveGroup();
    _isLoading = false;
    notifyListeners();
  }

  /// Remove group.
  Future delGroup(PodcastGroup podcastGroup) async {
    _isLoading = true;
    for (var podcast in podcastGroup.podcastList)
      if (!_groups.first.podcastList.contains(podcast)) {
        _groups[0].podcastList.insert(0, podcast);
      }
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

  /// Subscribe podcast from search result.
  Future subscribe(PodcastLocal podcastLocal) async {
    _groups[0].podcastList.insert(0, podcastLocal.id);
    await _saveGroup();
    await dbHelper.savePodcastLocal(podcastLocal);
    await _groups[0].getPodcasts();
    notifyListeners();
  }

  Future updatePodcast(String id) async {
    int counts = await dbHelper.getPodcastCounts(id);
    for (var group in _groups)
      if (group.podcastList.contains(id)) {
        group.podcasts.firstWhere((podcast) => podcast.id == id)
          ..episodeCount = counts;
        notifyListeners();
      }
  }

  /// Subscribe podcast from OMPL.
  Future _subscribeNewPodcast({String id, String groupName = 'Home'}) async {
    for (PodcastGroup group in _groups) {
      if (group.name == groupName) {
        if (!group.podcastList.contains(id)) {
          group.podcastList.insert(0, id);
          await _saveGroup();
          await group.getPodcasts();
          notifyListeners();
          return;
        }
      }
    }
    _isLoading = true;
    _groups.add(PodcastGroup(groupName));
    _groups.last.podcastList.insert(0, id);
    await _saveGroup();
    await _groups.last.getPodcasts();
    _isLoading = false;
    notifyListeners();
  }

  List<PodcastGroup> getPodcastGroup(String id) {
    List<PodcastGroup> result = [];
    for (var group in _groups)
      if (group.podcastList.contains(id)) {
        result.add(group);
      }
    return result;
  }

  //Change podcast groups
  changeGroup(String id, List<PodcastGroup> list) async {
    _isLoading = true;
    notifyListeners();

    for (var group in getPodcastGroup(id)) {
      if (list.contains(group)) {
        list.remove(group);
      } else {
        group.podcastList.remove(id);
      }
    }
    for (var s in list) s.podcastList.insert(0, id);
    await _saveGroup();
    for (var group in _groups) await group.getPodcasts();
    _isLoading = false;
    notifyListeners();
  }

  /// Unsubscribe podcast
  removePodcast(String id) async {
    _isLoading = true;
    notifyListeners();
    for (var group in _groups) group.podcastList.remove(id);
    await _saveGroup();
    await dbHelper.delPodcastLocal(id);
    for (var group in _groups) await group.getPodcasts();
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

Future<void> subIsolateEntryPoint(SendPort sendPort) async {
  List<SubscribeItem> items = [];
  bool _running = false;
  final List<String> listColor = [
    '388E3C',
    '1976D2',
    'D32F2F',
    '00796B',
  ];
  ReceivePort subReceivePort = ReceivePort();
  sendPort.send(subReceivePort.sendPort);

  Future<String> _getColor(File file) async {
    final imageProvider = FileImage(file);
    var colorImage = await getImageFromProvider(imageProvider);
    var color = await getColorFromImage(colorImage);
    String primaryColor = color.toString();
    return primaryColor;
  }

  Future<void> _subscribe(SubscribeItem item) async {
    var dbHelper = DBHelper();
    String rss = item.url;
    sendPort.send([item.title, item.url, 1]);
    BaseOptions options = new BaseOptions(
      connectTimeout: 20000,
      receiveTimeout: 20000,
    );
    print(rss);

    try {
      Response response = await Dio(options).get(rss);
      RssFeed p;
      try {
        p = RssFeed.parse(response.data);
      } on ArgumentError catch (e) {
        print(e);
        sendPort.send([item.title, item.url, 6]);
        await Future.delayed(Duration(seconds: 2));
        sendPort.send([item.title, item.url, 4]);
        items.removeWhere((element) => element.url == item.url);
        if (items.isNotEmpty) {
          await _subscribe(items.first);
        } else
          sendPort.send("done");
      }

      var dir = await getApplicationDocumentsDirectory();

      String realUrl =
          response.redirects.isEmpty ? rss : response.realUri.toString();

      String checkUrl = await dbHelper.checkPodcast(realUrl);

      /// If url not existe in database.
      if (checkUrl == '') {
        img.Image thumbnail;
        String imageUrl;
        try {
          Response<List<int>> imageResponse = await Dio().get<List<int>>(
              p.itunes.image.href,
              options: Options(responseType: ResponseType.bytes));
          imageUrl = p.itunes.image.href;
          img.Image image = img.decodeImage(imageResponse.data);
          thumbnail = img.copyResize(image, width: 300);
        } catch (e) {
          try {
            Response<List<int>> imageResponse = await Dio().get<List<int>>(
                item.imgUrl,
                options: Options(responseType: ResponseType.bytes));
            imageUrl = item.imgUrl;
            img.Image image = img.decodeImage(imageResponse.data);
            thumbnail = img.copyResize(image, width: 300);
          } catch (e) {
            print(e);
            try {
              int index = math.Random().nextInt(3);
              Response<List<int>> imageResponse = await Dio().get<List<int>>(
                  "https://ui-avatars.com/api/?size=300&background="
                  "${listColor[index]}&color=fff&name=${item.title}&length=2&bold=true",
                  options: Options(responseType: ResponseType.bytes));
              imageUrl = "https://ui-avatars.com/api/?size=300&background="
                  "${listColor[index]}&color=fff&name=${item.title}&length=2&bold=true";
              thumbnail = img.decodeImage(imageResponse.data);
            } catch (e) {
              print(e);
              sendPort.send([item.title, item.url, 6]);
              await Future.delayed(Duration(seconds: 2));
              sendPort.send([item.title, item.url, 4]);
              items.removeWhere((element) => element.url == item.url);
              if (items.length > 0) {
                await _subscribe(items.first);
              } else
                sendPort.send("done");
            }
          }
        }
        String uuid = Uuid().v4();
        File("${dir.path}/$uuid.png")
          ..writeAsBytesSync(img.encodePng(thumbnail));

        String imagePath = "${dir.path}/$uuid.png";
        String primaryColor = await _getColor(File("${dir.path}/$uuid.png"));
        String author = p.itunes.author ?? p.author ?? '';
        String provider = p.generator ?? '';
        String link = p.link ?? '';
        PodcastLocal podcastLocal = PodcastLocal(p.title, imageUrl, realUrl,
            primaryColor, author, uuid, imagePath, provider, link,
            description: p.description);

        await dbHelper.savePodcastLocal(podcastLocal);
        sendPort.send([item.title, item.url, 2, uuid, item.group]);
        if (provider.contains('fireside')) {
          FiresideData data = FiresideData(uuid, link);
          try {
            await data.fatchData();
          } catch (e) {
            print(e);
          }
        }
        await dbHelper.savePodcastRss(p, uuid);

        sendPort.send([item.title, item.url, 3, uuid]);

        await Future.delayed(Duration(seconds: 2));

        sendPort.send([item.title, item.url, 4]);
        items.removeWhere((element) => element.url == item.url);
        if (items.length > 0) {
          await _subscribe(items.first);
        } else
          sendPort.send("done");
      } else {
        sendPort.send([item.title, realUrl, 5, checkUrl, item.group]);
        await Future.delayed(Duration(seconds: 2));
        sendPort.send([item.title, item.url, 4]);
        items.removeWhere((element) => element.url == item.url);
        if (items.length > 0) {
          await _subscribe(items.first);
        } else
          sendPort.send("done");
      }
    } on DioError catch (e) {
      print(e);
      sendPort.send([item.title, item.url, 6]);
      await Future.delayed(Duration(seconds: 2));
      sendPort.send([item.title, item.url, 4]);
      items.removeWhere((element) => element.url == item.url);
      if (items.length > 0) {
        await _subscribe(items.first);
      } else
        sendPort.send("done");
    }
  }

  subReceivePort.distinct().listen((message) {
    if (message is List<String>) {
      items.add(SubscribeItem(message[0], message[1],
          imgUrl: message[2], group: message[3]));
      if (!_running) {
        _subscribe(items.first);
        _running = true;
      }
    }
  });
}
